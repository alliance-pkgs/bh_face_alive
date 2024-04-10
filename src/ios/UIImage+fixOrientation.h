//
//  UIImage+fixOrientation.h
//  TestCamera
//
//  Created by zzzili on 13-9-25.
//  Copyright (c) 2013年 zzzili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

+(UIImage *)scaleImage:(UIImage *)image ToSize:(CGSize)size;

+(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;

@end
