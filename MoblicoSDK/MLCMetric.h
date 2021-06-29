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

#import "MLCEntity.h"

@class MLCLocation;

NS_ASSUME_NONNULL_BEGIN
/// Indicates the type of metric.
typedef NSString *MLCMetricType NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(MetricType);

/// Specifies that the application started.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeApplicationStart;

/// Specifies that the application has exited.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeApplicationStop;

/// Specifies that the application has been sent to the background.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeInBackground;

/// Specifies that the application has resumed from the background.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeOutBackground;

/// Specifies that the application has presented a view.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeEnterPage;

/// Specifies that the application has dismissed a view.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeExitPage;

/// Specifies that the user has interacted with an ad.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeAdClick;

/// Specifies that an action has been performed as a result of a user interacting with an ad.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeAdAction;

/// Specifies a generic tracking metric.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeTracking;

/// Specifies a custom metric used for triggers.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeCustom;

/// Specifies that the user has interacted with a deal.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewDeal;

/// Specifies that the user has interacted with a reward.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewReward;

/// Specifies that the user has interacted with a location.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewLocation;

/// Specifies that the user has interacted with an event.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewEvent;

/// Specifies that the user has interacted with a media.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewMedia;

/// Specifies that the user has shared the app.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeShareApp;

/// Specifies that the user has shared a deal.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeShareDeal;

/// Specifies that the user has shared a reward.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeShareReward;

/// Specifies that the user has shared a location.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeShareLocation;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeEnterGeoRegion;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeExitGeoRegion;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeEnterBeaconRegion;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeExitBeaconRegion;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeChangeGPS;


FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewProduct;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeShareProduct;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeOpenProduct;
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeExternalOpenProduct;

/// Specifies that the user has seen a promo.
FOUNDATION_EXPORT MLCMetricType const MLCMetricTypeViewPromo;

/**
 Moblico metrics provide a means for mobile applications to track and report
 usage by functional area. The Moblico platform has an in-depth reporting facility
 which enables querying on an application's feature set for helping
 to determine specific activity levels within an application.
 
 A MLCMetric object encapsulates the data of a metric which will be sent to Moblico.
 */
NS_SWIFT_NAME(Metric)
@interface MLCMetric : MLCEntity

/**
 The type for this metric. 
 
 @see MLCMetricType
 */
@property (copy, nonatomic) MLCMetricType type;

/**
 The text for this metric. (optional)
 
 Specify additional information about the metric i.e. screen name.
 */
@property (copy, nonatomic, nullable) NSString *text;

/**
 The username for this metric. (optional)
 */
@property (copy, nonatomic, nullable) NSString *username;


/**
 The MLCLocation for this metric. (optional)
 */
@property (strong, nonatomic, nullable) MLCLocation *location;
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
@property (nonatomic, strong, readonly) NSDate *timeStamp;

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
+ (nullable instancetype)metricWithType:(MLCMetricType)type text:(nullable NSString *)text location:(nullable MLCLocation *)location username:(nullable NSString *)username;

@end

NS_ASSUME_NONNULL_END
