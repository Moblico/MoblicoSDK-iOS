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
#import "MLCEntity_Private.h"
#import "MLCMediaService.h"
#import "MLCMedia.h"
#import "MLCLocation.h"
#import "MLCEvent.h"

MLCMediaServiceParameter const MLCMediaServiceParameterMediaType = @"mediaType";
MLCMediaServiceParameter const MLCMediaServiceParameterMediaTypeCategory = @"mediaTypeCategory";
MLCMediaServiceParameter const MLCMediaServiceParameterCategory = @"category";

@implementation MLCMediaService

+ (NSMutableDictionary *)sanitizeParameters:(MLCMediaServiceParameters)parameters {
    NSMutableDictionary *params = [parameters mutableCopy];
    params[MLCMediaServiceParameterMediaType] = [MLCEntity stringFromValue:params[MLCMediaServiceParameterMediaType]];
    params[MLCMediaServiceParameterMediaTypeCategory] = [MLCEntity stringFromValue:params[MLCMediaServiceParameterMediaTypeCategory]];
    params[MLCMediaServiceParameterCategory] = [MLCEntity stringFromValue:params[MLCMediaServiceParameterCategory]];

    return params;
}

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCLocation class], [MLCEvent class], [MLCMedia class]];
}

+ (Class)classForResource {
    return [MLCMedia class];
}

+ (instancetype)findMediaWithParameters:(MLCMediaServiceParameters)parameters handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters = [self sanitizeParameters:parameters];
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}


+ (instancetype)readMediaWithMediaId:(NSUInteger)mediaId handler:(MLCMediaServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(mediaId) handler:handler];
}

+ (instancetype)listMedia:(MLCMediaServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{} handler:handler];
}

+ (instancetype)listMediaForLocation:(MLCLocation *)location handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    return [self listMediaForResource:location handler:handler];
}

+ (instancetype)listMediaForEvent:(MLCEvent *)event handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    return [self listMediaForResource:event handler:handler];
}

+ (instancetype)listMediaForMedia:(MLCMedia *)media handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    return [self listMediaForResource:media handler:handler];
}

+ (instancetype)listMediaForResource:resource handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{} handler:handler];
}

+ (instancetype)findMediaForMedia:(MLCMedia *)media parameters:(MLCMediaServiceParameters)parameters handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters = [self sanitizeParameters:parameters];
    return [self findScopedResourcesForResource:media searchParameters:searchParameters handler:handler];
}

+ (instancetype)findMediaForLocation:(MLCLocation *)location parameters:(MLCMediaServiceParameters)parameters handler:(MLCMediaServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters = [self sanitizeParameters:parameters];
    return [self findScopedResourcesForResource:location searchParameters:searchParameters handler:handler];
}


@end
