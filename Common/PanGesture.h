//
//  PanGesture.h
//  FlickSKK
//
//  Created by mzp on 11/8/15.
//  Copyright © 2015 BAN Jun. All rights reserved.
//

#ifndef PanGesture_h
#define PanGesture_h

@interface UIPanGestureRecognizer (Private)
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

#endif /* PanGesture_h */
