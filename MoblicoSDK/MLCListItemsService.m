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

#import "MLCListItemsService.h"
#import "MLCListItem.h"
#import "MLCService_Private.h"
#import "MLCList.h"

@implementation MLCListItemsService

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCList class]];
}

+ (Class)classForResource {
    return [MLCListItem class];
}

+ (instancetype)listListItemsForList:(MLCList *)resource handler:(MLCListItemsServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{} handler:handler];
}

+ (instancetype)createListItem:(MLCListItem *)listItem forList:(MLCList *)list handler:(MLCListItemsServiceResourceCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[list class] collectionName], list.uniqueIdentifier, [[listItem class] collectionName]]];
    return [self _create:path parameters:[[listItem class] serialize:listItem] handler:handler];
}

+ (instancetype)updateListItem:(MLCListItem *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self updateResource:resource handler:handler];
}

+ (instancetype)destroyListItem:(MLCListItem *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self destroyResource:resource handler:handler];
}

@end
