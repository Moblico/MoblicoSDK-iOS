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

@interface MLCMetric ()
@property (nonatomic, strong) NSDate *timeStamp;
+ (NSString *)stringForMetricType:(MLCMetricType)type;
@end

@implementation MLCMetric

- (NSDate *)timeStamp {
    if (!_timeStamp) {
        _timeStamp = [NSDate date];
    }
    return _timeStamp;
}

+ (id)metricWithType:(MLCMetricType)type payload:(NSString *)payload {
    MLCMetric * metric = [[MLCMetric alloc] init];
    metric.type = type;
    metric.payload = payload;
    metric.timeStamp = [NSDate date];
//    metric.latitude = latitude;
//    metric.longitude = longitude;
    return metric;
}

- (id)serialize {
    NSMutableDictionary *serializedObject = [[super serialize] mutableCopy];
    
    NSString *type = [MLCMetric stringForMetricType:self.type];
    serializedObject[@"type"] = type;

    return serializedObject;
}

+ (NSString *)stringForMetricType:(MLCMetricType)type {
    switch(type){
		case MLCMetricTypeApplicationStart:
			return @"Application_Start";
		case MLCMetricTypeApplicationStop:
			return @"Application_Stop";
		case MLCMetricTypeInBackground:
			return @"In_Background";
		case MLCMetricTypeOutBackground:
			return @"Out_Background";
		case MLCMetricTypeEnterPage:
			return @"Enter_Page";
		case MLCMetricTypeExitPage:
			return @"Exit_Page";
		case MLCMetricTypeAdClick:
			return @"Ad_Click";
		case MLCMetricTypeDealClick:
			return @"Deal_Click";
		case MLCMetricTypeTracking:
            return @"Tracking";
    }
    return nil;
}

@end
