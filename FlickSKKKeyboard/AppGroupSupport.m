//
//  AppGroupSupport.m
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 10/22/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppGroupSupport.h"

#define STR(x) @#x
#define STR2(x) STR(x)

@implementation AppGroupSupport

+ (NSString*)userName
{
    return STR2(USER);
}


@end