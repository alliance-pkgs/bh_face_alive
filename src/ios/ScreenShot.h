//
//  ScreenShot.h
//  BHSoundAliveDetect
//
//  Created by 陈贤彬 on 16/5/20.
//  Copyright (c) 2016年 BoomHope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScreenShot : NSObject

+(UIImage *)screenShot;

+(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+(UIImage *)fixOrientation:(UIImage *)srcImg;

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;

+ (UIImage *)addImage:(UIImage *)image1 toCoverImage:(UIImage *)image2;

@end
