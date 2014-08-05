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

@interface MLCImage ()

@property (strong, nonatomic, readwrite) NSData *data;
@property (nonatomic, strong) NSString *path;

@end

@implementation MLCImage

+ (instancetype)deserializeFromString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@";"];
    if (components.count != 3) {
        return nil;
    }
    NSString *imageId = components[0];
    NSString *url = components[1];
    NSString *lastUpdateDate = components[2];

    return [self deserialize:@{@"id": imageId, @"url": url, @"lastUpdateDate": lastUpdateDate}];
}

- (void)loadImageData {
    if (self.data) {
//        [self didChangeValueForKey:NSStringFromSelector(@selector(data))];
        self.data = self.data;
        return;
    }

    dispatch_queue_t currentQueue = dispatch_get_main_queue();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *image = [[NSData alloc] initWithContentsOfFile:self.path];

        if (!image) {
            image = [[NSData alloc] initWithContentsOfURL:self.url];
        }

        [image writeToFile:self.path atomically:YES];
        dispatch_async(currentQueue, ^{
            if (image) {
                self.data = image;
            } else {
                self.data = [NSData data];
            }
        });
    });
}

- (NSString *)path {
    if (_path) return _path;


    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([searchPaths count] == 0) return nil;
    NSString *docDir = [searchPaths[0] stringByAppendingPathComponent:@"CachedImages"];

    if (![[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil]) {
        return nil;
    }

    NSString *fileName = [NSString stringWithFormat:@"%.0F-%@", [self.lastUpdateDate timeIntervalSince1970], @(self.imageId)];
    if (!self.imageId) {
        fileName = [@([self.url.absoluteString hash]) stringValue];
    }
    _path = [docDir stringByAppendingPathComponent:fileName];

    return _path;
}

@end
