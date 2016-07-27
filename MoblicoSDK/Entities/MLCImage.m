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
@interface MLCImage ()

@property (strong, nonatomic, readwrite) NSData *data;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@end

@implementation MLCImage
@synthesize dataTask = __dataTask;

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
//        [self didChangeValueForKey:NSStringFromSelector(@selector(data))];
        self.data = self.data;
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = self.path;
        NSData *image;

        if (path) {
            image = [[NSData alloc] initWithContentsOfFile:path];
        }

        if (!image && self.url) {
            image = [[NSData alloc] initWithContentsOfURL:self.url];
        }

        if (path) {
            [image writeToFile:path atomically:YES];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                self.data = image;
            } else {
                self.data = [NSData data];
            }
        });
    });
}

- (void)loadImageData:(MLCImageCompletionHandler)handler {
    return [self _mlc_loadImageDataFromURL:self.url handler:handler];
//    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
//    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:currentQueue
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data,
//                                               NSError *connectionError) {
//                               handler(data, connectionError, NO);
//                           }];

}

+ (NSCache *)_mlc_sharedCache {
    static NSCache *sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[NSCache alloc] init];
    });

    return sharedCache;
}

- (void)_mlc_loadImageDataFromURL:(NSURL *)url handler:(MLCImageCompletionHandler)handler {
    NSString *key = [url.absoluteString stringByAppendingFormat:@"|%@", self.lastUpdateDate];
    NSCache *cache = [self.class _mlc_sharedCache];
    NSData *cachedData = [cache objectForKey:key];
    CGFloat scale = self.scaleFactor;
    if (cachedData) {
        handler(cachedData, nil, YES, scale);
        return;
    }

    self.dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            [cache setObject:data forKey:key];
        }
        else {
            [cache removeObjectForKey:key];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data, error, NO, scale);
        });
    }];
    [self.dataTask resume];
}

- (void)dealloc {
    [__dataTask cancel];
    __dataTask = nil;
}

- (NSString *)path {
    if (_path) return _path;


    NSString *searchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    if (!searchPath) return nil;
    NSString *docDir = [searchPath stringByAppendingPathComponent:@"CachedImages"];

    if (![[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil]) {
        return nil;
    }

    NSString *fileName = [NSString stringWithFormat:@"%.0F-%@", (self.lastUpdateDate).timeIntervalSince1970, @(self.imageId)];
    if (!self.imageId) {
        fileName = (@((self.url.absoluteString).hash)).stringValue;
    }
    _path = [docDir stringByAppendingPathComponent:fileName];

    return _path;
}

@end
