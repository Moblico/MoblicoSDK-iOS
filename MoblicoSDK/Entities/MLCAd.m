//
//  MLCAd.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCAd.h"
#import "MLCEntity_Private.h"
#import "MLCImage.h"

@implementation MLCAd

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    NSMutableDictionary *adJson = [jsonObject mutableCopy];
    NSString *clickToCall = adJson[@"clickToCall"];
    if ([clickToCall isKindOfClass:[NSString class]] && clickToCall.length && ![clickToCall hasPrefix:@"tel:"]) {
        adJson[@"clickToCall"] = [NSString stringWithFormat:@"tel:%@", clickToCall];
    }

    self = [super initWithJSONObject:adJson];

    if (self) {
        MLCImage *image = [[MLCImage alloc] initWithJSONObject:adJson[@"image"]];
        if (image) {
            self.image = image;
        }
        else {
            self.image = nil;
        }




        if ([self.image isKindOfClass:[NSDictionary class]]) {
        }

    }

    return self;

}
@end
