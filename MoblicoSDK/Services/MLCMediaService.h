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

#import "MLCService.h"
@class MLCLocation;
@class MLCEvent;

/**
 The media facility provides the means to reference and provide dynamic meta data for any type of content required.

 Media is loaded and managed using Moblico's admin tool.
 */
@interface MLCMediaService : MLCService

/**
 This method is used to request a media item with a specified id.

 @param mediaId The identifier of the media you are requesting.
 @param handler The request completion handler.

 @return A MLCMediaService instance.

 @see -[MLCServiceProtocol start]
 */
+ (instancetype)readMediaWithMediaId:(NSUInteger)mediaId handler:(MLCServiceResourceCompletionHandler)handler;

/**
 This method requests all media.

 @param handler The request completion handler.
 */
+ (instancetype)listMedia:(MLCServiceCollectionCompletionHandler)handler;

/**
 This method requests all media for a specified location.

 @param location The MLCLocation instance that the media are assigned to.
 @param handler The request completion handler.
 */
+ (instancetype)listMediaForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler;

/**
 This method requests all media for a specified event.

 @param event The MLCEvent instance that the media are assigned to.
 @param handler The request completion handler.
 */
+ (instancetype)listMediaForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler;

/**
 This method requests all media for a specified generic resource.
 
 This is a generic method for requesting media that are assigned to another
 resource. For example, you can call this method with either a MLCEvent or
 MLCLocation instance as the resource.

 @param resource The resource that the media is assigned to.
 @param handler The request completion handler.
 */
+ (instancetype)listMediaForResource:(id <MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

@end
