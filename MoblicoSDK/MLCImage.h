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

#import <MoblicoSDK/MLCEntity.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
typedef void(^MLCImageCompletionHandler)(UIImage *_Nullable image, NSError *_Nullable error, BOOL fromCache) NS_SWIFT_NAME(MLCImage.CompletionHandler);
#else
typedef void(^MLCImageCompletionHandler)(NSData *data, NSError *error, BOOL fromCache) NS_SWIFT_NAME(MLCImage.CompletionHandler);
#endif
/**
 A MLCImage object encapsulates the image data for a deal stored in 
 the Moblico Admin Portal.
 */
NS_SWIFT_NAME(Image)
@interface MLCImage : MLCEntity

/**
 A unique identifier for this image.
 */
@property (nonatomic) NSUInteger imageId NS_SWIFT_NAME(id);
@property (nonatomic) CGFloat scaleFactor;
/**
 The URL for this image.
 */
@property (strong, nonatomic) NSURL *url;

/**
 The date this image was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

- (void)loadImage:(MLCImageCompletionHandler)handler;
#if TARGET_OS_IOS
@property (strong, nonatomic, readonly, nullable) UIImage *cachedImage;
#else
@property (strong, nonatomic, readonly, nullable) NSData *cachedImage;
#endif

+ (BOOL)clearCache:(out NSError *_Nullable __autoreleasing *)error;

- (nullable instancetype)initWithURLString:(NSString *)URLString;
- (nullable instancetype)initWithStringComponents:(NSString *)components;

@end

NS_ASSUME_NONNULL_END
