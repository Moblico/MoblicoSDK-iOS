//
//  MLCProduct.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCProduct.h"

@implementation MLCProduct

void _MLCConvertDateForKey(NSMutableDictionary *json, NSString *key) {
    NSString *dateString = json[key];
	if (dateString == nil || [dateString isKindOfClass:NSNull.class]) {
		return;
	}
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.lenient = YES;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    }
    NSLog(@"dateFormat: %@", [dateFormatter stringFromDate:[NSDate date]]);
    NSLog(@"dateString: %@", dateString);
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSLog(@"date: %@", date);
    NSTimeInterval timeInterval = date.timeIntervalSince1970;
    NSNumber *timeStamp = @(timeInterval * 1000.0);
    NSLog(@"timeStamp: %@", timeStamp);

    json[key] = @(timeStamp.longLongValue);
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    NSMutableDictionary *json = [jsonObject mutableCopy];
    _MLCConvertDateForKey(json, @"expirationDate");
    _MLCConvertDateForKey(json, @"introDate");
    _MLCConvertDateForKey(json, @"revDate");

    self = [super initWithJSONObject:json];

    return self;
}

@end
