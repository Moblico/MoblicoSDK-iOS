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
    NSMutableString *description = [super.description mutableCopy];
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
