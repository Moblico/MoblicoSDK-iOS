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

typedef void(^MLCImageDataCompletionHandler)(NSData *data, NSError *error, BOOL fromCache) NS_SWIFT_NAME(MLCImage.DataCompletionHandler);


@interface MLCImage ()
@property (class, nonatomic, readonly) NSCache *sharedCache;
@property (class, nonatomic, readonly) NSString *cacheDirectory;
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
    return @[@"data", @"path", @"dataTask", @"cachedImage"];
}

- (instancetype)initWithStringComponents:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@";"];
    if (components.count != 3) {
        return nil;
    }
    NSString *imageId = components[0];
    NSString *url = components[1];
    NSString *lastUpdateDate = components[2];

    NSDictionary *jsonObject = @{@"id": imageId,
                                 @"url": url,
                                 @"lastUpdateDate": lastUpdateDate};
    self = [self initWithJSONObject:jsonObject];
    return self;
}

- (void)loadImage:(MLCImageCompletionHandler)handler {
#if TARGET_OS_IOS
    CGFloat scale = self.scaleFactor;
    return [self loadImageDataFromURL:self.url handler:^(NSData *data, NSError *error, BOOL fromCache) {
        UIImage *image = [[UIImage alloc] initWithData:data scale:scale];
        handler(image, error, fromCache);
    }];
#else
    return [self loadImageDataFromURL:self.url handler:handler];
#endif
}

- (NSData *)cachedImageData {
    NSString *key = [self.url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
    return [MLCImage.sharedCache objectForKey:key] ?: [NSData dataWithContentsOfFile:[self cachedPath:key]];
}

- (id)cachedImage {
    NSData *data = [self cachedImageData];
    if (!data) {
        return nil;
    }

#if TARGET_OS_IOS
    return [[UIImage alloc] initWithData:data scale:self.scaleFactor];
#else
    return data;
#endif
}

+ (NSCache *)sharedCache {
    static NSCache *sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[NSCache alloc] init];
    });

    return sharedCache;
}

+ (NSString *)cacheDirectory {
    static NSString *cacheDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *searchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        cacheDirectory = [searchPath stringByAppendingPathComponent:@"CachedImages"];
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create CachedImages directory: %@", error.localizedDescription);
        }
    });

    return cacheDirectory;
}

+ (BOOL)clearCache:(NSError **)error {
    NSString *cacheDirectory = self.cacheDirectory;
    return [NSFileManager.defaultManager removeItemAtPath:cacheDirectory error:error] && [NSFileManager.defaultManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:error];
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

    return [MLCImage.cacheDirectory stringByAppendingPathComponent:fileName];
}

- (void)loadImageDataFromURL:(NSURL *)url handler:(MLCImageDataCompletionHandler)handler {
    NSString *key = [url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
    NSCache *cache = MLCImage.sharedCache;
    NSData *cachedData = [cache objectForKey:key];
    NSString *cachedPath = [self cachedPath:key];

    if (cachedData) {
        handler(cachedData, nil, YES);
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueue.mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpResponse = (NSHTTPURLResponse *)response;
        }

        if (data) {
            [cache setObject:data forKey:key];
            [data writeToFile:cachedPath atomically:YES];
            handler(data, error, NO);
        } else if (httpResponse.statusCode == 404 || httpResponse.statusCode == 200) {
            [cache removeObjectForKey:key];
            [NSFileManager.defaultManager removeItemAtPath:cachedPath error:nil];
            handler(data, error, NO);
        } else {
            NSData *fallbackData = [NSData dataWithContentsOfFile:cachedPath];
            handler(fallbackData, error, NO);
        }
    }];
}

@end
