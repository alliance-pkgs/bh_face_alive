//
//  SZNumberLabel.h
//  STLivenessController
//
//  Created by sluin on 16/3/3.
//  Copyright © 2016年 SunLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SZNumberLabel : UILabel

@property (nonatomic , assign) BOOL bHighlight;

- (instancetype)initWithFrame:(CGRect)frame number:(int)iNumber;


@end
