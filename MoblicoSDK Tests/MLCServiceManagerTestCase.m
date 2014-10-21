//
//  MoblicoSDK_Tests.m
//  MoblicoSDK Tests
//
//  Created by Cameron Knight on 4/19/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "MLCServiceManager.h"

@interface MLCServiceManagerTestCase : XCTestCase

@end

@implementation MLCServiceManagerTestCase

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
- (void)testSharedServiceManagerReturnsSingletonOrThrowsException {
    if ([MLCServiceManager apiKey]) {
            XCTAssertEqual([MLCServiceManager sharedServiceManager], [MLCServiceManager sharedServiceManager], @"");
    }
    else {
        XCTAssertThrows([MLCServiceManager sharedServiceManager], @"should throw MLCInvalidAPIKeyException");
    }

}

- (void)testSharedServiceManagerThrowsExceptionWhenAPIKeyIsSetTwice {
    [MLCServiceManager setTestingEnabled:NO];
    if (![MLCServiceManager apiKey]) {
        [MLCServiceManager setAPIKey:@"PROD API KEY"];
    }

    XCTAssertThrows([MLCServiceManager setAPIKey:@"PROD API KEY 2"], @"should throw MLCInvalidAPIKeyException");
}

- (void)testSharedServiceManagerThrowsExceptionWhenTestingAPIKeyIsSetTwice {
    [MLCServiceManager setTestingEnabled:YES];
    if (![MLCServiceManager apiKey]) {
        [MLCServiceManager setTestingAPIKey:@"TEST API KEY"];
    }

    XCTAssertThrows([MLCServiceManager setTestingAPIKey:@"TEST API KEY 2"], @"should throw MLCInvalidAPIKeyException");
}
*/

@end
