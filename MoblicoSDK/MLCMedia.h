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

typedef void(^MLCMediaCompletionHandler)(NSData *data, NSError *error, BOOL fromCache) NS_SWIFT_NAME(MLCMedia.CompletionHandler);

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
@property (copy, nonatomic) NSString *type;

/**
 The name for this media.
 */
@property (copy, nonatomic) NSString *name;

/**
 The details for this media.
 */
@property (copy, nonatomic) NSString *details;

/**
 The URL for this media.
 */
@property (strong, nonatomic) NSURL *url;

/**
 The image URL for this media.
 */
@property (strong, nonatomic) NSURL *imageUrl;

/**
 The attributes for this media.
 */
@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *attributes;

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
@property (copy, nonatomic) NSURL *thumbUrl;

/**
 The external unique identifier for this media.
 
 The externalId will be set when the media originates from an external system to Moblico.
 */
@property (copy, nonatomic) NSString *externalId;

- (void)loadImageData:(MLCMediaCompletionHandler)handler;
@property (strong, nonatomic, readonly) NSData *cachedImageData;
- (void)loadThumbData:(MLCMediaCompletionHandler)handler;
@property (strong, nonatomic, readonly) NSData *cachedThumbData;
- (void)loadData:(MLCMediaCompletionHandler)handler;
@property (strong, nonatomic, readonly) NSData *cachedData;

@end
