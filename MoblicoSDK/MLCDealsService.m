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

#import "MLCDealsService.h"
#import "MLCDeal.h"
#import "MLCService_Private.h"
#import "MLCLocation.h"

@implementation MLCDealsService

+ (Class)classForResource {
    return [MLCDeal class];
}

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCLocation class]];
}

+ (instancetype)readDealWithDealId:(NSUInteger)dealId handler:(MLCDealsServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(dealId) handler:handler];
}

+ (instancetype)listDeals:(MLCDealsServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

+ (instancetype)listDealsForResource:(MLCEntity *)resource handler:(MLCDealsServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

+ (instancetype)listDealsForLocation:(MLCLocation *)location handler:(MLCDealsServiceCollectionCompletionHandler)handler {
    return [self listDealsForResource:location handler:handler];
}

+ (instancetype)redeemDeal:(MLCDeal *)deal handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *resource = [NSString pathWithComponents:@[[[deal class] collectionName], deal.uniqueIdentifier, @"redeem"]];

    return [self update:resource parameters:@{@"offerCode": deal.offerCode} handler:handler];
}

@end
