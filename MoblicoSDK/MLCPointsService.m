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
#import "MLCService_Private.h"
#import "MLCPointsService.h"
#import "MLCPoints.h"
#import "MLCUser.h"

MLCPointsServiceTotalType const MLCPointsServiceTotalTypePoints = @"POINTS";
MLCPointsServiceTotalType const MLCPointsServiceTotalTypeAccumulated = @"ACCUM";
MLCPointsServiceTotalType const MLCPointsServiceTotalTypeBoth = @"";

static NSString *const MLCPointsServiceParameterTotalTypeName = @"totalTypeName";
static NSString *const MLCPointsServiceParameterPointTypeName = @"pointTypeName";
static NSString *const MLCPointsServiceParameterPoints = @"points";

static NSString *const MLCPointsServicePointTypeInteractive = @"Interactive";

@interface MLCPointsService ()

@end

@implementation MLCPointsService

+ (Class)classForResource {
    return [MLCPoints class];
}

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCUser class]];
}

+ (instancetype)listPointsForUser:(MLCUser *)user handler:(MLCPointsServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters = @{MLCPointsServiceParameterPointTypeName: MLCPointsServicePointTypeInteractive};
    return [self findScopedResourcesForResource:user searchParameters:searchParameters handler:handler];
}

+ (instancetype)updateTotalType:(MLCPointsServiceTotalType)totalType toPoints:(NSInteger)points forUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSMutableDictionary *parameters = [@{MLCPointsServiceParameterPointTypeName: MLCPointsServicePointTypeInteractive,
                                         MLCPointsServiceParameterPoints: @(points)} mutableCopy];
    if (totalType.length) parameters[MLCPointsServiceParameterTotalTypeName] = totalType;
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [MLCPoints collectionName]]];
    return [self update:path parameters:parameters handler:handler];
}


@end
