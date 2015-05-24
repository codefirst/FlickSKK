//
//  IOUtil.h
//  FlickSKK
//
//  Created by mzp on 2014/10/01.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

#ifndef FlickSKK_IOUtil_h
#define FlickSKK_IOUtil_h

#import <Foundation/Foundation.h>

@interface IOUtil : NSObject
+ (void)each: (NSString*)path with:(void (^)(NSString *str))block;
@end

#endif
