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

#ifndef __APPCODE_IDE__
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 120000
#error "iOS 12 is the minimum required Target Deployment for MoblicoSDK."
#endif
#endif

//! Project version number for MoblicoSDK.
FOUNDATION_EXPORT double MoblicoSDKVersionNumber;

//! Project version string for MoblicoSDK.
FOUNDATION_EXPORT const unsigned char MoblicoSDKVersionString[];

#import <MoblicoSDK/MLCServiceManager.h>

// Services
#import <MoblicoSDK/MLCService.h>
#import <MoblicoSDK/MLCGenericService.h>
#import <MoblicoSDK/MLCConcurrentService.h>

#import <MoblicoSDK/MLCAdsService.h>
#import <MoblicoSDK/MLCAffinitiesService.h>
#import <MoblicoSDK/MLCCheckInService.h>
#import <MoblicoSDK/MLCCredentialsService.h>
#import <MoblicoSDK/MLCDealsService.h>
#import <MoblicoSDK/MLCEventsService.h>
#import <MoblicoSDK/MLCGroupsService.h>
#import <MoblicoSDK/MLCInboxMessagesService.h>
#import <MoblicoSDK/MLCLeaderboardService.h>
#import <MoblicoSDK/MLCListItemsService.h>
#import <MoblicoSDK/MLCListsService.h>
#import <MoblicoSDK/MLCLocationsService.h>
#import <MoblicoSDK/MLCMediaService.h>
#import <MoblicoSDK/MLCMerchantsService.h>
#import <MoblicoSDK/MLCMessageService.h>
#import <MoblicoSDK/MLCMetricsService.h>
#import <MoblicoSDK/MLCNotificationsService.h>
#import <MoblicoSDK/MLCOutOfBandService.h>
#import <MoblicoSDK/MLCPointsService.h>
#import <MoblicoSDK/MLCProductCategoriesService.h>
#import <MoblicoSDK/MLCProductsService.h>
#import <MoblicoSDK/MLCRewardsService.h>
#import <MoblicoSDK/MLCScanService.h>
#import <MoblicoSDK/MLCSettingsService.h>
#import <MoblicoSDK/MLCUsersService.h>
#import <MoblicoSDK/MLCUserTransactionsService.h>
#import <MoblicoSDK/MLCUserTransactionsSummaryService.h>


// Models
#import <MoblicoSDK/MLCEntity.h>
#import <MoblicoSDK/MLCValidation.h>

#import <MoblicoSDK/MLCAd.h>
#import <MoblicoSDK/MLCAffinity.h>
#import <MoblicoSDK/MLCCredential.h>
#import <MoblicoSDK/MLCDeal.h>
#import <MoblicoSDK/MLCEvent.h>
#import <MoblicoSDK/MLCGroup.h>
#import <MoblicoSDK/MLCImage.h>
#import <MoblicoSDK/MLCInboxMessage.h>
#import <MoblicoSDK/MLCLeader.h>
#import <MoblicoSDK/MLCList.h>
#import <MoblicoSDK/MLCListItem.h>
#import <MoblicoSDK/MLCLocation.h>
#import <MoblicoSDK/MLCMedia.h>
#import <MoblicoSDK/MLCMerchant.h>
#import <MoblicoSDK/MLCMessage.h>
#import <MoblicoSDK/MLCNotification.h>
#import <MoblicoSDK/MLCMetric.h>
#import <MoblicoSDK/MLCPoints.h>
#import <MoblicoSDK/MLCProduct.h>
#import <MoblicoSDK/MLCProductCategory.h>
#import <MoblicoSDK/MLCProductType.h>
#import <MoblicoSDK/MLCResetPassword.h>
#import <MoblicoSDK/MLCReward.h>
#import <MoblicoSDK/MLCStatus.h>
#import <MoblicoSDK/MLCUser.h>
#import <MoblicoSDK/MLCUserTransaction.h>
#import <MoblicoSDK/MLCUserTransactionsSummary.h>

#import <MoblicoSDK/MLCMetricsManager.h>
#import <MoblicoSDK/MLCOrderManager.h>

#import <MoblicoSDK/MLCEntityCache.h>
#import <MoblicoSDK/MLCKeychainPasswordItem.h>

#import <MoblicoSDK/MLCLogger.h>
