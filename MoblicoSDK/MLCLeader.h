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

NS_ASSUME_NONNULL_BEGIN

/// MLCLeader represents a user who has earned points.
NS_SWIFT_NAME(Leader)
@interface MLCLeader : MLCEntity

/// The username of the user.
@property (copy, nonatomic, nullable) NSString *username;

/// The first name of the user.
@property (copy, nonatomic, nullable) NSString *firstName;

/// The last name of the user.
@property (copy, nonatomic, nullable) NSString *lastName;

/// The email address of the user.
@property (copy, nonatomic, nullable) NSString *email;

/// The nick name of the user.
@property (copy, nonatomic, nullable) NSString *nickName;

/// The amount of points earned by this user.
@property (nonatomic) NSInteger points;

@end

NS_ASSUME_NONNULL_END
