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

#define MLCLog(frmt, ...) \
    do { [MLCLogger log:frmt, ##__VA_ARGS__]; } while(0)

#define MLCDebugLog(frmt, ...) \
    do { [MLCLogger debugLog:frmt, ##__VA_ARGS__]; } while(0)


NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Logger)
@interface MLCLogger : NSObject

+ (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) NS_SWIFT_UNAVAILABLE("Use `log(_:)` instead.");
+ (void)debugLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) NS_SWIFT_UNAVAILABLE("Use `debugLog(_:)` instead.");
+ (void)logMessage:(NSString *)message NS_SWIFT_NAME(log(_:));
+ (void)debugLogMessage:(NSString *)message NS_SWIFT_NAME(debugLog(_:));
@end

NS_ASSUME_NONNULL_END
