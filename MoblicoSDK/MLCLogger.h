//
//  MLCLogger.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 5/5/16.
//  Copyright © 2016 Moblico Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCServiceManager.h"

FOUNDATION_EXPORT void _mlc_info_log() __attribute__((deprecated("Remove this log.")));
#define MLCDebugLog(frmt, ...) \
    do { if ([MLCServiceManager isLoggingEnabled]) NSLog(frmt, ##__VA_ARGS__); } while(0)

#define MLCInfoLog(frmt, ...) \
do { if ([MLCServiceManager isLoggingEnabled]) {NSLog(frmt, ##__VA_ARGS__);}_mlc_info_log(); } while(0)
