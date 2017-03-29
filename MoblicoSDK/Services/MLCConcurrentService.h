//
//  MLCConcurrentService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 3/28/17.
//  Copyright © 2017 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLCConcurrentServiceCompletionHandler)(void);


@interface MLCConcurrentService : MLCService

+ (instancetype)concurrentServiceWithServices:(NSArray<__kindof MLCService *> *)services completionHandler:(_Nullable MLCConcurrentServiceCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
