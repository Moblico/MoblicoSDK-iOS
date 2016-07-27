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
#import "MLCEntity_Private.h"

@interface MLCMedia ()
- (void)_mlc_loadImageDataFromURL:(NSURL *)url handler:(MLCMediaCompletionHandler)handler;
+ (NSCache *)_mlc_sharedCache;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@end

@implementation MLCMedia
@synthesize dataTask = __dataTask;

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

- (void)loadImageData:(MLCMediaCompletionHandler)handler {
    [self _mlc_loadImageDataFromURL:self.imageUrl handler:handler];
}

- (void)loadThumbData:(MLCMediaCompletionHandler)handler {
    [self _mlc_loadImageDataFromURL:self.thumbUrl handler:handler];
}

- (void)loadData:(MLCMediaCompletionHandler)handler {
    [self _mlc_loadImageDataFromURL:self.url handler:handler];
}

- (void)_mlc_loadImageDataFromURL:(NSURL *)url handler:(MLCMediaCompletionHandler)handler {
    NSString *key = [url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
    NSCache *cache = [self.class _mlc_sharedCache];
    NSData *cachedData = [cache objectForKey:key];
    if (cachedData) {
        handler(cachedData, nil, YES);
        return;
    }

    NSURLSession *session = [NSURLSession sharedSession];
    self.dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data) {
            [cache setObject:data forKey:key];
        }
        else {
            [cache removeObjectForKey:key];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data, error, NO);
        });
    }];
    [self.dataTask resume];
}

- (void)dealloc {
    [__dataTask cancel];
    __dataTask = nil;
}

@end
