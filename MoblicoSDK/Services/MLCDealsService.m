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

@implementation MLCDealsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCDeal class];
}

+ (NSArray *)scopeableResources {
    return @[@"MLCLocation"];
}

+ (id)readDealWithDealId:(NSUInteger)dealId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(dealId) handler:handler];
}

+ (id)listDeals:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

+ (id)listDealsForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

+ (id)listDealsForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listDealsForResource:(id<MLCEntityProtocol>)location handler:handler];
}

+ (id)redeemDeal:(MLCDeal *)deal withOfferCode:(NSString *)offerCode handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *resource = [NSString pathWithComponents:@[[deal collectionName], [deal uniqueIdentifier], @"redeem"]];
    return [self update:resource parameters:@{@"offerCode": offerCode} handler:handler];
}

@end
