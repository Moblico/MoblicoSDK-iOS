//
//  MLCSessionManager.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 9/24/18.
//  Copyright © 2018 Moblico Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLCSessionManager : NSObject

@property (class, strong, readonly, nonatomic, nonnull) NSURLSession *session;

@end

NS_ASSUME_NONNULL_END
