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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_SWIFT_NAME(MLCMetricsManager.LocationDelegate)
@protocol MLCMetricsManagerLocationDelegate<NSObject>
@required
@property (nonatomic, readonly, copy, nullable) CLLocation *location;

@end

NS_SWIFT_NAME(MetricsManager)
@interface MLCMetricsManager : NSObject

@property (nonatomic, class, strong, readonly, nonnull) MLCMetricsManager *sharedMetricsManager;
@property (nonatomic, weak, nullable) id<MLCMetricsManagerLocationDelegate> locationDelegate;

@end
