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

#import <Foundation/Foundation.h>
#import "MLCServiceManager.h"

FOUNDATION_EXPORT void _mlc_info_log(void) __attribute__((deprecated("Remove this log.")));
#define MLCDebugLog(frmt, ...) \
    do { if ([MLCServiceManager isLoggingEnabled]) NSLog(frmt, ##__VA_ARGS__); } while(0)

#define MLCInfoLog(frmt, ...) \
do { if ([MLCServiceManager isLoggingEnabled]) {NSLog(frmt, ##__VA_ARGS__);}_mlc_info_log(); } while(0)
