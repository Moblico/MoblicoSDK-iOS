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

#import "MLCLocation.h"

@implementation MLCLocation

//@property (nonatomic, copy) NSString *geoEnterNotificationText;
//@property (nonatomic, strong) CLCircularRegion *geoFenceRegion;
//@property (nonatomic) CLLocationDistance geoFenceRadius;
//@property (nonatomic) BOOL checkinEnabled;
//@property (nonatomic) CLLocationDistance checkinRadius;

//@property (nonatomic, copy) NSString *beaconEnterNotificationText;
//@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
//@property (nonatomic) CLProximity beaconDesiredProximity;
//@property (nonatomic) CLProximity beaconLastProximity;
//@property (nonatomic) CLProximity beaconMinimumCheckInProximity;

#if TARGET_OS_IOS
+ (CLProximity)proximityFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return CLProximityUnknown;

    NSString *uppercaseString = string.uppercaseString;
    if ([uppercaseString isEqualToString:@"NEAR"]) return CLProximityNear;
    if ([uppercaseString isEqualToString:@"FAR"]) return CLProximityFar;
    if ([uppercaseString isEqualToString:@"IMMEDIATE"]) return CLProximityImmediate;

    return CLProximityUnknown;
}
#endif

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super initWithJSONObject:jsonObject];
    if (self) {
        if (_attributes == nil) {
            _attributes = @{};
        }

        NSString *identifier = [NSString stringWithFormat:@"%@-LOCATION", @(_locationId)];

        if ([jsonObject[@"geoNotificationEnabled"] boolValue]) {
            NSString *geoIdentifier = [identifier stringByAppendingFormat:@"-%@,%@,%@", @(_latitude), @(_longitude), @(_geoFenceRadius)];
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_latitude, _longitude);
            _geoFenceRegion = [[CLCircularRegion alloc] initWithCenter:center
                                                                radius:_geoFenceRadius
                                                            identifier:geoIdentifier];
            _geoFenceRegion.notifyOnEntry = YES;
            _geoFenceRegion.notifyOnExit = YES;
        }

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
        if ([jsonObject[@"beaconNotificationEnabled"] boolValue]) {
            NSString *beaconIdentifier = jsonObject[@"beaconIdentifier"];
            NSArray<NSString *> *beacon = [beaconIdentifier componentsSeparatedByString:@","];
            beaconIdentifier = [identifier stringByAppendingFormat:@"-%@", beaconIdentifier];

            if (beacon.count > 0) {
                CLBeaconRegion *region;
                NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:beacon[0]];
                if (beacon.count > 1) {
                    CLBeaconMajorValue majorValue = (CLBeaconMajorValue)beacon[1].integerValue;
                    if (beacon.count > 2) {
                        CLBeaconMajorValue minorValue = (CLBeaconMajorValue)beacon[2].integerValue;
                        region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:majorValue minor:minorValue identifier:beaconIdentifier];
                    } else {
                        region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:majorValue identifier:beaconIdentifier];
                    }
                } else {
                    region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:beaconIdentifier];
                }
                region.notifyEntryStateOnDisplay = YES;
                region.notifyOnEntry = YES;
                region.notifyOnExit = YES;
                _beaconRegion = region;
            }

            _beaconDesiredProximity = [[self class] proximityFromString:jsonObject[@"beaconRange"]];
            _beaconMinimumCheckInProximity = [[self class] proximityFromString:jsonObject[@"checkinRange"]];
            _beaconLastProximity = CLProximityUnknown;
        }
#endif

    }
    return self;
}

- (NSComparisonResult)compare:(MLCLocation *)location order:(MLCLocationCompareOrder)order {
    NSComparisonResult distance = [@(self.distance) compare:@(location.distance)];
    NSComparisonResult name = [self.name localizedStandardCompare:location.name];

    if (order == MLCLocationCompareOrderDistance) {
        return distance ?: name;
    }

    // order == MLCLocationCompareOrderName
    return name ?: distance;
}

- (NSComparisonResult)compare:(MLCLocation *)location {
    return [self compare:location order:MLCLocationCompareOrderDistance];
}


@end
