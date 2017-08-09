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

@import CoreLocation;
#import <MoblicoSDK/MLCService.h>

@class MLCLocation;
@class MLCEvent;

@interface MLCCheckInService : MLCService

+ (instancetype)checkInWithLocation:(MLCLocation *)location handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)checkInWithLocation:(MLCLocation *)location event:(MLCEvent *)event handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)checkInWithLocation:(MLCLocation *)location userLocation:(CLLocation *)userLocation beaconIdentifier:(NSString *)beaconIdentifier handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)checkInWithLocation:(MLCLocation *)location userLocation:(CLLocation *)userLocation beaconIdentifier:(NSString *)beaconIdentifier event:(MLCEvent *)event handler:(MLCServiceResourceCompletionHandler)handler;

@end
