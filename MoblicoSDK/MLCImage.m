/*
 Copyright 2012 Moblico Solutions LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MLCImage.h"
#import "MLCEntity_Private.h"
#import <CommonCrypto/CommonDigest.h>

@interface MLCImage ()

@property (strong, nonatomic, readwrite) NSData *data;
@end

@implementation MLCImage

- (instancetype)initWithURLString:(NSString *)URLString {
    if (!URLString) {
        return nil;
    }
    self = [self initWithJSONObject:@{@"url": URLString}];
    return self;
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    NSUInteger imageId = [MLCEntity unsignedIntegerFromValue:jsonObject[@"imageId"]];
    NSURL *url = [MLCEntity URLFromValue:jsonObject[@"url"]];
    if (imageId == 0 && url == nil) {
        return nil;
    }

    NSMutableDictionary *object = [jsonObject mutableCopy];
    if (!jsonObject[@"scaleFactor"]) {
        object[@"scaleFactor"] = @(2.0);
    }

    self = [super initWithJSONObject:object];
    
    return self;
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"data", @"path", @"dataTask"];
}

+ (instancetype)deserializeFromString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@";"];
    if (components.count != 3) {
        return nil;
    }
    NSString *imageId = components[0];
    NSString *url = components[1];
    NSString *lastUpdateDate = components[2];

    return [[self.class alloc] initWithJSONObject:@{@"id": imageId,
                                                      @"url": url,
                                                      @"lastUpdateDate": lastUpdateDate}];
}

- (void)loadImageData {
    if (self.data) {
        self.data = self.data;
        return;
    }

    [self loadImageData:^(NSData *data, NSError *error, BOOL fromCache, CGFloat scale) {
        self.data = data ?: [NSData data];
    }];
}

- (void)loadImageData:(MLCImageCompletionHandler)handler {
    return [self _mlc_loadImageDataFromURL:self.url handler:handler];
}

+ (NSCache *)_mlc_sharedCache {
    static NSCache *sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[NSCache alloc] init];
    });

    return sharedCache;
}

+ (NSString *)_mlc_cacheDirectory {
    static NSString *cacheDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *searchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        cacheDirectory = [searchPath stringByAppendingPathComponent:@"CachedImages"];
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create CachedImages directory: %@", error.localizedDescription);
        }
    });

    return cacheDirectory;
}

- (NSString *)sha1Hash:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (NSString *)cachedPath:(NSString *)key {
    NSString *fileName = [self sha1Hash:key];

    return [[self.class _mlc_cacheDirectory] stringByAppendingPathComponent:fileName];
}

- (void)_mlc_loadImageDataFromURL:(NSURL *)url handler:(MLCImageCompletionHandler)handler {
    NSString *key = [url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
    NSCache *cache = [self.class _mlc_sharedCache];
    NSData *cachedData = [cache objectForKey:key];
    NSString *cachedPath = [self cachedPath:key];

    CGFloat scale = self.scaleFactor;
    if (cachedData) {
        handler(cachedData, nil, YES, scale);
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueue.mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            [cache setObject:data forKey:key];
            [data writeToFile:cachedPath atomically:YES];
        }
        else {
            data = [NSData dataWithContentsOfFile:cachedPath];
            [cache removeObjectForKey:key];
        }

        handler(data, error, NO, scale);
    }];
}

@end
