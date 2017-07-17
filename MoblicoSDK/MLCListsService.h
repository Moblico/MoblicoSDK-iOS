#import <MoblicoSDK/MLCService.h>

@class MLCList;

@interface MLCListsService : MLCService

+ (instancetype)listLists:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)readListWithListId:(NSUInteger)listId handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)createList:(MLCList *)list handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)updateList:(MLCList *)list handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyList:(MLCList *)list handler:(MLCServiceSuccessCompletionHandler)handler;

@end
