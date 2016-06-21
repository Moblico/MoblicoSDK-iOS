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
    static dispatch_once_t pred;
    static NSURL * documentsDirectory = nil;
    dispatch_once(&pred, ^{
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                inDomains:NSUserDomainMask];
        documentsDirectory = paths.firstObject;
    });
    
    return documentsDirectory;
}

+ (NSURL *)URL:(NSString *)key {
    NSString *component = [key stringByAppendingPathExtension:@"archive"];
    return [[self documentsURL] URLByAppendingPathComponent:component];
}

+ (BOOL)entityExistsWithKey:(NSString *)key {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self URL:key].path];
}

+ (id)retrieveEntityWithKey:(NSString *)key {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self URL:key].path];
}

+ (BOOL)persistEntity:(id)object key:(NSString *)key {
    NSString *path = [self URL:key].path;
    
    return [NSKeyedArchiver archiveRootObject:object
                                       toFile:path]
    && [[NSFileManager defaultManager] setAttributes:@{
                                                       NSFileProtectionKey:
                                                           NSFileProtectionNone
                                                       }
                                        ofItemAtPath:path
                                               error:NULL];
}

+ (BOOL)clearEntityWithKey:(NSString *)key {
    return [[NSFileManager defaultManager] removeItemAtURL:[self URL:key] error:NULL];
}

+ (BOOL)clearCache {
    __block BOOL hadError = YES;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:[self documentsURL]
                                   includingPropertiesForKeys:nil
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:NULL];
    
    
    [contents enumerateObjectsWithOptions:NSEnumerationConcurrent
                               usingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
                                   if (![fileManager removeItemAtURL:fileURL
                                                               error:NULL]) {
                                       *stop = YES;
                                       hadError = YES;
                                   }
                               }];
    
    return !hadError;
}

@end
