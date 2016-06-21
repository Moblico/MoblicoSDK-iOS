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

#import <MoblicoSDK/MLCEntity.h>
@class MLCLocation;

/**
 Indicates the type of metric.
 */
typedef NS_ENUM(NSUInteger, MLCMetricType) {
    /// Specifies that the application started.
    MLCMetricTypeApplicationStart,

    /// Specifies that the application has exited.
    MLCMetricTypeApplicationStop,

    /// Specifies that the application has been sent to the background.
    MLCMetricTypeInBackground,

    /// Specifies that the application has resumed from the background.
    MLCMetricTypeOutBackground,

    /// Specifies that the application has presented a view.
    MLCMetricTypeEnterPage,

    /// Specifies that the application has dismissed a view.
    MLCMetricTypeExitPage,

    /// Specifies that the user has interacted an ad.
    MLCMetricTypeAdClick,

    /// Specifies a generic tracking metric.
    MLCMetricTypeTracking,

    /// Specifies a custom metric used for triggers.
    MLCMetricTypeCustom,

	/// Specifies that the user has interacted with a deal.
    MLCMetricTypeViewDeal,

	/// Specifies that the user has interacted with a reward.
    MLCMetricTypeViewReward,

	/// Specifies that the user has interacted with a location.
    MLCMetricTypeViewLocation,

	/// Specifies that the user has interacted with an event.
    MLCMetricTypeViewEvent,

	/// Specifies that the user has interacted with a media.
    MLCMetricTypeViewMedia,

	/// Specifies that the user has shared the app.
    MLCMetricTypeShareApp,

	/// Specifies that the user has shared a deal.
    MLCMetricTypeShareDeal,

	/// Specifies that the user has shared a reward.
    MLCMetricTypeShareReward,

    /// Specifies that the user has shared a location.
    MLCMetricTypeShareLocation,
    MLCMetricTypeEnterGeoRegion,
    MLCMetricTypeExitGeoRegion,
    MLCMetricTypeEnterBeaconRegion,
    MLCMetricTypeExitBeaconRegion,
    MLCMetricTypeChangeGPS,
};

/**
 Moblico metrics provide a means for mobile applications to track and report
 usage by functional area. The Moblico platform has an in-depth reporting facility
 which enables querying on an application's feature set for helping
 to determine specific activity levels within an application.
 
 A MLCMetric object encapsulates the data of a metric which will be sent to Moblico.
 */
@interface MLCMetric : MLCEntity

/**
 The type for this metric. 
 
 @see MLCMetricType
 */
@property (nonatomic) MLCMetricType type;

/**
 The text for this metric. (optional)
 
 Specify additional information about the metric i.e. screen name.
 */
@property (strong, nonatomic) NSString *text;

/**
 The username for this metric. (optional)
 */
@property (strong, nonatomic) NSString *username;


/**
 The MLCLocation for this metric. (optional)
 */
@property (strong, nonatomic) MLCLocation *location;
/**
 The latitude for this metric. (optional)
 */
@property (nonatomic) double latitude;

/**
 The longitude for this metric. (optional)
 */
@property (nonatomic) double longitude;

/**
 The time stamp representing when this metric was created.
 
 This time stamp will be automatically populated if you use the
 convenience class method metricWithType:text:username:.
 */
@property (nonatomic, readonly) NSDate *timeStamp;

/**
 Convenience class method to create a MLCMetric object with the provided parameters.
 
 The timeStamp property for the metric will be automatically populated when using this method.

 @param type The MLCMetricType for this metric.
 @param text The text for this metric. (optional)
 @param location The MLCLocation for this metric. (optional)
 @param username The username for this metric. (optional)

 @return A MLCMetric object to use with +[MLCMetricsService sendMetric:].

 @see +[MLCMetricsService sendMetric:]
 */
+ (instancetype)metricWithType:(MLCMetricType)type text:(NSString *)text location:(MLCLocation *)location username:(NSString *)username;

@end

@interface MLCMetric (Deprecated)

/**
 This method is no longer used,
 and will be removed in the next major release.

 @deprecated Use 'metricWithType:text:location:username:' instead.

 @see +metricWithType:text:location:username:
 */
+ (instancetype)metricWithType:(MLCMetricType)type text:(NSString *)text username:(NSString *)username __attribute__((deprecated ("Use 'metricWithType:text:location:username:' instead.")));

/**
 This method is no longer used,
 and will be removed in the next major release.

 @deprecated Use 'metricWithType:text:location:username:' instead.

 @see +metricWithType:text:location:username:
 */
+ (instancetype)metricWithType:(MLCMetricType)type payload:(NSString *)payload __attribute__((deprecated ("Use 'metricWithType:text:location:username:' instead.")));

/**
 The payload property has been renamed to text,
 and will be removed in the next major release.

 @deprecated Use 'text' instead.

 @see text
 */
@property (strong, nonatomic) NSString *payload __attribute__((deprecated ("Use 'text' instead.")));

@end
