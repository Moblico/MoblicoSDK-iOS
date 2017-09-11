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

+ (CLProximity)proximityFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return CLProximityUnknown;

    NSString *uppercaseString = string.uppercaseString;
    if ([uppercaseString isEqualToString:@"NEAR"]) return CLProximityNear;
    if ([uppercaseString isEqualToString:@"FAR"]) return CLProximityFar;
    if ([uppercaseString isEqualToString:@"IMMEDIATE"]) return CLProximityImmediate;

    return CLProximityUnknown;
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super initWithJSONObject:jsonObject];
    if (self) {
        if (_attributes == nil) {
            _attributes = @{};
        }
        
        NSString *identifier = [NSString stringWithFormat:@"%@-LOCATION", @(_locationId)];

        if ([jsonObject[@"geoNotificationEnabled"] boolValue]) {
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_latitude, _longitude);
            _geoFenceRegion = [[CLCircularRegion alloc] initWithCenter:center
                                                                radius:_geoFenceRadius
                                                            identifier:identifier];
            _geoFenceRegion.notifyOnEntry = YES;
            _geoFenceRegion.notifyOnExit = YES;
        }
        if ([jsonObject[@"beaconNotificationEnabled"] boolValue]) {
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

            _beaconDesiredProximity = [[self class] proximityFromString:jsonObject[@"beaconRange"]];
            _beaconMinimumCheckInProximity = [[self class] proximityFromString:jsonObject[@"checkinRange"]];
            _beaconLastProximity = CLProximityUnknown;
        }

    }
    return self;
}

- (NSComparisonResult)compare:(MLCLocation *)location order:(MLCLocationCompareOrder)order {
    NSComparisonResult distance = [@(self.distance) compare:@(location.distance)];
    NSComparisonResult name = [self.name localizedStandardCompare:location.name];

    if (order == MLCLocationCompareOrderDistance) {
        return distance ?: name;
    }

    return name ?: distance;
}

- (NSComparisonResult)compare:(MLCLocation *)location {
    return [self compare:location order:MLCLocationCompareOrderDistance];
}


@end
