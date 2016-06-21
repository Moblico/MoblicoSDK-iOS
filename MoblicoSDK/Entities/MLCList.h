#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCList : MLCEntity
@property (nonatomic) NSUInteger listId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@end
