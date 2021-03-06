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

#import "MLCService.h"
#import "MLCMetric.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Moblico metrics provide a means for mobile applications to track and report
 usage by functional area. The Moblico platform has an in-depth reporting facility
 which enables querying on an application's feature set for helping to determine
 specific activity levels within an application. 
 
 Use the MLCMetricsService to send an MLCMetric to Moblico.
 */
NS_SWIFT_NAME(MetricsService)
@interface MLCMetricsService : MLCService

@property (nonatomic, class, getter=isEnabled) BOOL enabled;

#pragma mark Send a Metric
///--------------------
/// @name Send a Metric
///--------------------

/**
 Creates an automatically running service that sends a metric to Moblico.

 @param metric The MLCMetric which is sent to Moblico.
 */
+ (void)sendMetric:(MLCMetric *)metric;

/**
 Creates an automatically running service that sends an automatically created
 metric to Moblico.

 @param type The type of metric which is created.
 */
+ (void)sendMetricWithType:(MLCMetricType)type;

/**
 Creates an automatically running service that sends an automatically created
 metric to Moblico.

 @param type The type of metric which is created.
 @param text Additional data include with the metric.
 */
+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text;

/**
 Creates an automatically running service that sends an automatically created
 metric to Moblico.

 @param type The type of metric which is created.
 @param text Additional data include with the metric.
 @param location The location include with the metric.
 */
+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location;

/**
 Creates an automatically running service that sends an automatically created
 metric to Moblico.

 @param type The type of metric which is created.
 @param text Additional data include with the metric.
 @param username The username include with the metric.
 */
+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text username:(NSString *)username;

/**
 Creates an automatically running service that sends an automatically created
 metric to Moblico.

 @param type The type of metric which is created.
 @param text Additional data include with the metric.
 @param location The location include with the metric.
 @param username The username include with the metric.
 */
+ (void)sendMetricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location username:(NSString *)username;

@end

NS_ASSUME_NONNULL_END
