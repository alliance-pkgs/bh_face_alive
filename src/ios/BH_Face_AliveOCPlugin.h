//
//  BH_Face_AliveOCPlugin.h
//  HelloWorld
//
//  Created by DF-Mac on 17/4/27.
//
//

#import <Cordova/CDV.h>

@interface BH_Face_AliveOCPlugin : CDVPlugin

@property (nonatomic, copy) void(^completion)(BOOL success, NSDictionary *info);

//调用活体检测
-(void)bh_face_alive:(CDVInvokedUrlCommand*)command;
//压缩图像
-(void)encode:(CDVInvokedUrlCommand*)command;

@end
