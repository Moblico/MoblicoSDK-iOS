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

#import "MLCMedia.h"
#import "MLCLogger.h"
#import <CommonCrypto/CommonDigest.h>

@interface MLCMedia ()
@property (class, nonatomic, readonly) NSCache *sharedCache;
@property (class, nonatomic, readonly) NSString *cacheDirectory;
- (void)loadDataFromURL:(NSURL *)url handler:(MLCMediaDataCompletionHandler)handler;
@end

@implementation MLCMedia

+ (NSString *)collectionName {
    return @"media";
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"data", @"dataTask", @"cachedImage", @"cachedThumb", @"cachedData"];
}

- (instancetype)initWithJSONObject:(NSDictionary<NSString *,id> *)jsonObject {
    self = [super initWithJSONObject:jsonObject];
    if (self) {
        if (_attributes == nil) {
            _attributes = @{};
        }
    }
    return self;
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
        cacheDirectory = [searchPath stringByAppendingPathComponent:@"CachedMedia"];
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            MLCDebugLog(@"Failed to create CachedMedia directory: %@", error.localizedDescription);
        }
    });

    return cacheDirectory;
}

+ (BOOL)clearCache:(out NSError **)error {
    NSString *cacheDirectory = self.cacheDirectory;
    return [NSFileManager.defaultManager removeItemAtPath:cacheDirectory error:error] && [NSFileManager.defaultManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:error];
}

- (void)loadImage:(MLCMediaImageCompletionHandler)handler {
    return [self loadImageFromURL:self.imageUrl handler:handler];
}

- (id)cachedImage {
    NSData *data = [self cachedDataFromURL:self.imageUrl];
    if (!data) {
        return nil;
    }

#if TARGET_OS_IOS
    return [[UIImage alloc] initWithData:data scale:2.0];
#else
    return data;
#endif
}

- (void)loadThumb:(MLCMediaImageCompletionHandler)handler {
    [self loadImageFromURL:self.thumbUrl handler:handler];
}

- (id)cachedThumb {
    return [self cachedImageFromURL:self.thumbUrl];
}

- (void)loadData:(MLCMediaDataCompletionHandler)handler {
    [self loadDataFromURL:self.url handler:handler];
}

- (NSData *)cachedData {
    return [self cachedDataFromURL:self.url];
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

    return [MLCMedia.cacheDirectory stringByAppendingPathComponent:fileName];
}

- (NSString *)typeForURL:(NSURL *)url {
    if (url == self.url) return @"url";
    if (url == self.thumbUrl) return @"thumbUrl";
    if (url == self.imageUrl) return @"imageUrl";

    return @"";
}

- (NSString *)keyForURL:(NSURL *)url {
    NSString *type = [self typeForURL:url];
    return [type stringByAppendingFormat:@"-%@", @(self.mediaId)];
//    return [url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
//    return url.absoluteString;
}

- (void)loadDataFromURL:(NSURL *)url handler:(MLCMediaDataCompletionHandler)handler {
    NSString *key = [self keyForURL:url];
    NSCache *cache = MLCMedia.sharedCache;
    NSData *cachedData = [cache objectForKey:key];
    NSString *cachedPath = [self cachedPath:key];

    if (cachedData) {
        handler(cachedData, nil, YES);
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueue.mainQueue completionHandler:^(__unused NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            [cache setObject:data forKey:key];
            [data writeToFile:cachedPath atomically:YES];
            handler(data, error, NO);
        } else {
            NSData *fallbackData = [NSData dataWithContentsOfFile:cachedPath];
            handler(fallbackData, error, NO);
        }
    }];
}

- (void)loadImageFromURL:(NSURL *)url handler:(MLCMediaImageCompletionHandler)handler {
#if TARGET_OS_IOS
    return [self loadDataFromURL:url handler:^(NSData *data, NSError *error, BOOL fromCache) {
        UIImage *image = [[UIImage alloc] initWithData:data scale:2.0];
        handler(image, error, fromCache);
    }];
#else
    return [self loadDataFromURL:url handler:handler];
#endif
}

- (NSData *)cachedDataFromURL:(NSURL *)url {
    return [NSData dataWithContentsOfFile:[self cachedPath:[self keyForURL:url]]];
}

- (id)cachedImageFromURL:(NSURL *)url {
    NSData *data = [self cachedDataFromURL:url];
    if (!data) {
        return nil;
    }

#if TARGET_OS_IOS
    return [[UIImage alloc] initWithData:data scale:2.0];
#else
    return data;
#endif
}

@end
