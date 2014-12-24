//
//  AppGroup.h
//  FlickSKK
//
//  Created by BAN Jun on 2014/10/26.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppGroup : NSObject

+ (NSString *)appGroupID;
+ (NSString *)initialText;
+ (NSString *)pathForResource:(NSString *)subpath;

@end
