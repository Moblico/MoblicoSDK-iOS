#import "MLCListItemsService.h"
#import "MLCListItem.h"
#import "MLCList.h"
#import "MLCEntity_Private.h"
#import "MLCInvalidService.h"
#import "MLCService_Private.h"

@implementation MLCListItemsService

+ (NSArray *)scopeableResources {
	return @[@"MLCList"];
}
+ (Class<MLCEntityProtocol>)classForResource {
	return [MLCListItem class];
}

+ (instancetype)listListItemsForList:(MLCList *)resource handler:(MLCServiceCollectionCompletionHandler)handler {
	return [self listScopedResourcesForResource:resource handler:handler];
}

+ (instancetype)createListItem:(MLCListItem *)listItem forList:(MLCList *)list handler:(MLCServiceResourceCompletionHandler)handler {
	NSString *path = [NSString pathWithComponents:@[[[list class] collectionName], list.uniqueIdentifier, [[listItem class] collectionName]]];
	return [self create:path parameters:[[listItem class] serialize:listItem] handler:handler];
}

+ (instancetype)updateListItem:(MLCListItem *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
	return [self updateResource:resource handler:handler];
}

+ (instancetype)destroyListItem:(MLCListItem *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
	return [self destroyResource:resource handler:handler];
}

@end
