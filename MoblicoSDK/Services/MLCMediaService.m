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

#import "MLCMediaService.h"
#import "MLCMedia.h"

@implementation MLCMediaService

+ (NSArray *)scopeableResources {
    return @[@"MLCLocation", @"MLCEvent"];
}

+ (Class<MLCEntity>)classForResource {
    return [MLCMedia class];
}

+ (instancetype)findMediaWithMediaType:(NSString *)mediaType mediaTypeCategory:(NSString *)mediaTypeCategory handler:(MLCServiceCollectionCompletionHandler)handler {

    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionaryWithCapacity:5];
    if (mediaType.length) searchParameters[@"mediaType"] = mediaType;
    if (mediaTypeCategory.length) searchParameters[@"mediaTypeCategory"] = mediaTypeCategory;

    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}


+ (instancetype)readMediaWithMediaId:(NSUInteger)mediaId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(mediaId) handler:handler];
}

+ (instancetype)listMedia:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

+ (instancetype)listMediaForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listMediaForResource:(id<MLCEntity>)location handler:handler];
}

+ (instancetype)listMediaForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listMediaForResource:(id<MLCEntity>)event handler:handler];
}

+ (instancetype)listMediaForResource:(id <MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

@end
