//
//  BDWLivenessController.h
//  BHSoundAliveDetect
//
//  Created by DF-Mac on 17/4/28.
//  Copyright © 2017年 BoomHope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "STLivenessEnumType.h"
#import "STLivenessDetectorDelegate.h"
#import "STLivenessController.h"

#define  myMargin  20
#define  btnH  44
#define barH 64

#define backBtnH 25
#define backBtnW 13



#define buttonH  44
#define textFieldH 30
#define subviewMargin 10


#define successW 50

#define successH 50

#define sIVW 50
#define sIVH 50

#define sLW 100
#define sLH 50

#define Radius 5


#define screenH [UIScreen mainScreen].bounds.size.height

#define screenW [UIScreen mainScreen].bounds.size.width

#define ivRate screenH/568

#define ivWRate screenW/320

@protocol STLivenessControllerDelegate <NSObject>
@optional

/**
 用于获取活体验证图像的代理
 
 @param img            活体验证获得的代理
 @param viewcontroller STLivenessController该控制器是活体验证的控制器
 */
-(void)getLiveImage:(UIImage*)img FromLiveController:(UIViewController*)viewcontroller;

@end
@protocol JSObjcDelegate <JSExport>
//JSExportAs(nextAction /** js 调用别名*/,
//           - (void)nextAction:(NSNumber*)number);
- (void)nextAction;
- (void)finishByJs;

@end
@interface STLivenessController : UIViewController
//距离顶部的高度
@property (nonatomic, assign) int top;
@property (nonatomic, assign) int height;

//是否隐藏,不设置默认为不隐藏工具栏
@property (nonatomic, assign) BOOL toolViewHidden;
@property (nonatomic, assign) BOOL toolTopViewHidden;

@property (nonatomic, strong) NSURL *urlPath;
@property (nonatomic, strong) JSContext *jsContext;
/**
 *  设置语音提示默认是否开启 , 不设置时默认为YES即开启.
 */
@property (nonatomic , assign) BOOL bVoicePrompt;


/**
 STLivenessController类用于活体检测库，封装了进入活体检测所需要调用的方法。

 @param dDurationPerModel     每个模块允许的最大检测时间,小于等于0时为不设置超时时间
 @param strBundlePath         活体资源 st_liveness_resource.bundle 的路径 , 形如 @"path/st_liveness_resource.bundle"
 @param strModelPath          模型资源 M_Finance_Composite_General_Liveness_1.0.model的路径
 @param strFinanceLicensePath SenseID_Liveness.lic的路径

 @return 活体检测器实例(无)
 */
- (instancetype)initWithDuration:(double)dDurationPerModel resourcesBundlePath:(NSString *)strBundlePath modelPath:(NSString *)strModelPath financeLicensePath:(NSString *)strFinanceLicensePath;



/**
 活体检测器配置方法。

 @param delegate     回调代理
 @param queue        回调线程
 @param arrDetection 动作序列, 如 @[@(LIVE_BLINK) ,@(LIVE_MOUTH) ,@(LIVE_NOD) ,@(LIVE_YAW)] , 参照 STLivenessEnumType.h
 */
- (void)setDelegate:(id <STLivenessDetectorDelegate>)delegate callBackQueue:(dispatch_queue_t)queue detectionSequence:(NSArray *)arrDetection;

/**
 *  设置活体检测器默认输出方案及难易度, 可根据需求在 startDetection 之前调用使生效.
 *  @param iComplexity 活体检测的复杂度, 默认为 LIVE_COMPLEXITY_NORMAL
 */
- (void)setComplexity:(LivefaceComplexity)iComplexity;

/**
 *  开始检测, 检测的输出方案以及难易程度为之前最近一次调用 setOutputType:complexity: 所指定方案及难易程度.
 */
- (void)startDetection;


/**
 *  取消检测
 */
- (void)cancelDetection;



/**
 *  获取SDK版本
 *
 *  @return SDK版本
 */
+ (NSString *)getSDKVersion;


/**
 传递活体验证图像到插件的代理
 */
@property (nonatomic, weak) id<STLivenessControllerDelegate> imageDelegate;

@end
