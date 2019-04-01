//
//  MLCSessionManager.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 9/24/18.
//  Copyright © 2018 Moblico Solutions LLC. All rights reserved.
//

#import "MLCSessionManager.h"

@interface MLCSessionManager () <NSURLSessionDelegate>
@property (nonatomic, readonly, strong, class) MLCSessionManager *sharedManager;
@property (strong, readwrite, nonatomic, nonnull) NSURLSession *session;
@end

@implementation MLCSessionManager

+ (MLCSessionManager *)sharedManager {
    static MLCSessionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:NSOperationQueue.mainQueue];
    }
    return _session;

}

+ (NSURLSession *)session {
    return MLCSessionManager.sharedManager.session;
}

#pragma mark - NSURLSessionDelegate


@end


//
//#pragma mark - NSURLConnectionDataDelegate
//
//- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    self.httpResponse = (NSHTTPURLResponse *)response;
//    self.receivedData.length = 0;
//}
//
//- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.receivedData appendData:data];
//}
//
//- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error {
//#if TARGET_OS_IPHONE
//    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
//#endif
//
//    MLCDebugLog(@"connection:didFailWithError:%@", error);
//    [self logDictionaryWithResponse:nil error:error];
//
//    self.jsonCompletionHandler(self, nil, error, self.httpResponse);
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//#if TARGET_OS_IPHONE
//    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
//#endif
//
//    NSError *error;
//    id jsonObject = nil;
//
//    if (self.receivedData.length) {
//        jsonObject = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingAllowFragments error:&error];
//    }
//
//    MLCDebugLog(@"connectionDidFinishLoading: %@", connection);
//    [self logDictionaryWithResponse:jsonObject error:error];
//
//    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *statusJSON = jsonObject[@"status"];
//        if ([statusJSON isKindOfClass:[NSDictionary class]]) {
//            MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:statusJSON];
//            if (status.type != MLCStatusTypeSuccess) {
//                MLCStatusError *statusError = [[MLCStatusError alloc] initWithStatus:status];
//                self.jsonCompletionHandler(self, nil, statusError, self.httpResponse);
//                self.receivedData = nil;
//                return;
//            }
//        }
//    } else if (jsonObject == [NSNull null]) {
//        jsonObject = nil;
//    }
//
//    self.jsonCompletionHandler(self, jsonObject, nil, self.httpResponse);
//    self.receivedData = nil;
//}
//
//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    MLCDebugLog(@"connection: %@ willSendRequestForAuthenticationChallenge: %@", connection, challenge);
//    MLCDebugLog(@"challenge.protectionSpace: %@ challenge.proposedCredential: %@ challenge.previousFailureCount: %@ challenge.failureResponse: %@ challenge.error: %@ challenge.sender: %@", challenge.protectionSpace, challenge.proposedCredential, @(challenge.previousFailureCount), challenge.failureResponse, challenge.error, challenge.sender);
//    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
//}
