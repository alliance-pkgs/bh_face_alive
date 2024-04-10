//
//  UILabel+BHLabel.m
//  BHVIPFaceDetectDemo
//
//  Created by 陈贤彬 on 15/7/21.
//  Copyright (c) 2015年 BoomHope. All rights reserved.
//

#import "UILabel+BHLabel.h"

@implementation UILabel (BHLabel)

+(instancetype)labelWithText:(NSString *)text textColor:(UIColor *)color frame:(CGRect)frame{
    
    UILabel *titleLabel=[[UILabel alloc] init];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.frame=frame;
    CGRect frm=titleLabel.frame;
    frm.size=CGSizeMake(100, 44);
    titleLabel.frame=frm;
    [titleLabel setTextColor:color];
    titleLabel.text=text;
    
    titleLabel.font=[UIFont boldSystemFontOfSize:20];
    
    return titleLabel;
    
}

@end
