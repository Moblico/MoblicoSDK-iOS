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

NS_ASSUME_NONNULL_BEGIN

@class MLCImage;

/// A MLCAd object encapsulates the data for an ad stored in the Moblico Marketing Portal.
NS_SWIFT_NAME(Ad)
@interface MLCAd : MLCEntity

/// Unique identifier for this ad.
@property (nonatomic) NSUInteger adId NS_SWIFT_NAME(id);
/// Date this ad was created.
@property (strong, nonatomic) NSDate *createDate;
/// Date this ad was last modified.
@property (strong, nonatomic) NSDate *lastUpdateDate;
/// Name of the ad.
@property (copy, nonatomic) NSString *name;
/// Name of the advertiser.
@property (copy, nonatomic, nullable) NSString *advertiserName;
/// URL of type `tel:`.
@property (strong, nonatomic, nullable) NSURL *clickToCall;
/// URL of type `http:|https:`.
@property (strong, nonatomic, nullable) NSURL *clickToUrl;
/// Image of the ad.
@property (strong, nonatomic, nullable) MLCImage *image;
@end

NS_ASSUME_NONNULL_END
