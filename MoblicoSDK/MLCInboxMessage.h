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

NS_SWIFT_NAME(InboxMessage)
@interface MLCInboxMessage : MLCEntity
@property (nonatomic) NSUInteger inboxMessageId NS_SWIFT_NAME(id);
@property (nonatomic, copy, nullable) NSString *alertText;
//@property (nonatomic, copy, nullable) NSString *titleText;
//@property (nonatomic, copy, nullable) NSString *messageText;
//@property (nonatomic, copy, nullable) NSString *passthru;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *payload;
@property (nonatomic, copy, nullable) NSString *state;
@property (nonatomic, copy, nullable) NSDate *dateCreated;
//@property (nonatomic, copy, nullable) NSDate *lastDateModified;
@end

NS_ASSUME_NONNULL_END
