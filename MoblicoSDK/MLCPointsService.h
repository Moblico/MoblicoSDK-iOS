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

#import "MLCService.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *MLCPointsServiceTotalType NS_TYPED_ENUM NS_SWIFT_NAME(MLCPointsService.TotalType);
FOUNDATION_EXPORT MLCPointsServiceTotalType const MLCPointsServiceTotalTypePoints;
FOUNDATION_EXPORT MLCPointsServiceTotalType const MLCPointsServiceTotalTypeAccumulated;
FOUNDATION_EXPORT MLCPointsServiceTotalType const MLCPointsServiceTotalTypeBoth;

@class MLCUser;
@class MLCPoints;

MLCServiceCreateCollectionCompletionHandler(MLCPointsService, MLCPoints);

NS_SWIFT_NAME(PointsService)
@interface MLCPointsService : MLCService

+ (instancetype)listPointsForUser:(MLCUser *)user handler:(MLCPointsServiceCollectionCompletionHandler)handler;

+ (instancetype)updateTotalType:(MLCPointsServiceTotalType)totalType toPoints:(NSInteger)points forUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler NS_SWIFT_NAME(update(_:to:for:handler:));

@end

NS_ASSUME_NONNULL_END
