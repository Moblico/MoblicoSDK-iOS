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

@import CoreLocation;

static NSString *const MLCMetricTypeApplicationStartString = @"Application_Start";
static NSString *const MLCMetricTypeApplicationStopString = @"Application_Stop";
static NSString *const MLCMetricTypeInBackgroundString = @"In_Background";
static NSString *const MLCMetricTypeOutBackgroundString = @"Out_Background";
static NSString *const MLCMetricTypeEnterPageString = @"Enter_Page";
static NSString *const MLCMetricTypeExitPageString = @"Exit_Page";
static NSString *const MLCMetricTypeAdClickString = @"Ad_Click";
static NSString *const MLCMetricTypeTrackingString = @"Tracking";
static NSString *const MLCMetricTypeCustomString = @"Custom";
static NSString *const MLCMetricTypeViewDealString = @"View_Deal";
static NSString *const MLCMetricTypeViewRewardString = @"View_Reward";
static NSString *const MLCMetricTypeViewLocationString = @"View_Location";
static NSString *const MLCMetricTypeViewEventString = @"View_Event";
static NSString *const MLCMetricTypeViewMediaString = @"View_Media";
static NSString *const MLCMetricTypeShareAppString = @"Share_App";
static NSString *const MLCMetricTypeShareDealString = @"Share_Deal";
static NSString *const MLCMetricTypeShareRewardString = @"Share_Reward";
static NSString *const MLCMetricTypeShareLocationString = @"Share_Location";
static NSString *const MLCMetricTypeEnterGeoRegionString = @"Enter_Geo_Region";
static NSString *const MLCMetricTypeExitGeoRegionString = @"Exit_Geo_Region";
static NSString *const MLCMetricTypeEnterBeaconRegionString = @"Enter_Beacon_Region";
static NSString *const MLCMetricTypeExitBeaconRegionString = @"Exit_Beacon_Region";
static NSString *const MLCMetricTypeChangeGPSString = @"Change_GPS";

@interface MLCMetric ()

@property (nonatomic, strong) NSDate *timeStamp;
+ (NSString *)stringForMetricType:(MLCMetricType)type;

@end

@implementation MLCMetric

+ (NSArray *)ignoredPropertiesDuringSerialization {
    NSArray *parentArray = [super ignoredPropertiesDuringSerialization];

    return [@[@"payload"] arrayByAddingObjectsFromArray:parentArray];
}

- (void)setPayload:(NSString *)payload {
    self.text = payload;
}

- (NSString *)payload {
    return self.text;
}

- (NSDate *)timeStamp {
    if (!_timeStamp) {
        _timeStamp = [NSDate date];
    }

    return _timeStamp;
}

+ (instancetype)metricWithType:(MLCMetricType)type payload:(NSString *)payload {
    return [self metricWithType:type text:payload location:nil username:nil];
}

+ (instancetype)metricWithType:(MLCMetricType)type text:(NSString *)text username:(NSString *)username {
    return [self metricWithType:type text:text location:nil username:username];
}

+ (instancetype)metricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location username:(NSString *)username {
    MLCMetric *metric = [[MLCMetric alloc] init];
    metric.type = type;
    metric.text = text;
    metric.username = username;
    metric.timeStamp = [NSDate date];
    metric.location = location;

    CLLocation *coreLocation = ([MLCMetricsManager sharedMetricsManager].locationDelegate).location;
    if (coreLocation) {
        metric.latitude = coreLocation.coordinate.latitude;
        metric.longitude = coreLocation.coordinate.longitude;
    }

    return metric;
}

+ (NSDictionary *)serialize:(MLCMetric *)metric {
    NSMutableDictionary *serializedObject = [[super serialize:metric] mutableCopy];
    
    NSString *type = [MLCMetric stringForMetricType:metric.type];
    serializedObject[@"type"] = type;

    [serializedObject removeObjectForKey:@"location"];
    NSUInteger locationId = metric.location.locationId;
    
    if (locationId > 0) {
        serializedObject[@"locationId"] = @(locationId);
    }

    NSString *latitude = @(metric.latitude).stringValue;
    latitude = [latitude substringToIndex:MIN((NSUInteger)16, latitude.length)];
    serializedObject[@"latitude"] = latitude;

    NSString *longitude = @(metric.longitude).stringValue;
    longitude = [longitude substringToIndex:MIN((NSUInteger)16, longitude.length)];
    serializedObject[@"longitude"] = longitude;
    
    return serializedObject;
}

+ (NSString *)stringForMetricType:(MLCMetricType)type {
    if (type == MLCMetricTypeApplicationStart) return MLCMetricTypeApplicationStartString;
    if (type == MLCMetricTypeApplicationStop) return MLCMetricTypeApplicationStopString;
    if (type == MLCMetricTypeInBackground) return MLCMetricTypeInBackgroundString;
    if (type == MLCMetricTypeOutBackground) return MLCMetricTypeOutBackgroundString;
    if (type == MLCMetricTypeEnterPage) return MLCMetricTypeEnterPageString;
    if (type == MLCMetricTypeExitPage) return MLCMetricTypeExitPageString;
    if (type == MLCMetricTypeAdClick) return MLCMetricTypeAdClickString;
    if (type == MLCMetricTypeTracking) return MLCMetricTypeTrackingString;
    if (type == MLCMetricTypeCustom) return MLCMetricTypeCustomString;
    if (type == MLCMetricTypeViewDeal) return MLCMetricTypeViewDealString;
    if (type == MLCMetricTypeViewReward) return MLCMetricTypeViewRewardString;
    if (type == MLCMetricTypeViewLocation) return MLCMetricTypeViewLocationString;
    if (type == MLCMetricTypeViewEvent) return MLCMetricTypeViewEventString;
    if (type == MLCMetricTypeViewMedia) return MLCMetricTypeViewMediaString;
    if (type == MLCMetricTypeShareApp) return MLCMetricTypeShareAppString;
    if (type == MLCMetricTypeShareDeal) return MLCMetricTypeShareDealString;
    if (type == MLCMetricTypeShareReward) return MLCMetricTypeShareRewardString;
    if (type == MLCMetricTypeShareLocation) return MLCMetricTypeShareLocationString;
    if (type == MLCMetricTypeEnterGeoRegion) return MLCMetricTypeEnterGeoRegionString;
    if (type == MLCMetricTypeExitGeoRegion) return MLCMetricTypeExitGeoRegionString;
    if (type == MLCMetricTypeEnterBeaconRegion) return MLCMetricTypeEnterBeaconRegionString;
    if (type == MLCMetricTypeExitBeaconRegion) return MLCMetricTypeExitBeaconRegionString;
    if (type == MLCMetricTypeChangeGPS) return MLCMetricTypeChangeGPSString;
    return nil;
}

@end
