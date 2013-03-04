//
//  MLCInvalidService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/5/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCServiceProtocol.h"

typedef void(^MLCInvalidServiceCompletionHandler)(id jsonObject, NSError *error, NSHTTPURLResponse *response);

@interface MLCInvalidService : NSObject <MLCServiceProtocol>
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) MLCInvalidServiceCompletionHandler handler;
+ (id)invalidServiceWithError:(NSError *)error handler:(MLCInvalidServiceCompletionHandler)handler;
@end
