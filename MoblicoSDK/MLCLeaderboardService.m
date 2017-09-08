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

#import "MLCService_Private.h"

#import "MLCLeaderboardService.h"
#import "MLCLeader.h"

MLCLeaderboardServiceType const MLCLeaderboardServiceTypeOverallPoints = @"overallPoints";

@interface MLCLeaderboardService ()

@end

@implementation MLCLeaderboardService

+ (Class)classForResource {
    return [MLCLeader class];
}

+ (instancetype)findLeaderboardWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCLeaderboardServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}

+ (instancetype)findLeaderboardWithType:(MLCLeaderboardServiceType)type limit:(NSInteger)limit handler:(MLCLeaderboardServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *searchParameters = [@{@"type": type} mutableCopy];
    if (limit) searchParameters[@"leaderboardLimit"] = @(limit);

    return [self findLeaderboardWithSearchParameters:searchParameters handler:handler];
}

@end
