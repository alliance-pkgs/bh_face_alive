//
//  SettingModel.m
//  BHFaceDetect
//
//  Created by 陈贤彬 on 15/8/7.
//  Copyright (c) 2015年 BoomHope. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel


+(instancetype)shareSettingModel{
    static SettingModel *setting=nil;
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
       
        setting=[[self alloc] init];
        
    });
    
    return setting;

}

@end
