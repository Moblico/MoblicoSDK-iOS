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

#import <MoblicoSDK/MLCService.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *MLCMediaServiceParameter NS_TYPED_ENUM NS_SWIFT_NAME(MLCMediaService.Parameter);
FOUNDATION_EXPORT MLCMediaServiceParameter const MLCMediaServiceParameterMediaType;
FOUNDATION_EXPORT MLCMediaServiceParameter const MLCMediaServiceParameterMediaTypeCategory;
FOUNDATION_EXPORT MLCMediaServiceParameter const MLCMediaServiceParameterCategory;

typedef NSDictionary<MLCMediaServiceParameter, id> * MLCMediaServiceParameters NS_SWIFT_NAME(MLCMediaService.Parameters);

@class MLCLocation;
@class MLCEvent;
@class MLCMedia;

MLCServiceCreateResourceCompletionHandler(MLCMediaService, MLCMedia);
MLCServiceCreateCollectionCompletionHandler(MLCMediaService, MLCMedia);

/**
 The media facility provides the means to reference and provide dynamic meta data for any type of content required.

 Media is loaded and managed using Moblico's admin tool.
 */
NS_SWIFT_NAME(MediaService)
@interface MLCMediaService : MLCService

/**
 This method is used to request a media item with a specified id.

 @param mediaId The identifier of the media you are requesting.
 @param handler The request completion handler.

 @return A MLCMediaService instance.

 @see -[MLCService start]
 */
+ (instancetype)readMediaWithMediaId:(NSUInteger)mediaId handler:(MLCMediaServiceResourceCompletionHandler)handler NS_SWIFT_NAME(readMedia(withId:handler:));

/**
 This method requests all media for the specified type and category.

 @param parameters Search parameters.
 @param handler The request completion handler.
 */
+ (instancetype)findMediaWithParameters:(MLCMediaServiceParameters)parameters handler:(MLCMediaServiceCollectionCompletionHandler)handler;

/**
 This method requests all media.

 @param handler The request completion handler.
 */
+ (instancetype)listMedia:(MLCMediaServiceCollectionCompletionHandler)handler;

/**
 This method requests all media for a specified location.

 @param location The MLCLocation instance that the media are assigned to.
 @param handler The request completion handler.
 */
+ (instancetype)listMediaForLocation:(MLCLocation *)location handler:(MLCMediaServiceCollectionCompletionHandler)handler;

+ (instancetype)findMediaForLocation:(MLCLocation *)location parameters:(MLCMediaServiceParameters)parameters handler:(MLCMediaServiceCollectionCompletionHandler)handler;

/**
 This method requests all media for a specified event.

 @param event The MLCEvent instance that the media are assigned to.
 @param handler The request completion handler.
 */
+ (instancetype)listMediaForEvent:(MLCEvent *)event handler:(MLCMediaServiceCollectionCompletionHandler)handler;


+ (instancetype)listMediaForMedia:(MLCMedia *)media handler:(MLCMediaServiceCollectionCompletionHandler)handler;

+ (instancetype)findMediaForMedia:(MLCMedia *)media parameters:(MLCMediaServiceParameters)parameters handler:(MLCMediaServiceCollectionCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
