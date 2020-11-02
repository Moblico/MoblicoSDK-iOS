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
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Merchant)
@interface MLCMerchant : MLCEntity

@property (nonatomic) NSUInteger merchantId NS_SWIFT_NAME(id);
@property (copy, nonatomic, nullable) NSString *externalId;
@property (nonatomic) NSUInteger ownerUserId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic, nullable) NSString *redemptionType;
@property (copy, nonatomic) NSString *status;
@property (strong, nonatomic) NSDate *lastUpdateDate;

#if TARGET_OS_IOS
@property (nonatomic) BOOL beaconRegionEnabled;
@property (copy, nonatomic, nullable) NSString *beaconIdentifier;
@property (copy, nonatomic, nullable) NSString *beaconEnterNotificationText;
@property (nonatomic, strong, nullable) CLBeaconRegion *beaconRegion;
#endif

@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *attributes;

@end

NS_ASSUME_NONNULL_END
