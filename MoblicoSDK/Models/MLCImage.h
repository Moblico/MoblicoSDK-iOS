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

#import "MLCEntity.h"

/**
 A MLCImage object encapsulates the image data for a deal stored in the Moblico Admin Portal.
 */
@interface MLCImage : MLCEntity

/**
 A unique identifier for this image.
 */
@property (nonatomic) NSUInteger imageId;

/**
 The URL for this image.
 */
@property (strong, nonatomic) NSURL *url;

/**
 The date this image was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

/**
 The data of this image. Loaded asyncronously.
 */
@property (strong, nonatomic, readonly) NSData *data;

- (void)loadImageData;

@end
