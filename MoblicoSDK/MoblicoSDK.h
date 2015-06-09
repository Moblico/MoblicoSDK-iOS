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

@import Foundation;

FOUNDATION_EXPORT double MoblicoSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char MoblicoSDKVersionString[];


#import <MoblicoSDK/version.h>
#import <MoblicoSDK/MLCServiceManager.h>

// Services
#import <MoblicoSDK/MLCService.h>
#import <MoblicoSDK/MLCBasicService.h>

#import <MoblicoSDK/MLCAffinitiesService.h>
#import <MoblicoSDK/MLCCheckInService.h>
#import <MoblicoSDK/MLCDealsService.h>
#import <MoblicoSDK/MLCEventsService.h>
#import <MoblicoSDK/MLCGroupsService.h>
#import <MoblicoSDK/MLCLeaderboardService.h>
#import <MoblicoSDK/MLCLocationsService.h>
#import <MoblicoSDK/MLCMediaService.h>
#import <MoblicoSDK/MLCMessageService.h>
#import <MoblicoSDK/MLCMetricsService.h>
#import <MoblicoSDK/MLCOutOfBandService.h>
#import <MoblicoSDK/MLCPointsService.h>
#import <MoblicoSDK/MLCProductCategoriesService.h>
#import <MoblicoSDK/MLCProductsService.h>
#import <MoblicoSDK/MLCRewardsService.h>
#import <MoblicoSDK/MLCSettingsService.h>
#import <MoblicoSDK/MLCUsersService.h>
#import <MoblicoSDK/MLCUserTransactionsService.h>
#import <MoblicoSDK/MLCUserTransactionsSummaryService.h>


// Models
#import <MoblicoSDK/MLCEntity.h>
#import <MoblicoSDK/MLCValidation.h>

#import <MoblicoSDK/MLCAffinity.h>
#import <MoblicoSDK/MLCDeal.h>
#import <MoblicoSDK/MLCEvent.h>
#import <MoblicoSDK/MLCGroup.h>
#import <MoblicoSDK/MLCImage.h>
#import <MoblicoSDK/MLCLeader.h>
#import <MoblicoSDK/MLCLocation.h>
#import <MoblicoSDK/MLCMedia.h>
#import <MoblicoSDK/MLCMessage.h>
#import <MoblicoSDK/MLCMetric.h>
#import <MoblicoSDK/MLCPoints.h>
#import <MoblicoSDK/MLCProduct.h>
#import <MoblicoSDK/MLCProductCategory.h>
#import <MoblicoSDK/MLCProductType.h>
#import <MoblicoSDK/MLCReward.h>
#import <MoblicoSDK/MLCStatus.h>
#import <MoblicoSDK/MLCUser.h>
#import <MoblicoSDK/MLCUserTransaction.h>
#import <MoblicoSDK/MLCUserTransactionsSummary.h>

#import <MoblicoSDK/MLCMetricsManager.h>
