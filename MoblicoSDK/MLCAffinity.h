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

/**
 Moblico affinity facilitates a points plus rewards system.
 The Moblico admin portal provides the means to define actions
 for the affinity engine to process.
 
 Please see the Moblico admin portal for more information concerning
 affinity setup and usage including how to setup your own unique rewards.
 
 A MLCAffinity object encapsulates the data of an affinity stored in the Moblico Admin Portal.
 */
NS_SWIFT_NAME(Affinity)
@interface MLCAffinity : MLCEntity

/**
 A unique identifier for this affinity.
 */
@property (nonatomic) NSUInteger affinityId NS_SWIFT_NAME(id);

/**
 The date this affinity was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date this affinity was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

/**
 The date this affinity will become active.
 */
@property (strong, nonatomic, nullable) NSDate *startDate;

/**
 The date this affinity will no longer be active.
 */
@property (strong, nonatomic, nullable) NSDate *endDate;

/**
 The name for this affinity.
 */
@property (copy, nonatomic) NSString *name;

/**
 The details for this affinity.
 */
@property (copy, nonatomic, nullable) NSString *details;

/**
 Optional data about this affinity.
 */
@property (copy, nonatomic, nullable) NSString *optional;

/**
 The amount of points this affinity is worth.
 */
@property (nonatomic) NSInteger points;

/**
 The maximum number of times a user can be rewarded this affinity.
 */
@property (nonatomic) NSInteger userLimit;

/**
 The unique identifier for the affinity action associated with this affinity.
 */
@property (nonatomic) NSUInteger affinityActionId;

/**
 The unique identifier for the point type associated with this affinity.
 */
@property (nonatomic) NSUInteger pointTypeId;

/**
 The unique identifier for the reward associated with this affinity.
 */
@property (nonatomic) NSUInteger rewardId;

/**
 The unique identifier for the event associated with this affinity.
 */
@property (nonatomic) NSUInteger eventId;

/**
 The unique identifier for the location associated with this affinity.
 */
@property (nonatomic) NSUInteger locationId;

/**
 The unique identifier for the question answer associated with this affinity.
 */
@property (nonatomic) NSUInteger questionAnswerId;

/**
 The unique identifier for the group associated with this affinity.
 */
@property (nonatomic) NSUInteger groupId;

@property (nonatomic) NSUInteger recipientGroupId;

@property (copy, nonatomic) NSString *affinityActionName;

@end

NS_ASSUME_NONNULL_END
