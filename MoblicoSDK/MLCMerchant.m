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

#import "MLCMerchant.h"

@implementation MLCMerchant

- (instancetype)initWithJSONObject:(NSDictionary<NSString *, id> *)jsonObject {
    self = [super initWithJSONObject:jsonObject];
    if (self) {
        if (_attributes == nil) {
            _attributes = @{};
        }

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
        if ([jsonObject[@"beaconRegionEnabled"] boolValue]) {
            NSString *identifier = [NSString stringWithFormat:@"%@-MERCHANT", @(_merchantId)];
            NSArray<NSString *> *beacon = [jsonObject[@"beaconIdentifier"] componentsSeparatedByString:@","];

            if (beacon.count > 0) {
                CLBeaconRegion *region;
                NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:beacon[0]];
                if (beacon.count > 1) {
                    CLBeaconMajorValue majorValue = (CLBeaconMajorValue)beacon[1].integerValue;
                    if (beacon.count > 2) {
                        CLBeaconMajorValue minorValue = (CLBeaconMajorValue)beacon[2].integerValue;
                        region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:majorValue minor:minorValue identifier:identifier];
                    } else {
                        region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:majorValue identifier:identifier];
                    }
                } else {
                    region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
                }
                region.notifyEntryStateOnDisplay = YES;
                region.notifyOnEntry = YES;
                region.notifyOnExit = YES;
                _beaconRegion = region;
            }
        }
#endif

    }
    return self;
}

@end
