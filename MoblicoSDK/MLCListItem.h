#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCListItem : MLCEntity

@property (nonatomic) NSUInteger listItemId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *details;
@property (nonatomic) NSUInteger count;
@property (nonatomic, getter=isChecked) BOOL checked;
@property (nonatomic, getter=isFavorite) BOOL favorite;

@end
