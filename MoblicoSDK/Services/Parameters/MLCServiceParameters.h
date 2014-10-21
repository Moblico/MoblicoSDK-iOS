//
//  MLCServiceParameter.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/11/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

@import Foundation;

@interface MLCServiceParameters : NSObject

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
//- (id)
@end
