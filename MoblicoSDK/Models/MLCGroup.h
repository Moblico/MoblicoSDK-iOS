//
//  MLCGroup.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/22/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCGroup : MLCEntity

@property (assign, nonatomic) NSUInteger groupId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *details;
@property (assign, nonatomic, getter = isRegisterable) BOOL registerable;
@property (assign, nonatomic) BOOL belongs;
//private String name;
//private String description;
//private boolean isRegisterable;
//private Boolean belongs;

@end
