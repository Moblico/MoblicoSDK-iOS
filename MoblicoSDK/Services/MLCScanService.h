#import <MoblicoSDK/MLCService.h>

@interface MLCScanService : MLCService

+ (instancetype)processScanWithQRCodeId:(NSString *)qrCodeId handler:(MLCServiceSuccessCompletionHandler)handler;

@end
