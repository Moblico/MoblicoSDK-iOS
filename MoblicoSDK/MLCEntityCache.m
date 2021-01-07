//
//  MLCEntityCache.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCEntityCache.h"

@interface MLCEntityCache ()
@property (class, nonnull, copy, readonly) NSURL *cacheDirectoryURL;
@end


@implementation MLCEntityCache

+ (NSURL *)cacheDirectoryURL {
    static dispatch_once_t onceToken;
    static NSURL *cacheDirectoryURL = nil;
    dispatch_once(&onceToken, ^{
        NSArray *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        cacheDirectoryURL = [paths.firstObject URLByAppendingPathComponent:@"CachedEntities" isDirectory:YES];
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtURL:cacheDirectoryURL
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:&error]) {
            NSLog(@"Failed to create CachedEntities directory: %@", error.localizedDescription);
        }
    });

    return cacheDirectoryURL;
}

+ (NSURL *)URL:(NSString *)key {
    NSString *component = [key stringByAppendingPathExtension:@"archive"];
    return [self.cacheDirectoryURL URLByAppendingPathComponent:component isDirectory:NO];
}

+ (BOOL)entityExistsWithKey:(NSString *)key {
    return [NSFileManager.defaultManager fileExistsAtPath:[self URL:key].path];
}

+ (id)retrieveEntityOfClasses:(NSSet<Class> *)classes withKey:(NSString *)key error:(out NSError **)error {
    @try {
        NSData *data = [NSData dataWithContentsOfURL:[self URL:key]];
        if (data) {
            return [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:error];
        }
    } @catch (NSException *exception) {
        NSLog(@"retrieveEntity exception %@", exception);
    }
    return nil;
}

+ (BOOL)persistEntity:(id)object key:(NSString *)key error:(out NSError **)error {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:error];
    if (!data) {
        return NO;
    }
    NSDataWritingOptions options = NSDataWritingAtomic;
#if TARGET_OS_IPHONE
    options |= NSDataWritingFileProtectionNone;
#endif
    return [data writeToURL:[self URL:key] options:options error:error];
}

+ (BOOL)clearEntityWithKey:(NSString *)key error:(out NSError **)outError {
    NSError *error;
    BOOL success = [NSFileManager.defaultManager removeItemAtURL:[self URL:key] error:&error];
    if (!success && [error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSFileNoSuchFileError) {
        // Calls to clearEntity should be idempotent, if the archive does not exist then there is no error.
        success = YES;
        error = nil;
    }
    if (outError != NULL) {
        *outError = error;
    }
    return success;
}

+ (BOOL)clearCache:(out NSError **)error {
    NSURL *cacheDirectoryURL = self.cacheDirectoryURL;
    return [NSFileManager.defaultManager removeItemAtURL:cacheDirectoryURL error:error] && [NSFileManager.defaultManager createDirectoryAtURL:cacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:error];
}

@end
