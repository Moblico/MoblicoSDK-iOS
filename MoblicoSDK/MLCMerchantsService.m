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

#import "MLCMerchantsService.h"
#import "MLCService_Private.h"
#import "MLCMerchant.h"
@implementation MLCMerchantsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCMerchant class];
}

+ (instancetype)readMerchantWithMerchantId:(NSUInteger)merchantId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(merchantId) handler:handler];
}

+ (instancetype)findMerchantsWithBeaconRegionEnabled:(BOOL)beaconRegionEnabled handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{@"beaconRegionEnabled": @(beaconRegionEnabled)} handler:handler];
}

+ (instancetype)listMerchants:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

@end
