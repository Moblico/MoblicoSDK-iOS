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

@interface MLCPointsService ()
+ (NSString *)stringForPointsTotalType:(MLCPointsTotalType)type;
@end

@implementation MLCPointsService

+ (Class<MLCEntity>)classForResource {
    return [MLCPoints class];
}

+ (NSArray *)scopeableResources {
    return @[@"MLCUser"];
}

+ (instancetype)listPointsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler {
    NSDictionary * searchParameters = @{@"pointTypeName": @"Interactive"};
    return [self findScopedResourcesForResource:(id<MLCEntity>)user searchParameters:searchParameters handler:handler];
}

+ (instancetype)updatePoints:(NSInteger)points type:(MLCPointsTotalType)totalType forUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    NSMutableDictionary * parameters = [@{@"pointTypeName": @"Interactive"} mutableCopy];
    parameters[@"points"] = @(points);
    NSString * totalTypeName = [self stringForPointsTotalType:totalType];
    if (totalTypeName.length) parameters[@"totalTypeName"] = totalTypeName;
    NSString * path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], @"points"]];
    return [self update:path parameters:parameters handler:handler];
}

+ (NSString *)stringForPointsTotalType:(MLCPointsTotalType)type {
    switch (type) {
        case MLCPointsTotalTypeAccumulated:
            return @"ACCUM";
            break;
        case MLCPointsTotalTypePoints:
            return @"POINTS";
            break;
        case MLCPointsTotalTypeBoth:
            return nil;
    }
    return nil;
}

@end
