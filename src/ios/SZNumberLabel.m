//
//  SZNumberLabel.m
//  STLivenessController
//
//  Created by sluin on 16/3/3.
//  Copyright © 2016年 SunLin. All rights reserved.
//

#import "SZNumberLabel.h"

@interface SZNumberLabel ()
{
    UIColor *_whiteColor;
    UIColor *_blackColor;
}

@end

@implementation SZNumberLabel

- (instancetype)initWithFrame:(CGRect)frame number:(int)iNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _whiteColor = [UIColor whiteColor];
        _blackColor = [UIColor blackColor];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = self.frame.size.width / 2.0f;
        self.clipsToBounds = YES;
        
        self.text = [NSString stringWithFormat:@"%d" ,iNumber];
        self.adjustsFontSizeToFitWidth = YES;
        self.font = [UIFont systemFontOfSize:frame.size.width];
        self.textAlignment = NSTextAlignmentCenter;
        self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        self.textColor = _whiteColor;
        self.backgroundColor = _blackColor;
    }
    return self;
}


- (void)setBHighlight:(BOOL)bHighlight
{
    _bHighlight = bHighlight;
    self.textColor = self.bHighlight ? _blackColor : _whiteColor;
    self.backgroundColor = self.bHighlight ? _whiteColor : _blackColor;
}



@end