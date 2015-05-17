
//
//  IOUtil.m
//  FlickSKK
//
//  Created by mzp on 2014/10/01.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOUtil.h"
#include <fstream>

@implementation IOUtil

+ (void)each: (NSString*)path with:(void (^)(NSString *str))block {
    std::ifstream ifs([path cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    std::string line;
    while (std::getline(ifs, line))
    {
        NSString *string = [NSString stringWithCString:line.c_str() encoding: NSUTF8StringEncoding];
        block(string);
    }
    ifs.close();
}

@end