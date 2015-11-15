//
//  Haptic.h
//  FlickSKK
//
//  Created by mzp on 11/8/15.
//  Copyright © 2015 BAN Jun. All rights reserved.
//

#ifndef Haptic_h
#define Haptic_h

#import <UIKit/UIKit.h>

@interface UITapticEngine : NSObject
- (void)actuateFeedback:(int)feedbackType;
@end

@interface UIDevice (Private)
- (UITapticEngine *)_tapticEngine;
@end

#endif /* Haptic_h */
