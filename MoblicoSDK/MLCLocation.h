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
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MLCLocationCompareOrder) {
    MLCLocationCompareOrderDistance,
    MLCLocationCompareOrderName
} NS_SWIFT_NAME(MLCLocation.CompareOrder);

/**
 Locations may be associated with users, events, deals, rewards
 and many other features within the Moblico ecosystem 
 for an exceptionally rich consumer experience. 
 
 Locations are loaded and managed using Moblico's admin tool.
 
 A MLCLocation object encapsulates the data of a location stored in the Moblico Admin Portal.
 */
NS_SWIFT_NAME(Location)
@interface MLCLocation : MLCEntity

/**
 A unique identifier for this location.
 */
@property (nonatomic) NSUInteger locationId NS_SWIFT_NAME(id);
@property (nonatomic) NSUInteger accountId;

/**
 The date this location was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date this location was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

/**
 The type for this location.
 */
@property (copy, nonatomic) NSString *type;

/**
 Specifies whether this location is active.
 */
@property (nonatomic) BOOL active;

/**
 The name for this location.
 */
@property (copy, nonatomic) NSString *name;

/**
 The details for this location.
 */
@property (copy, nonatomic, nullable) NSString *details;

/**
 The first line of the address for this location.
 */
@property (copy, nonatomic, nullable) NSString *address1;

/**
 The second line of the address for this location.
 */
@property (copy, nonatomic, nullable) NSString *address2;

/**
 The city for this location.
 */
@property (copy, nonatomic, nullable) NSString *city;

/**
 The county for this location.
 */
@property (copy, nonatomic, nullable) NSString *county;

/**
 The state or province for this location.
 */
@property (copy, nonatomic, nullable) NSString *stateOrProvince;

/**
 The phone number for this location.
 */
@property (copy, nonatomic, nullable) NSString *phone;

/**
 The email address for this location.
 */
@property (copy, nonatomic, nullable) NSString *email;

/**
 The postal (zip) code for this location.
 */
@property (copy, nonatomic, nullable) NSString *postalCode;

/**
 The country for this location.
 */
@property (copy, nonatomic, nullable) NSString *country;

/**
 The latitude for this location.
 */
@property (nonatomic) CLLocationDegrees latitude;

/**
 The longitude for this location.
 */
@property (nonatomic) CLLocationDegrees longitude;

/**
 The distance for this location.
 
 The distance will be set when the location is retrieved with a service call
 that specifies a search area.
 */
@property (nonatomic) CLLocationDistance distance;

/**
 The URL for this location.
 */
@property (strong, nonatomic, nullable) NSURL *url;

/**
 The contact name for this location.
 */
@property (copy, nonatomic, nullable) NSString *contactName;

/**
 The external unique identifier for this location.
 
 The externalId will be set when the location originates from an external system to Moblico.
 */
@property (copy, nonatomic, nullable) NSString *externalId;

/**
 The locale for this location.
 */
@property (copy, nonatomic, nullable) NSString *locale;

/**
 The attributes for this location.
 */
@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *attributes;

/**
 The merchant id for this location.
 */
@property (nonatomic) NSUInteger merchantId;


@property (nonatomic, strong, nullable) CLCircularRegion *geoFenceRegion;
@property (nonatomic, copy, nullable) NSString *geoEnterNotificationText;
@property (nonatomic) CLLocationDistance geoFenceRadius;

@property (nonatomic, strong, nullable) CLBeaconRegion *beaconRegion;
@property (nonatomic, copy, nullable) NSString *beaconEnterNotificationText;
@property (nonatomic) CLProximity beaconDesiredProximity;
@property (nonatomic) CLProximity beaconLastProximity;
@property (nonatomic) CLProximity beaconMinimumCheckInProximity;

@property (nonatomic) BOOL checkinEnabled;
@property (nonatomic) CLLocationDistance checkinRadius;

- (NSComparisonResult)compare:(MLCLocation *)location order:(MLCLocationCompareOrder)order;
- (NSComparisonResult)compare:(MLCLocation *)location;

@end

NS_ASSUME_NONNULL_END
