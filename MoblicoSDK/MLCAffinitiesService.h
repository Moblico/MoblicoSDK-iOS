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

@class MLCLocation;
@class MLCAffinity;

MLCServiceCreateCollectionCompletionHandler(MLCAffinitiesService, MLCAffinity);

/**
 Moblico affinity facilitates a points plus rewards system.
 The Moblico admin portal provides the means to define actions
 for the affinity engine to process.
 
 Please see the Moblico admin portal for more information concerning
 affinity setup and usage including how to setup your own unique rewards.
 
 Use the MLCAffinitiesService class to retrieve affinities from the Moblico Admin Portal.
 */
NS_SWIFT_NAME(AffinitiesService)
@interface MLCAffinitiesService : MLCService

/**
 This method creates a service that retrieves the list of affinities
 that are currently available via the Moblico admin portal.

 @param handler Completion handler.

 @return A MLCAffinitiesService instance which conforms to MLCServiceProtocol.
 */
+ (instancetype)listAffinities:(MLCAffinitiesServiceCollectionCompletionHandler)handler;

/**
 This method creates a service that retrieves the list of affinities
 for a specific location that are currently available via the Moblico admin portal.

 @param location Location for affinities.
 @param handler Completion handler.
 @return A MLCAffinitiesService instance which conforms to the MLCServiceProtocol protocol.
 */
+ (instancetype)listAffinitiesForLocation:(MLCLocation *)location handler:(MLCAffinitiesServiceCollectionCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
