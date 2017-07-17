#import "MLCScanService.h"
#import "MLCService_Private.h"
#import "MLCStatus.h"
#import "MLCServiceManager.h"
#import "MLCUser.h"

@implementation MLCScanService

+ (instancetype)processScanWithQRCodeId:(NSString *)qrCodeId handler:(MLCServiceSuccessCompletionHandler)handler {

	NSString *path = [NSString pathWithComponents:@[@"users",
								   MLCServiceManager.sharedServiceManager.currentUser.username,
								   @"points",
								   @"scan"]];
	return [self update:path parameters:@{@"qrCodeId": qrCodeId} handler:handler];
}

+ (Class<MLCEntityProtocol>)classForResource {
	return [MLCStatus class];
}

@end
