//
//  ToolView.m
//  BHNewFaceAlive
//
//  Created by xianbin chen on 15/10/22.
//  Copyright (c) 2015年 BoomHope. All rights reserved.
//

#import "ToolView.h"

@interface ToolView ()

@property (nonatomic,weak) UIImageView *bgView;

@end

@implementation ToolView


-(instancetype)initWithFrame:(CGRect)frame{

    
    self=[super initWithFrame:frame];
    
    if (self) {
        
        UIImageView *bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolViewbg"]];
        
        bgView.backgroundColor=[UIColor whiteColor];
        
        self.bgView=bgView;
        
        [self addSubview:bgView];
        
        UIImageView *animationView=[[UIImageView alloc] init];
        
        self.animationView=animationView;
        
        [self addSubview:animationView];
        
        
        UILabel *tickLabel=[[UILabel alloc] init];
        
        tickLabel.textAlignment=NSTextAlignmentCenter;
        tickLabel.textColor=[UIColor blackColor];
        tickLabel.font=[UIFont boldSystemFontOfSize:13];
        
        self.tickLabel=tickLabel;
        
        [self addSubview:tickLabel];
        
//        UILabel *aliveLabel=[[UILabel alloc] init];
//
//        aliveLabel.font=[UIFont boldSystemFontOfSize:13];
//
//        self.aliveLabel=aliveLabel;
//
//        aliveLabel.textAlignment=NSTextAlignmentCenter;
//        aliveLabel.textColor=[UIColor blackColor];
//
//        [self addSubview:aliveLabel];
        
        UIImageView *tickingImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ticking"]];
        
        self.tickingImageView=tickingImageView;
        [self addSubview:tickingImageView];
   
    }

    return self;
}

-(void)layoutSubviews{

    self.bgView.frame=self.bounds;
    
    CGFloat alH=15;
    CGFloat margin=1;
    
    CGFloat anH=self.frame.size.height-alH-2*margin;
    CGFloat anW=anH;
    
    CGFloat anX=(self.frame.size.width-anW)/2;
    CGFloat anY=margin;
    self.animationView.frame=CGRectMake(anX, anY, anW, anH);
    
    CGFloat alY=anY+anH+margin;
    CGFloat alW=anW;
    CGFloat alX=anX;
    self.aliveLabel.frame=CGRectMake(alX, alY, alW, alH);

    CGFloat tvWH=80;
    CGFloat tvX=self.frame.size.width/2 - 40;
    self.tickingImageView.frame=CGRectMake(tvX, 10, tvWH, tvWH);
    
    CGFloat tickW=tvWH;
    CGFloat tickH=21;
    
    CGFloat tickX=tvX;
    CGFloat tickY=CGRectGetMidY(self.tickingImageView.frame) - 10;
    
    self.tickLabel.frame=CGRectMake(CGRectGetMaxX(self.tickingImageView.frame) + 40, tickY, 40, tickH);
}


@end
