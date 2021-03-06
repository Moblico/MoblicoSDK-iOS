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
#import <CoreGraphics/CoreGraphics.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IPHONE
typedef void(^MLCImageCompletionHandler)(UIImage *_Nullable image, NSError *_Nullable error) NS_SWIFT_NAME(MLCImage.CompletionHandler);
#elif TARGET_OS_OSX
typedef void(^MLCImageCompletionHandler)(NSImage *_Nullable image, NSError *_Nullable error) NS_SWIFT_NAME(MLCImage.CompletionHandler);
#else
typedef void(^MLCImageCompletionHandler)(NSData *_Nullable data, NSError *_Nullable error) NS_SWIFT_NAME(MLCImage.CompletionHandler);
#endif
typedef void(^MLCImageDownloadCompletionHandler)(NSURL *_Nullable location, NSError *_Nullable error) NS_SWIFT_NAME(MLCImage.DownloadCompletionHandler);

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
- (void)downloadImage:(MLCImageDownloadCompletionHandler)handler NS_SWIFT_NAME(download(_:));
#if TARGET_OS_IPHONE
@property (strong, nonatomic, readonly, nullable) UIImage *cachedImage;
#elif TARGET_OS_OSX
@property (strong, nonatomic, readonly, nullable) NSImage *cachedImage;
#else
@property (strong, nonatomic, readonly, nullable) NSData *cachedImage;
#endif

+ (BOOL)clearCache:(out NSError **)error;

- (nullable instancetype)initWithURLString:(NSString *)URLString;
- (nullable instancetype)initWithStringComponents:(NSString *)components;

@end

NS_ASSUME_NONNULL_END
