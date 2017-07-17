#import <MoblicoSDK/MLCService.h>

@class MLCList;
@class MLCListItem;

@interface MLCListItemsService : MLCService

+ (instancetype)listListItemsForList:(MLCList *)list handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)createListItem:(MLCListItem *)listItem forList:(MLCList *)list handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)updateListItem:(MLCListItem *)listItem handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyListItem:(MLCListItem *)listItem handler:(MLCServiceSuccessCompletionHandler)handler;

@end
