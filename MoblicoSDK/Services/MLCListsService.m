#import "MLCListsService.h"
#import "MLCList.h"
#import "MLCEntity_Private.h"
#import "MLCInvalidService.h"
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
