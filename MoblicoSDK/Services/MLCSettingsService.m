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

#import "MLCSettingsService.h"
#import "MLCService_Private.h"

@implementation MLCSettingsService

+ (Class<MLCEntityProtocol>)classForResource {
    return Nil;
}

+ (instancetype)readSettings:(MLCServiceJSONCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:@"settings"
                       parameters:nil
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                                  [[NSUserDefaults standardUserDefaults] setObject:jsonObject forKey:@"MLCSettings"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                              }
                              handler(jsonObject, error, response);
                          }];
}

+ (NSDictionary *)settings {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"MLCSettings"];
}

+ (void)overrideSettings:(NSDictionary *)settings {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.settings];
    [dictionary addEntriesFromDictionary:settings];
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"MLCSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
