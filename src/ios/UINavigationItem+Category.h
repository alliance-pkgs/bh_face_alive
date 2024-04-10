//
//  UINavigationItem+Category.h
//  BHFaceDetect
//
//  Created by 陈贤彬 on 15/8/14.
//  Copyright (c) 2015年 BoomHope. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UINavigationItem (Category)


-(void)setBackItemWithImage:(UIImage *)image target:(UIViewController *)target selector:(SEL)selector;

-(void)setTitleViewItemWithTitleName:(NSString *)titleName;

@end
