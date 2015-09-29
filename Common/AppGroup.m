//
//  AppGroup.m
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/26.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

#import "AppGroup.h"

#define STR(x) @#x
#define STR2(x) STR(x)
static NSString * const kAppIdentifier = STR2(APP_IDENTIFIER);
static NSString * const kInitalText = STR2(INITIAL_TEXT);

@implementation AppGroup

+ (NSString *)appGroupID
{
    return [NSString stringWithFormat:@"group.%@", kAppIdentifier];
}

+ (NSString *)initialText
{
    return kInitalText;
}

+ (NSString *)pathForResource:(NSString *)subpath
{
    return [self urlForResource:subpath].path;
}

+ (NSURL *)urlForResource:(NSString *)subpath {
    NSURL *container = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[self appGroupID]];
    return [container URLByAppendingPathComponent:subpath];
}

@end
