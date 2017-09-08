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

/**
 A MLCPoints object represents points earned through affinity.
 */
NS_SWIFT_NAME(Points)
@interface MLCPoints : MLCEntity

/**
 The type for these points.
 */
@property (copy, nonatomic) NSString *type;

/**
 The details for these points.
 */
@property (copy, nonatomic) NSString *details;

/**
 The total amount for these points.
 */
@property (nonatomic) NSInteger total;

/**
 The accumulated total amount for these points.
 */
@property (nonatomic) NSInteger accumulatedTotal;

/**
 The merchant id for these points;
 */
@property (nonatomic) NSUInteger merchantId;

@end
