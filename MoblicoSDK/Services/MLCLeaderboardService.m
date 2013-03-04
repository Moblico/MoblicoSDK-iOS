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

@interface MLCLeaderboardService ()
+ (NSString *)stringFromMLCLeaderboardType:(MLCLeaderboardType)type;
@end

@implementation MLCLeaderboardService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCLeader class];
}

+ (id)findLeaderboardWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}

+ (id)findLeaderboardWithType:(MLCLeaderboardType)type limit:(int)limit handler:(MLCServiceCollectionCompletionHandler)handler {
    NSMutableDictionary * searchParameters = [@{@"type": [self stringFromMLCServiceRequestMethod:type]} mutableCopy];
    if (limit) searchParameters[@"leaderboardLimit"] = @(limit);
    return [self findLeaderboardWithSearchParameters:searchParameters handler:handler];
}

+ (NSString *)stringFromMLCLeaderboardType:(MLCLeaderboardType)type {
    switch (type) {
        case MLCLeaderboardTypeOverallPoints:
            return @"overallPoints";
    }
    
    return nil;
}

@end
