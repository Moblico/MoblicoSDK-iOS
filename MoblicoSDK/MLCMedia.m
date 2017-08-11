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
- (void)_mlc_loadImageDataFromURL:(NSURL *)url handler:(MLCMediaCompletionHandler)handler;
+ (NSCache *)_mlc_sharedCache;
@end

@implementation MLCMedia

+ (NSString *)collectionName {
    return @"media";
}

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"data", @"dataTask"];
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
        cacheDirectory = [searchPath stringByAppendingPathComponent:@"CachedMedia"];
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            MLCDebugLog(@"Failed to create CachedMedia directory: %@", error.localizedDescription);
        }
    });

    return cacheDirectory;
}

- (void)loadImageData:(MLCMediaCompletionHandler)handler {
    [self _mlc_loadImageDataFromURL:self.imageUrl handler:handler];
}

- (NSData *)cachedImageData {
    return [self _mlc_cachedImageDataFromURL:self.imageUrl];
}

- (void)loadThumbData:(MLCMediaCompletionHandler)handler {
    [self _mlc_loadImageDataFromURL:self.thumbUrl handler:handler];
}

- (NSData *)cachedThumbData {
    return [self _mlc_cachedImageDataFromURL:self.thumbUrl];
}

- (void)loadData:(MLCMediaCompletionHandler)handler {
    [self _mlc_loadImageDataFromURL:self.url handler:handler];
}

- (NSData *)cachedData {
    return [self _mlc_cachedImageDataFromURL:self.url];
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

    return [[[self class] _mlc_cacheDirectory] stringByAppendingPathComponent:fileName];
}

- (NSString *)_mlc_keyForURL:(NSURL *)url {
    return [url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
}

- (void)_mlc_loadImageDataFromURL:(NSURL *)url handler:(MLCMediaCompletionHandler)handler {
    NSString *key = [self _mlc_keyForURL:url];
    NSCache *cache = [[self class] _mlc_sharedCache];
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
        } else {
            NSData *fallbackData = [NSData dataWithContentsOfFile:cachedPath];
            handler(fallbackData, error, NO);
        }
    }];
}

- (NSData *)_mlc_cachedImageDataFromURL:(NSURL *)url {
    return [NSData dataWithContentsOfFile:[self cachedPath:[self _mlc_keyForURL:url]]];
}

@end
