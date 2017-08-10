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

#import "MLCListsService.h"
#import "MLCList.h"
#import "MLCService_Private.h"

@implementation MLCListsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCList class];
}

+ (instancetype)listLists:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:nil handler:handler];
}

+ (instancetype)readListWithListId:(NSUInteger)listId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(listId) handler:handler];
}

+ (instancetype)createList:(MLCList *)resource handler:(MLCServiceResourceCompletionHandler)handler {
    return [self createResource:resource handler:handler];
}

+ (instancetype)updateList:(MLCList *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self updateResource:resource handler:handler];
}

+ (instancetype)destroyList:(MLCList *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self destroyResource:resource handler:handler];
}

@end
