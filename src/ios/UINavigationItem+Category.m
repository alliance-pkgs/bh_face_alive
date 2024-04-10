//
//  UINavigationItem+Category.m
//  BHFaceDetect
//
//  Created by 陈贤彬 on 15/8/14.
//  Copyright (c) 2015年 BoomHope. All rights reserved.
//

#import "UINavigationItem+Category.h"

#import "UIImage+fixOrientation.h"

#import "UILabel+BHLabel.h"

#define backBtnH 25
#define backBtnW 13

@implementation UINavigationItem (Category)


-(void)setBackItemWithImage:(UIImage *)image target:(UIViewController *)target selector:(SEL)selector{
    
    CGSize size=CGSizeMake(backBtnW, backBtnH);
    
    image=[UIImage scaleImage:image ToSize:size];
    image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.leftBarButtonItem=[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    
    
}
-(void)setTitleViewItemWithTitleName:(NSString *)titleName{

    self.titleView=[UILabel labelWithText:titleName textColor:[UIColor whiteColor] frame:self.titleView.frame];

}

@end
