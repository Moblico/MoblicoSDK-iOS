#import "MLCListItem.h"
#import "MLCEntity_Private.h"

@implementation MLCListItem

+ (NSString *)resourceName {
	return @"listItem";
}

+ (NSString *)collectionName {
	return @"listItems";
}

- (NSString *)description {
	NSMutableString *description = [[super description] mutableCopy];
	[description appendFormat:@"id: %@ name: %@ details: %@ count: %@ checked: %@ favorite: %@",
	 @(self.listItemId), self.name, self.details, @(self.count), self.checked ? @"YES" : @"NO", self.favorite ? @"YES" : @"NO"];
	return description;
}

+ (NSDictionary *)renamedPropertiesDuringDeserialization {
	NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:[super renamedPropertiesDuringDeserialization]];
	properties[@"isChecked"] = @"checked";
	properties[@"isFavorite"] = @"favorite";

	return properties;
}

+ (NSDictionary *)renamedPropertiesDuringSerialization {
	NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:[super renamedPropertiesDuringSerialization]];
	properties[@"checked"] = @"isChecked";
	properties[@"favorite"] = @"isFavorite";

	return properties;
}

@end
