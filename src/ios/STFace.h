//
//  STFace.h
//  STLivenessDetector
//
//  Created by sluin on 16/2/29.
//  Copyright © 2016年 SunLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STRect.h"
#import "STPoint.h"

@interface STFace : NSObject

/**
 *  相对于原图人脸框的位置
 */
@property (nonatomic , strong) STRect *stRect;

/**
 *  面部关键点集合 , 元素为 STPoint 对象
 */
@property (nonatomic , copy) NSArray *arrSTPoints;

@end
