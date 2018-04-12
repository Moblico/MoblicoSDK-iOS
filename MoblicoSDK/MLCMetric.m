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

#import "MLCMetric.h"
#import "MLCLocation.h"
#import "MLCEntity_Private.h"
#import "MLCMetricsManager.h"

#import <CoreLocation/CoreLocation.h>

MLCMetricType const MLCMetricTypeApplicationStart = @"Application_Start";
MLCMetricType const MLCMetricTypeApplicationStop = @"Application_Stop";
MLCMetricType const MLCMetricTypeInBackground = @"In_Background";
MLCMetricType const MLCMetricTypeOutBackground = @"Out_Background";
MLCMetricType const MLCMetricTypeEnterPage = @"Enter_Page";
MLCMetricType const MLCMetricTypeExitPage = @"Exit_Page";
MLCMetricType const MLCMetricTypeAdClick = @"Ad_Click";
MLCMetricType const MLCMetricTypeTracking = @"Tracking";
MLCMetricType const MLCMetricTypeCustom = @"Custom";
MLCMetricType const MLCMetricTypeViewDeal = @"View_Deal";
MLCMetricType const MLCMetricTypeViewReward = @"View_Reward";
MLCMetricType const MLCMetricTypeViewLocation = @"View_Location";
MLCMetricType const MLCMetricTypeViewEvent = @"View_Event";
MLCMetricType const MLCMetricTypeViewMedia = @"View_Media";
MLCMetricType const MLCMetricTypeShareApp = @"Share_App";
MLCMetricType const MLCMetricTypeShareDeal = @"Share_Deal";
MLCMetricType const MLCMetricTypeShareReward = @"Share_Reward";
MLCMetricType const MLCMetricTypeShareLocation = @"Share_Location";
MLCMetricType const MLCMetricTypeEnterGeoRegion = @"Enter_Geo_Region";
MLCMetricType const MLCMetricTypeExitGeoRegion = @"Exit_Geo_Region";
MLCMetricType const MLCMetricTypeEnterBeaconRegion = @"Enter_Beacon_Region";
MLCMetricType const MLCMetricTypeExitBeaconRegion = @"Exit_Beacon_Region";
MLCMetricType const MLCMetricTypeChangeGPS = @"Change_GPS";
MLCMetricType const MLCMetricTypeViewProduct = @"View_Product";
MLCMetricType const MLCMetricTypeShareProduct = @"Share_Product";
MLCMetricType const MLCMetricTypeOpenProduct = @"Open_Product";
MLCMetricType const MLCMetricTypeExternalOpenProduct = @"External_Open_Product";
MLCMetricType const MLCMetricTypeViewPromo = @"View_Promo";

@interface MLCMetric ()

@property (nonatomic, strong, readwrite) NSDate *timeStamp;

@end

@implementation MLCMetric

+ (NSArray *)ignoredPropertiesDuringSerialization {
    NSArray *parentArray = [super ignoredPropertiesDuringSerialization];

    return [@[@"payload"] arrayByAddingObjectsFromArray:parentArray];
}

- (NSDate *)timeStamp {
    if (!_timeStamp) {
        _timeStamp = [NSDate date];
    }

    return _timeStamp;
}
- (instancetype)initWithJSONObject:(NSDictionary<NSString *,id> *)jsonObject {
    self = [super initWithJSONObject:jsonObject];
    if (self) {
        CLLocation *coreLocation = MLCMetricsManager.sharedMetricsManager.locationDelegate.location;
        if (coreLocation) {
            _timeStamp = [NSDate date];
            _latitude = coreLocation.coordinate.latitude;
            _longitude = coreLocation.coordinate.longitude;
        }
    }
    return self;
}

+ (instancetype)metricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location username:(NSString *)username {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    jsonObject[@"type"] = type;
    jsonObject[@"text"] = text;
    jsonObject[@"location"] = location;
    jsonObject[@"username"] = username;
    return [[self alloc] initWithJSONObject:jsonObject];
}

+ (NSDictionary *)serialize:(MLCMetric *)metric {
    NSMutableDictionary *serializedObject = [[super serialize:metric] mutableCopy];

    serializedObject[@"type"] = metric.type;

    [serializedObject removeObjectForKey:@"location"];
    NSUInteger locationId = metric.location.locationId;

    if (locationId > 0) {
        serializedObject[@"locationId"] = @(locationId);
    }

    NSUInteger maxLength = 16;
    NSString *latitude = @(metric.latitude).stringValue;
    latitude = [latitude substringToIndex:MIN(maxLength, latitude.length)];
    serializedObject[@"latitude"] = latitude;

    NSString *longitude = @(metric.longitude).stringValue;
    longitude = [longitude substringToIndex:MIN(maxLength, longitude.length)];
    serializedObject[@"longitude"] = longitude;

    return serializedObject;
}

@end
