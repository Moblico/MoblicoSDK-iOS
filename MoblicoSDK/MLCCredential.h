//
//  MLCCredentials.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/14/16.
//  Copyright © 2016 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCCredential : MLCEntity

@property (nonatomic) NSUInteger accountId;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic) NSUInteger parentAccountId;

//private long accountId;
//private String accountName;
//private String username;
//private String apiKey;
//private String keyword;
//private long parentAccountId;

@end
