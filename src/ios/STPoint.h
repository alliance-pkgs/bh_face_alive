//
//  STPoint.h
//  STLivenessDetector
//
//  Created by sluin on 16/2/29.
//  Copyright © 2016年 SunLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STPoint : NSObject

/**
 *  相对于原图点的水平方向坐标,为浮点数
 */
@property (nonatomic , assign) CGFloat fX;


/**
 *  相对于原图点的竖直方向坐标,为浮点数
 */
@property (nonatomic , assign) CGFloat fY;

@end
