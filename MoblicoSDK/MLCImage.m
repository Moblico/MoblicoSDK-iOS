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
#import "MLCSessionManager.h"
#import "MLCEntity_Private.h"
#import <CommonCrypto/CommonDigest.h>
#import "MLCLogger.h"

typedef void(^MLCImageDataCompletionHandler)(NSData *data, NSURL *location, NSError *error);

@interface MLCImage ()
@property (class, nonatomic, readonly) NSCache *sharedCache;
@property (class, nonatomic, readonly) NSURL *cacheDirectoryURL;
@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, strong) NSURL *cacheFileURL;
@end

@implementation MLCImage

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"cachedImage", @"cacheKey", @"cacheFileURL"];
}

- (instancetype)initWithURLString:(NSString *)URLString {
    if (!URLString) {
        return nil;
    }
    self = [self initWithJSONObject:@{@"url": URLString}];
    return self;
}

- (instancetype)initWithStringComponents:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@";"];
    if (components.count != 3) {
        return nil;
    }
    NSString *imageId = components[0];
    NSString *url = components[1];
    NSString *lastUpdateDate = components[2];

    NSDictionary *jsonObject = @{@"id": imageId, @"url": url, @"lastUpdateDate": lastUpdateDate};
    self = [self initWithJSONObject:jsonObject];
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
    if (!jsonObject[@"lastUpdateDate"]) {
        NSDate *now = [[NSDate alloc] init];
        object[@"lastUpdateDate"] = [MLCEntity timestampFromDate:now];
    }
    self = [super initWithJSONObject:object];
    return self;
}

#if TARGET_OS_IOS
+ (UIImage *)imageFromData:(NSData *)data scale:(CGFloat)scale {
    if (!data) {
        return nil;
    }
    return [[UIImage alloc] initWithData:data scale:scale];
}
#else
+ (id)imageFromData:(NSData *)data scale:(__unused CGFloat)scale {
    return data;
}
#endif

- (void)loadImage:(MLCImageCompletionHandler)handler {
    CGFloat scale = self.scaleFactor;
    return [self loadImageData:^(NSData *data, __unused NSURL *location, NSError *error) {
        handler([MLCImage imageFromData:data scale:scale], error);
    }];
}

- (void)downloadImage:(MLCImageDownloadCompletionHandler)handler {
    return [self downloadImageData:^(__unused NSData *data, NSURL *location, NSError *error) {
        handler(location, error);
    }];
}

- (id)cachedImage {
    NSData *data = [MLCImage.sharedCache objectForKey:self.cacheKey] ?: [NSData dataWithContentsOfURL:self.cacheFileURL];
    return [MLCImage imageFromData:data scale:self.scaleFactor];
}

+ (BOOL)clearCache:(out NSError **)error {
    NSURL *cacheDirectoryURL = self.cacheDirectoryURL;
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:cacheDirectoryURL.path error:error];
    return attributes && [NSFileManager.defaultManager removeItemAtURL:cacheDirectoryURL error:error] && [NSFileManager.defaultManager createDirectoryAtURL:cacheDirectoryURL withIntermediateDirectories:YES attributes:attributes error:error];
}

+ (NSCache *)sharedCache {
    static NSCache *sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[NSCache alloc] init];
    });

    return sharedCache;
}

+ (NSURL *)cacheDirectoryURL {
    static NSURL *cacheDirectoryURL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *cachesDirectory = [NSFileManager.defaultManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
        cacheDirectoryURL = [cachesDirectory URLByAppendingPathComponent:@"CachedImages" isDirectory:YES];
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtURL:cacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error]) {
            MLCLog(@"Failed to create CachedImages directory: %@", error.localizedDescription);
        }
    });

    return cacheDirectoryURL;
}

- (NSString *)cacheKey {
    if (!_cacheKey) {
        NSString *string = [self.url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        _cacheKey = [output copy];
    }
    return _cacheKey;
}

- (NSURL *)cacheFileURL {
    if (!_cacheFileURL) {
        _cacheFileURL = [MLCImage.cacheDirectoryURL URLByAppendingPathComponent:self.cacheKey isDirectory:NO];
    }
    return _cacheFileURL;
}

- (void)loadImageData:(MLCImageDataCompletionHandler)handler {
    NSData *cachedData = [MLCImage.sharedCache objectForKey:self.cacheKey];
    if (cachedData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(cachedData, nil, nil);
        });
        return;
    }

    [self downloadImageData:handler];
}

- (void)downloadImageData:(MLCImageDataCompletionHandler)handler {
    NSString *key = self.cacheKey;
    NSCache *cache = MLCImage.sharedCache;
    NSURL *cacheFileURL = self.cacheFileURL;

    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [[MLCSessionManager.session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSHTTPURLResponse *httpResponse;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpResponse = (NSHTTPURLResponse *)response;
        }

        if (data) {
            [cache setObject:data forKey:key];
            [data writeToURL:cacheFileURL atomically:YES];
            handler(data, cacheFileURL, error);
        } else if (httpResponse.statusCode == 404 || httpResponse.statusCode == 200) {
            [cache removeObjectForKey:key];
            [NSFileManager.defaultManager removeItemAtURL:cacheFileURL error:nil];
            handler(nil, nil, error);
        } else {
            NSData *fallbackData = [NSData dataWithContentsOfURL:cacheFileURL];
            handler(fallbackData, cacheFileURL, error);
        }
    }] resume];
}

@end
