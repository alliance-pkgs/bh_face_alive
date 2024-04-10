//
//  SettingModel.h
//  BHFaceDetect
//
//  Created by 陈贤彬 on 15/8/7.
//  Copyright (c) 2015年 BoomHope. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "AliveFaceRecognition.h"

@interface SettingModel : NSObject


@property (nonatomic,assign) BOOL isLivingCheck;

@property (nonatomic,assign) BOOL isShakeHead;

@property (nonatomic,assign) BOOL isOpenMouth;

@property (nonatomic,assign) BOOL isBlinkEye;

@property (nonatomic,assign) BOOL isDownHead;

@property (nonatomic,copy) NSString *severAddr;

@property (nonatomic,copy) NSString *severPort;

@property (nonatomic,copy) NSString *channel;
@property (nonatomic,copy) NSString *submitAddr;
@property (nonatomic,copy) NSString *submitPort;

//@property (nonatomic,assign) AliveType aliType;


@property (nonatomic,assign) int blinkTimes;

@property (nonatomic,assign) int openTimes;

@property (nonatomic,assign) float soundCorrectRate;

@property (nonatomic,assign) double faceLeaveOverTime;

@property (nonatomic,assign) BOOL isSearch;

@property (nonatomic,assign) NSInteger businessType;

+(instancetype)shareSettingModel;

@end
