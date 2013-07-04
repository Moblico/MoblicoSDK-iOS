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

@implementation MLCMetricsService

+ (Class<MLCEntityProtocol>)classForResource {
    return Nil;
}

+ (void)sendMetric:(MLCMetric *)metric {
    [[self createResource:metric handler:nil] start];
}

+ (void)sendMetricWithType:(MLCMetricType)type payload:(NSString *)payload {
    [self sendMetricWithType:type text:payload username:nil];
}

+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text username:(NSString *)username {
    MLCMetric *metric = [MLCMetric metricWithType:type text:text username:username];
    [self sendMetric:metric];
}

@end
