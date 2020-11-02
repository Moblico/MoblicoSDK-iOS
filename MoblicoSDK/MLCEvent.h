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
 Events are used within Moblico for informational purposes as well as targeting communications,
 ad campaigns and deals by time and location.
 
 Events are loaded and managed using Moblico's admin tool.
 
 A MLCEvent object encapsulates the data of an event stored in the Moblico Admin Portal.
 */
NS_SWIFT_NAME(Event)
@interface MLCEvent : MLCEntity

/**
 A unique identifier for this event.
 */
@property (nonatomic) NSUInteger eventId NS_SWIFT_NAME(id);

/**
 The unique identifier for the parent event associated with this event.
 */
@property (nonatomic) NSUInteger parentId;

/**
 The external unique identifier for this event.
 
 The externalId will be set when the event originates from an external system to Moblico.
 */
@property (copy, nonatomic, nullable) NSString *externalId;

/**
 The type for this event.
 */
@property (copy, nonatomic, nullable) NSString *type;

/**
 The name for this event.
 */
@property (copy, nonatomic) NSString *name;

/**
 The details for this event.
 */
@property (copy, nonatomic, nullable) NSString *details;

/**
 The time zone for this event.
 */
@property (copy, nonatomic) NSTimeZone *timeZone;

/**
 The phone number for this event.
 */
@property (copy, nonatomic, nullable) NSString *phone;

/**
 The email address for this event.
 */
@property (copy, nonatomic, nullable) NSString *email;

/**
 A string representation of the startDate for this event.
 */
@property (copy, nonatomic) NSString *startTime;

/**
 A string representation of the endDate for this event.
 */
@property (copy, nonatomic) NSString *endTime;

/**
 The RSVP name for this event.
 */
@property (copy, nonatomic, nullable) NSString *rsvpName;

/**
 The RSVP phone number for this event.
 */
@property (copy, nonatomic, nullable) NSString *rsvpPhone;

/**
 The RSVP email address for this event.
 */
@property (copy, nonatomic, nullable) NSString *rsvpEmail;

/**
 The RSVP URL for this event.
 */
@property (copy, nonatomic, nullable) NSURL *rsvpUrl;

/**
 The attributes for this event.
 */
@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *attributes;

/**
 The URL for this event.
 */
@property (strong, nonatomic, nullable) NSURL *url;

/**
 The date this event was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date this event was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

/**
 The date this event will become active.
 */
@property (strong, nonatomic) NSDate *startDate;

/**
 The date this event will no longer be active.
 */
@property (strong, nonatomic) NSDate *endDate;

@end

NS_ASSUME_NONNULL_END
