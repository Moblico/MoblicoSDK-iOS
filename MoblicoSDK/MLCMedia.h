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
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IOS
typedef void(^MLCMediaImageCompletionHandler)(UIImage *_Nullable image, NSError *_Nullable error, BOOL fromCache) NS_SWIFT_NAME(MLCMedia.ImageCompletionHandler);
#else
typedef void(^MLCMediaImageCompletionHandler)(NSData *_Nullable data, NSError *_Nullable error, BOOL fromCache) NS_SWIFT_NAME(MLCMedia.ImageCompletionHandler);
#endif

typedef void(^MLCMediaDataCompletionHandler)(NSData *_Nullable data, NSError *_Nullable error, BOOL fromCache) NS_SWIFT_NAME(MLCMedia.DataCompletionHandler);

/**
 The media facility provides the means to reference and provide dynamic meta data
 for any type of content required.
 
 Media is loaded and managed using Moblico's admin tool.
 
 A MLCMedia object encapsulates the data of a media stored in the Moblico Admin Portal.
 */
NS_SWIFT_NAME(Media)
@interface MLCMedia : MLCEntity

/**
 A unique identifier for this media.
 */
@property (nonatomic) NSUInteger mediaId NS_SWIFT_NAME(id);

/**
 The date this media was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date this media was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

/**
 The MIME type for this media.
 */
@property (copy, nonatomic) NSString *mimeType;

/**
 The type for this media.
 */
@property (copy, nonatomic, nullable) NSString *type;

/**
 The name for this media.
 */
@property (copy, nonatomic) NSString *name;

/**
 The details for this media.
 */
@property (copy, nonatomic, nullable) NSString *details;

/**
 The URL for this media.
 */
@property (strong, nonatomic) NSURL *url;

/**
 The image URL for this media.
 */
@property (strong, nonatomic, nullable) NSURL *imageUrl;

/**
 The attributes for this media.
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSString *> *attributes;

/**
 The sorting priority for this media.
 */
@property (nonatomic) NSUInteger priority;

/**
 Specifies whether this media should be cached.
 */
@property (nonatomic) BOOL shouldCache;

/**
 The thumbnail image URL for this media.
 */
@property (copy, nonatomic, nullable) NSURL *thumbUrl;

/**
 The external unique identifier for this media.
 
 The externalId will be set when the media originates from an external system to Moblico.
 */
@property (copy, nonatomic, nullable) NSString *externalId;

#if TARGET_OS_IOS
- (void)loadImage:(MLCMediaImageCompletionHandler)handler;
@property (strong, nonatomic, readonly, nullable) UIImage *cachedImage;
- (void)loadThumb:(MLCMediaImageCompletionHandler)handler;
@property (strong, nonatomic, readonly, nullable) UIImage *cachedThumb;
#else
- (void)loadImage:(MLCMediaDataCompletionHandler)handler;
@property (strong, nonatomic, readonly, nullable) NSData *cachedImage;
- (void)loadThumb:(MLCMediaDataCompletionHandler)handler;
@property (strong, nonatomic, readonly, nullable) NSData *cachedThumb;
#endif

- (void)loadData:(MLCMediaDataCompletionHandler)handler;
@property (strong, nonatomic, readonly, nullable) NSData *cachedData;

+ (BOOL)clearCache:(out NSError *_Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
