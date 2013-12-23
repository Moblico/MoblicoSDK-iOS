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

- (void)loadImageData {
    if (self.data) {
        self.data = self.data;
        return;
    }

    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
//        sleep(5);
        NSData *image = [[NSData alloc] initWithContentsOfFile:self.path];
        if (!image) {
            image = [[NSData alloc] initWithContentsOfURL:self.url];
        }

        [image writeToFile:self.path atomically:YES];
        dispatch_async(currentQueue, ^{
            if (image) {
                self.data = image;
            }
            else {
                self.data = [NSData data];
            }
        });
    });
}


- (NSString *)path {
    if (!_path) {
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (![searchPaths count]) return nil;
        NSString *docDir = [searchPaths[0] stringByAppendingPathComponent:@"CachedImages"];

        NSFileManager * fileManager = [NSFileManager defaultManager];
        if (![fileManager createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil]) {
            return nil;
        }

        _path = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0F-%@", [self.lastUpdateDate timeIntervalSince1970], @(self.imageId)]];
    }
    return _path;
}

@end
