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

#import "MLCMetricsService.h"
#import "MLCService_Private.h"

static NSString *const MLCMetricsServiceParameterType = @"type";
static NSString *const MLCMetricsServiceParameterText = @"text";
static NSString *const MLCMetricsServiceParameterLocation = @"location";
static NSString *const MLCMetricsServiceParameterUsername = @"username";

@implementation MLCMetricsService

static BOOL _enabled = YES;

+ (BOOL)isEnabled {
    return _enabled;
}

+ (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
}

+ (Class)classForResource {
    return Nil;
}

+ (void)sendMetric:(MLCMetric *)metric {
    if (self.isEnabled) {
        MLCMetricsService *service = [self createResource:metric handler:nil];
        [service start];
    }
}

+ (void)sendMetricWithType:(MLCMetricType)type {
    [self sendMetricWithParameters:@{MLCMetricsServiceParameterType: type}];
}

+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text {
    [self sendMetricWithParameters:@{MLCMetricsServiceParameterType: type, MLCMetricsServiceParameterText: text}];
}

+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location {
    [self sendMetricWithParameters:@{MLCMetricsServiceParameterType: type, MLCMetricsServiceParameterText: text, MLCMetricsServiceParameterLocation: location}];
}

+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text username:(NSString *)username {
    [self sendMetricWithParameters:@{MLCMetricsServiceParameterType: type, MLCMetricsServiceParameterText: text, MLCMetricsServiceParameterUsername: username}];
}

+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location username:(NSString *)username {
    [self sendMetricWithParameters:@{MLCMetricsServiceParameterType: type, MLCMetricsServiceParameterText: text, MLCMetricsServiceParameterLocation: location, MLCMetricsServiceParameterUsername: username}];
}

+ (void)sendMetricWithParameters:(NSDictionary *)parameters {
    [self sendMetric:[[MLCMetric alloc] initWithJSONObject:parameters]];
}

@end
