//
//  MLCEntityCache.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCEntityCache.h"

@implementation MLCEntityCache

+ (NSURL *)documentsURL {
    static dispatch_once_t onceToken;
    static NSURL *documentsDirectory = nil;
    dispatch_once(&onceToken, ^{
        NSArray *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        documentsDirectory = paths.firstObject;
    });

    return documentsDirectory;
}

+ (NSURL *)URL:(NSString *)key {
    NSString *component = [key stringByAppendingPathExtension:@"archive"];
    return [[self documentsURL] URLByAppendingPathComponent:component];
}

+ (BOOL)entityExistsWithKey:(NSString *)key {
    return [NSFileManager.defaultManager fileExistsAtPath:[self URL:key].path];
}

+ (id)retrieveEntityWithKey:(NSString *)key {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self URL:key].path];
}

+ (BOOL)persistEntity:(id)object key:(NSString *)key error:(out NSError **)error {
    NSString *path = [self URL:key].path;

    BOOL archived = [NSKeyedArchiver archiveRootObject:object toFile:path];

#if TARGET_OS_IOS
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionNone};
    return archived && [NSFileManager.defaultManager setAttributes:attributes ofItemAtPath:path error:error];
#endif

    return archived;
}

+ (BOOL)clearEntityWithKey:(NSString *)key error:(out NSError **)error {
    return [NSFileManager.defaultManager removeItemAtURL:[self URL:key] error:error];
}

+ (BOOL)clearCache:(out NSError **)error {
    __block BOOL hadError = YES;
    NSArray *contents = [NSFileManager.defaultManager contentsOfDirectoryAtURL:[self documentsURL]
                                                    includingPropertiesForKeys:nil
                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                         error:error];
    if (!contents) {
        return NO;
    }

    __block NSError *blockError;
    [contents enumerateObjectsWithOptions:NSEnumerationConcurrent
                               usingBlock:^(NSURL *fileURL, __unused NSUInteger idx, BOOL *stop) {
                                   if (![NSFileManager.defaultManager removeItemAtURL:fileURL
                                                                                error:&blockError]) {
                                       *stop = YES;
                                       hadError = YES;
                                   }
                               }];
    if (error) {
        *error = [blockError copy];
    }
    return !hadError;
}

@end
