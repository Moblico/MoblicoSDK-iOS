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

#import "MLCLogger.h"
#import "MLCServiceManager.h"

@implementation MLCLogger

+ (void)log:(NSString *)format, ... {
    if (MLCServiceManager.logging == MLCServiceManagerLoggingDisabled) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

+ (void)debugLog:(NSString *)format, ... {
    if (MLCServiceManager.logging < MLCServiceManagerLoggingEnabledVerbose) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

+ (void)logMessage:(NSString *)message {
	[self log:@"%@", message];
}

+ (void)debugLogMessage:(NSString *)message {
	[self debugLog:@"%@", message];
}

@end
