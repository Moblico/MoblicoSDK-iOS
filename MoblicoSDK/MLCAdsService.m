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

#import "MLCAdsService.h"
#import "MLCService_Private.h"
#import "MLCAd.h"

MLCAdsServiceType const MLCAdsServiceTypeBanner = @"AD_BANNER";
MLCAdsServiceType const MLCAdsServiceTypePromo = @"AD_PROMO";
MLCAdsServiceType const MLCAdsServiceTypeSponsor = @"AD_SPONSOR";

@implementation MLCAdsService

+ (Class)classForResource {
    return [MLCAd class];
}

+ (instancetype)findAdsWithType:(MLCAdsServiceType)type context:(NSString *)context handler:(MLCAdsServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    parameters[@"type"] = type;
    if (context) {
        parameters[@"context"] = context;
    }
    return [self _find:@"promos" searchParameters:parameters handler:handler];
}

+ (instancetype)readAdWithType:(MLCAdsServiceType)type context:(NSString *)context handler:(MLCAdsServiceResourceCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    parameters[@"type"] = type;
    if (context) {
        parameters[@"context"] = context;
    }
    return [self _read:@"ad" parameters:parameters handler:handler];
}

@end
