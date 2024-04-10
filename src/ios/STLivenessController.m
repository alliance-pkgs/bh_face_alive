
//
//  BDWLivenessController.m
//  BHSoundAliveDetect
//
//  Created by DF-Mac on 17/4/28.
//  Copyright © 2017年 BoomHope. All rights reserved.
//

#import "STLivenessController.h"
#import "STLivenessDetector.h"
#import "STLivenessCommon.h"
#import "UIView+STLayout.h"
#import "SZNumberLabel.h"
#import "STTracker.h"

#import "UINavigationItem+Category.h"
#import "ToolView.h"
#import "UILabel+BHLabel.h"
#import "SettingModel.h"

#import "ScreenShot.h"
#import <WebKit/WebKit.h>

@interface STLivenessController ()<STLivenessDetectorDelegate,JSObjcDelegate , AVCaptureVideoDataOutputSampleBufferDelegate,WKNavigationDelegate>{
    
    dispatch_queue_t _callBackQueue;
    
    CGFloat _fImageWidth;
    CGFloat _fImageHeight;
    CGFloat _fScale;
    
    BOOL _b3_5InchScreen;
    
    
    NSArray *_arrDetection;
    
    BOOL captureImageFlag;
    
    BOOL startRecord;
    
    BOOL liveRlt;
    NSInteger liveScore;
    NSString *msg;
}

@property (nonatomic , copy) NSString *strBundlePath;

@property (nonatomic , strong) STTracker *tracker;
@property (nonatomic,  strong) STImage *faceImage;
@property (nonatomic , strong) STLivenessDetector *detector;

@property (nonatomic , weak) id <STLivenessDetectorDelegate>delegate;
//完成步骤的枚举
@property (nonatomic , assign)LivefaceDetectionType* livefaceDetectionType;

@property (nonatomic , strong) UIImageView *imageMaskView;
@property (nonatomic , strong) UIView *blackMaskView;

@property (nonatomic , strong) WKWebView *webview;
@property (nonatomic, strong) UIView *cbgView;

@property (nonatomic , strong) UIView *stepBackGroundView;
@property (nonatomic , strong) UIView *stepBGViewBGView;


@property (nonatomic , strong) UIImageView *imageAnimationBGView;
@property (nonatomic , strong) UIImageView *imageAnimationView;

@property (nonatomic , strong) UILabel *lblTrackerPrompt;

@property (nonatomic , strong) UILabel *lblCountDown;

@property (nonatomic , strong) UILabel *lblPrompt;

@property (nonatomic , strong) UIButton *btnSound;

@property (nonatomic , assign) float fCurrentPlayerVolume;

@property (nonatomic , strong) UIButton *btnBack;

@property (nonatomic , strong) AVAudioPlayer *blinkAudioPlayer;
@property (nonatomic , strong) AVAudioPlayer *mouthAudioPlayer;
@property (nonatomic , strong) AVAudioPlayer *nodAudioPlayer;
@property (nonatomic , strong) AVAudioPlayer *yawAudioPlayer;
@property (nonatomic , strong) AVAudioPlayer *currentAudioPlayer;


@property (nonatomic , strong) NSArray *arrMothImages;
@property (nonatomic , strong) NSArray *arrYawImages;
@property (nonatomic , strong) NSArray *arrPitchImages;
@property (nonatomic , strong) NSArray *arrBlinkImages;

@property (nonatomic , strong) AVCaptureDeviceInput * deviceInput;
@property (nonatomic , strong) AVCaptureVideoDataOutput * dataOutput;
@property (nonatomic , strong) AVCaptureSession *session;
@property (nonatomic , strong) AVCaptureDevice *deviceFront;
@property (nonatomic , assign) CGRect previewframe;

@property (nonatomic , assign) BOOL bShowCountDownView;

@property (nonatomic , copy) NSString *strResourcesBundlePath;

@property (nonatomic , strong) UIImage *imageSoundOn;

@property (nonatomic , strong) UIImage *imageSoundOff;

@property (nonatomic , strong) UILabel *lblStaticPrompt;
@property (nonatomic , strong) UIButton *btnStartDetect;

@property (nonatomic,weak) ToolView *toolView;

@property (nonatomic,strong) UIImage *screenShotImg;
@property (nonatomic,strong) UIImage *captureImage;

@property (nonatomic,strong) dispatch_queue_t myQueue;

@end

@implementation STLivenessController

- (instancetype)init
{
    NSLog(@" ╔—————————————————————— WARNING —————————————————————╗");
    NSLog(@" | [[STLivenessController alloc] init] is not allowed |");
    NSLog(@" |     Please use  \"initWithDuration\" , thanks !    |");
    NSLog(@" ╚————————————————————————————————————————————————————╝");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithDuration:(double)dDurationPerModel resourcesBundlePath:(NSString *)strBundlePath modelPath:(NSString *)strModelPath financeLicensePath:(NSString *)strFinanceLicensePath{
    
    self = [super init];
    if (self) {
        
        self.tracker = [[STTracker alloc]initWithModelPath:strModelPath financeLicensePath:strFinanceLicensePath];
        self.detector = [[STLivenessDetector alloc]initWithDuration:dDurationPerModel modelPath:strModelPath financeLicensePath:strFinanceLicensePath];
        
        self.bShowCountDownView = dDurationPerModel > 0;
        
        if (!strBundlePath || [strBundlePath isEqualToString:@""] || ![[NSFileManager defaultManager] fileExistsAtPath:strBundlePath]) {
            NSLog(@" ╔————————————————————————— WARNING ————————————————————————╗");
            NSLog(@" |                                                          |");
            NSLog(@" |  Please add st_liveness_resource.bundle to your project !|");
            NSLog(@" |                                                          |");
            NSLog(@" ╚——————————————————————————————————————————————————————————╝");
            return nil;
        }
        
        self.strBundlePath = strBundlePath;
        
        self.imageSoundOn = [self imageWithFullFileName:@"st_sound_on.png"];
        self.imageSoundOff = [self imageWithFullFileName:@"st_sound_off.png"];
        
        self.bVoicePrompt = YES;
        self.fCurrentPlayerVolume = 0.8;
    }
    return self;

}
- (void)setDelegate:(id <STLivenessDetectorDelegate>)delegate callBackQueue:(dispatch_queue_t)queue detectionSequence:(NSArray *)arrDetection{
    if (!arrDetection) {
        NSLog(@" ╔———————————— WARNING ————————————╗");
        NSLog(@" |                                 |");
        NSLog(@" |  Please set detection sequence !|");
        NSLog(@" |                                 |");
        NSLog(@" ╚—————————————————————————————————╝");
    }else{
        
        self.previewframe = CGRectMake(0,0, kSTScreenWidth, kSTScreenHeight);
        
        #pragma mark -调整self.previewframe的Frame
//            CGFloat tvH=90*ivRate;
        if (_height&&_top) {
            self.previewframe = CGRectMake(0,kSTScreenHeight-_height-_top, kSTScreenWidth, _height);

        }
        
        double prepareCenterX = kSTScreenWidth/2.0;
        double prepareCenterY = _height/2.0;
//        double prepareCenterY = kSTScreenHeight/2.0;
        double prepareRadius = kSTScreenWidth/2.5;
        
        [self.tracker setDelegate:self callBackQueue:queue prepareCenterPoint:CGPointMake(prepareCenterX, prepareCenterY) prepareRadius:prepareRadius];
        
        [self.detector setDelegate:self callBackQueue:queue detectionSequence:arrDetection];
        
        _arrDetection = [arrDetection mutableCopy];
        
    }
    
    if (self.delegate != delegate) {
        self.delegate = delegate;
    }
    
    if (_callBackQueue != queue) {
        _callBackQueue = queue;
    }

}
- (void)setComplexity:(LivefaceComplexity)iComplexity{
    if (self.detector) {
        [self.detector setComplexity:iComplexity];
    }
}
- (void)setBVoicePrompt:(BOOL)bVoicePrompt
{
    _bVoicePrompt = bVoicePrompt;
    
    [self setPlayerVolume];
}
- (void)startDetection
{
    [self.tracker startTracking];
}

- (void)cancelDetection
{
    [self.tracker stopTracking];
    [self.detector cancelDetection];
}

+ (NSString *)getSDKVersion
{
    return [STLivenessDetector getSDKVersion];
}
#pragma - mark -
#pragma - mark Life Cycle

- (void)loadView {
    [super loadView];
    
    _b3_5InchScreen = (kSTScreenHeight == 480);
    
    //    [self setupUI];
    
    [self displayViewsIfRunning:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat safeBottom = ([[UIScreen mainScreen] bounds].size.height<812) ? 0 : 34;
    CGFloat webViewH = screenHeight - statusBarHeight - 10;
    WKWebView *webView=[[WKWebView alloc]initWithFrame:CGRectMake(0, 0, screenW, webViewH)];
        
    self.webview=webView;
    [self.view addSubview:webView];

    if (self.urlPath) {
        [webView loadRequest:[NSURLRequest requestWithURL:self.urlPath]];
    }

    self.webview.navigationDelegate=self;
    
    if (_top &&_height) {
        UIView *cbgView=[[UIView alloc]initWithFrame:CGRectMake(0, _top, screenW, _height)];
        self.cbgView=cbgView;
        cbgView.backgroundColor=[UIColor clearColor];
        [self.webview.scrollView addSubview:cbgView];
//            [self.webview.scrollView insertSubview:cbgView atIndex:1];
    }else{
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat safeBottom = ([[UIScreen mainScreen] bounds].size.height<812) ? 0 : 34;
            
        CGFloat fViewHeight = screenHeight - 50 - 100 - statusBarHeight - 10 - safeBottom;;
//            self.imageMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30+64, kSTScreenWidth, fViewHeight-30-64)];
        UIView *cbgView=[[UIView alloc]initWithFrame:CGRectMake(0, 30+64, kSTScreenWidth, fViewHeight)];
        [self.webview.scrollView addSubview:cbgView];
    }

    BOOL bSetupCaptureSession = [self setupCaptureSession];
    
    if (!bSetupCaptureSession) {
        return;
    }
    
    
    [self setupAudio];
    
     [self setupUI];
    
    
    //    设置代理
    
    //    获取上一个控制器
//    NSArray *childVCs=self.navigationController.childViewControllers;
//    NSInteger count=childVCs.count;

    NSString *daStr = @"myQueue";
    const char *queueName = [daStr UTF8String];
    dispatch_queue_t myQueue = dispatch_queue_create(queueName, NULL);
    
    self.myQueue=myQueue;
    
    startRecord=YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.detector && self.session && self.dataOutput && ![self.session isRunning]) {
            [self.session startRunning];
            [self cameraStart];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            captureImageFlag=YES;
        });
    });
}

- (void)dealloc
{
    if (self.session) {
        [self.session beginConfiguration];
        [self.session removeOutput:self.dataOutput];
        [self.session removeInput:self.deviceInput];
        [self.session commitConfiguration];
        
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
        self.session = nil;
    }
    
    if ([self.currentAudioPlayer isPlaying]) {
        [self.currentAudioPlayer stop];
    }
    
    if ([self.imageAnimationView isAnimating]) {
        [self.imageAnimationView stopAnimating];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma - mark -
#pragma - mark Private Methods

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImage *imageMask = [self imageWithFullFileName:@"st_mask_b@2x.png"];
    
    UIImage *imageMouth1 = [self imageWithFullFileName:@"st_mounth1.png"];
    UIImage *imageMouth2 = [self imageWithFullFileName:@"st_mounth1.png"];
    
    UIImage *imagePitch1 = [self imageWithFullFileName:@"st_pitch1.png"];
    UIImage *imagePitch2 = [self imageWithFullFileName:@"st_pitch2.png"];
    UIImage *imagePitch3 = [self imageWithFullFileName:@"st_pitch3.png"];
    UIImage *imagePitch4 = [self imageWithFullFileName:@"st_pitch4.png"];
    UIImage *imagePitch5 = [self imageWithFullFileName:@"st_pitch5.png"];
    
    
    UIImage *imageBlink1 = [self imageWithFullFileName:@"st_blink1.png"];
    UIImage *imageBlink2 = [self imageWithFullFileName:@"st_blink2.png"];
    
    UIImage *imageYaw1 = [self imageWithFullFileName:@"st_yaw1.png"];
    UIImage *imageYaw2 = [self imageWithFullFileName:@"st_yaw2.png"];
    UIImage *imageYaw3 = [self imageWithFullFileName:@"st_yaw3.png"];
    UIImage *imageYaw4 = [self imageWithFullFileName:@"st_yaw4.png"];
    UIImage *imageYaw5 = [self imageWithFullFileName:@"st_yaw5.png"];
    
    self.arrMothImages = [NSArray arrayWithObjects:imageMouth1 , imageMouth2, nil];
    
    self.arrPitchImages = [NSArray arrayWithObjects:imagePitch1 , imagePitch2 , imagePitch3 , imagePitch4, imagePitch5, imagePitch4 , imagePitch3 , imagePitch2, nil];
    self.arrBlinkImages = [NSArray arrayWithObjects:imageBlink1 , imageBlink2, nil];
    self.arrYawImages = [NSArray arrayWithObjects:imageYaw1 , imageYaw2 , imageYaw3, imageYaw4, imageYaw5, imageYaw4, imageYaw3, imageYaw2 ,nil];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    BOOL bNavigationBarHidden = self.navigationController.navigationBar.hidden;
    
    CGFloat fBarHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CGFloat fViewHeight = self.view.frame.size.height-_top;
    
    if (!bNavigationBarHidden) {
        fViewHeight = kSTScreenHeight - fBarHeight;
    }

    if (_height) {
        fViewHeight=_height;
    }
    #pragma mark -调整self.imageMaskView(即人像边缘)的Frame

    self.imageMaskView = [[UIImageView alloc] init];

    if (_top&&_height) {

        self.imageMaskView =[[UIImageView alloc]initWithFrame:self.cbgView.bounds];
        }

    self.imageMaskView.image = imageMask;
    self.imageMaskView.userInteractionEnabled = YES;
    self.imageMaskView.contentMode = UIViewContentModeScaleAspectFill;

    self.imageMaskView.clipsToBounds=YES;
    
    [self.cbgView addSubview:self.imageMaskView];

    
//    self.blackMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSTScreenWidth, fViewHeight)];
     self.blackMaskView = [[UIView alloc] initWithFrame:self.imageMaskView.bounds];
    

    self.blackMaskView.backgroundColor = [UIColor blackColor];
    self.blackMaskView.alpha = 0.3;
    [self.imageMaskView addSubview:self.blackMaskView];
    //[self.webview.scrollView addSubview:self.blackMaskView];
    self.stepBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _arrDetection.count * 20.0 + (_arrDetection.count - 1) * 10.0, 20.0)];
    self.stepBackGroundView.backgroundColor = [UIColor clearColor];
    self.stepBackGroundView.hidden = YES;
    self.stepBackGroundView.stCenterX = kSTScreenWidth / 2.0;
    self.stepBackGroundView.stBottom = self.imageMaskView.stBottom - 20;
    self.stepBackGroundView.userInteractionEnabled = NO;
    
    
    self.stepBGViewBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.stepBackGroundView.frame.size.width + 6.0, self.stepBackGroundView.frame.size.height + 6.0)];
    self.stepBGViewBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.stepBGViewBGView.layer.cornerRadius = self.stepBGViewBGView.frame.size.height / 2.0;
    self.stepBGViewBGView.center = self.stepBackGroundView.center;
    self.stepBGViewBGView.hidden = YES;
    [self.imageMaskView addSubview:self.stepBGViewBGView];
    [self.imageMaskView addSubview:self.stepBackGroundView];
    
    for (int i = 0; i < _arrDetection.count;  i ++) {
        
        SZNumberLabel *lblStepNumber = [[SZNumberLabel alloc] initWithFrame:CGRectMake(i * 25.0 + i * 5.0, 0, 20.0, 20.0) number:i + 1];
        lblStepNumber.tag = i + kSTViewTagBase;
        [self.stepBackGroundView addSubview:lblStepNumber];
    }
    
    self.stepBGViewBGView.hidden=YES;
    self.stepBackGroundView.hidden=YES;
    
    self.imageAnimationBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSTScreenWidth, 150.0)];
    self.imageAnimationBGView.stBottom = self.stepBGViewBGView.stTop - 16.0;
    [self.imageMaskView addSubview:self.imageAnimationBGView];
    
    CGFloat fAnimationViewWidth = 100.0;
    
    self.imageAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake((kSTScreenWidth - fAnimationViewWidth) / 2, 0, fAnimationViewWidth, fAnimationViewWidth)];
    self.imageAnimationView.stY = self.imageAnimationBGView.stHeight - self.imageAnimationView.stHeight;
    self.imageAnimationView.animationDuration = 2.0f;
    self.imageAnimationView.layer.cornerRadius = self.imageAnimationView.frame.size.width / 2;
    self.imageAnimationView.backgroundColor = kSTColorWithRGB(0xC8C8C8);
    [self.imageAnimationBGView addSubview:self.imageAnimationView];
    
    self.imageAnimationBGView.hidden=YES;
    
    float fLabelCountDownWidth = 45.0;
    
    self.lblCountDown = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fLabelCountDownWidth , fLabelCountDownWidth)];
    self.lblCountDown.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.lblCountDown.textColor = [UIColor whiteColor];
    self.lblCountDown.stRight = self.imageMaskView.stWidth - 14.0;
    self.lblCountDown.stCenterY = self.imageAnimationView.stCenterY + self.imageAnimationBGView.stTop;
    self.lblCountDown.layer.cornerRadius = fLabelCountDownWidth / 2.0f;
    self.lblCountDown.clipsToBounds = YES;
    self.lblCountDown.adjustsFontSizeToFitWidth = YES;
    self.lblCountDown.font = [UIFont systemFontOfSize:fLabelCountDownWidth / 2.0f];
    self.lblCountDown.textAlignment = NSTextAlignmentCenter;
    self.lblCountDown.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self.imageMaskView addSubview:self.lblCountDown];
    
    self.lblCountDown.hidden=YES;
    
    self.lblPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0, 38.0)];
    self.lblPrompt.center = CGPointMake(self.imageAnimationView.stCenterX, self.imageAnimationView.stTop - 14.0 - 19.0);
    self.lblPrompt.font = [UIFont systemFontOfSize:20];
    self.lblPrompt.textAlignment = NSTextAlignmentCenter;
    self.lblPrompt.textColor = [UIColor whiteColor];
    self.lblPrompt.layer.cornerRadius = self.lblPrompt.stHeight / 2.0;
    self.lblPrompt.layer.masksToBounds = YES;
    self.lblPrompt.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.imageAnimationBGView addSubview:self.lblPrompt];
    
    self.lblPrompt.hidden=YES;
    
    self.btnStartDetect = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnStartDetect.frame = CGRectMake(0, 0, (kSTScreenWidth - 40.0), 45.0);
    self.btnStartDetect.stLeft = 20.0;
    self.btnStartDetect.stBottom = self.imageMaskView.stBottom - 10.0;
    self.btnStartDetect.layer.cornerRadius = 5.0;
    self.btnStartDetect.backgroundColor = [UIColor whiteColor];
    [self.btnStartDetect setTitle:@"Start detection" forState:UIControlStateNormal];
    [self.btnStartDetect setTitleColor:kSTColorWithRGB(0x398af3) forState:UIControlStateNormal];
    [self.btnStartDetect addTarget:self action:@selector(onBtnStartDetect) forControlEvents:UIControlEventTouchUpInside];
    [self.imageMaskView addSubview:self.btnStartDetect];
    
    self.btnStartDetect.hidden=YES;
    
    self.lblStaticPrompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kSTScreenWidth, 100)];
    self.lblStaticPrompt.text = @"Please do it in a bright, light environment \nPlease remove the objects that will block the face, including the glasses \nKeep it in the center of the screen to avoid turning your head or moving out of the screen";
    
    self.lblStaticPrompt.hidden=YES;
    
    self.lblStaticPrompt.stBottom = _b3_5InchScreen ? self.btnStartDetect.stTop : self.btnStartDetect.stTop - 5;
    CGFloat fFontSize = 0;
    
    if (_b3_5InchScreen) {
        fFontSize = 17;
    }else if (kSTScreenHeight > 568){
        fFontSize = 21;
    }else{
        fFontSize = 18;
    }
    
    self.lblStaticPrompt.font = [UIFont systemFontOfSize:fFontSize];
    self.lblStaticPrompt.textAlignment = NSTextAlignmentCenter;
    self.lblStaticPrompt.textColor = [UIColor whiteColor];
    self.lblStaticPrompt.numberOfLines = 0;
    if (kSTScreenHeight == 480) {
        [self.lblStaticPrompt sizeToFit];
    }
    self.lblStaticPrompt.stLeft = (kSTScreenWidth - self.lblStaticPrompt.stWidth) / 2;
    [self.imageMaskView addSubview:self.lblStaticPrompt];
    
    UIButton *btnSound = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSound setFrame:CGRectMake(kSTScreenWidth - 60.0, 20, 40.0, 40.0)];
    [btnSound setImage:self.bVoicePrompt ? self.imageSoundOn : self.imageSoundOff forState:UIControlStateNormal];
    [btnSound addTarget:self action:@selector(onBtnSound) forControlEvents:UIControlEventTouchUpInside];
    [self.imageMaskView addSubview:btnSound];
    self.btnSound = btnSound;
    
    btnSound.hidden=YES;
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(20, 20.0, 40.0, 40.0)];
    //[btnBack setImage:[self imageWithFullFileName:@"st_scan_back.png"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(onBtnBack) forControlEvents:UIControlEventTouchUpInside];
    [self.imageMaskView addSubview:btnBack];
    self.btnBack = btnBack;
    
    btnBack.hidden=YES;
    
    
    [self.navigationItem setBackItemWithImage:[UIImage imageNamed:@"back"] target:self selector:@selector(back)];
    
    //    添加提示label
    
    UIView *labelView=[[UIView alloc] init];
    labelView.backgroundColor=[UIColor whiteColor];
    CGFloat lvH=40*ivRate;
    CGFloat lvW=self.view.frame.size.width;
    CGFloat lvX=0;
    CGFloat lvY=0;
    labelView.frame=CGRectMake(lvX, lvY-lvH, lvW, lvH);
#pragma mark - 提示label
    [self.cbgView addSubview:labelView];
//    labelView.frame=CGRectMake(lvX, lvY+_top-lvH, lvW, lvH);
    //[self.webview.scrollView addSubview:labelView];
    labelView.hidden=_toolTopViewHidden;
    //
    UILabel *label=[[UILabel alloc] init];
    label.text=@"Please keep your face in the box";
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont boldSystemFontOfSize:15];
    label.textColor=[UIColor lightGrayColor];
    
    CGFloat lbH=lvH;
    CGFloat margin=30;
    CGFloat lbX=margin;
    CGFloat lbW=labelView.frame.size.width-2*margin;
    
    label.frame=CGRectMake(lbX, 0, lbW, lbH);
    self.lblTrackerPrompt=label;
    [labelView addSubview:label];

    ToolView *toolView=[[ToolView alloc] init];
    toolView.animationView.image=[self imageWithFullFileName:@"st_mouth1.png"];
    self.toolView=toolView;
    
    CGFloat tvH=100;
    CGFloat tvW=self.view.frame.size.width;
    CGFloat tvX=0;
    CGFloat tvY=CGRectGetMaxY(self.cbgView.frame);
    toolView.frame=CGRectMake(tvX, tvY, tvW, tvH);
    toolView.hidden=_toolViewHidden;
    [self.webview addSubview:toolView];
    
    self.imageAnimationView=toolView.animationView;
    
//    self.lblPrompt=toolView.aliveLabel;
    
    self.lblCountDown=toolView.tickLabel;
  
}

-(void)back{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupAudio
{
    NSString *strBlinkPath = [self audioPathWithFullFileName:@"st_notice_blink.wav"];
    self.blinkAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strBlinkPath] error:nil];
    self.blinkAudioPlayer.volume = self.fCurrentPlayerVolume;
    self.blinkAudioPlayer.numberOfLoops = 0;
    [self.blinkAudioPlayer prepareToPlay];
    
    NSString *strMouthPath = [self audioPathWithFullFileName:@"st_notice_mouth.wav"];
    self.mouthAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strMouthPath] error:nil];
    self.mouthAudioPlayer.volume = _fCurrentPlayerVolume;
    self.mouthAudioPlayer.numberOfLoops = 0;
    [self.mouthAudioPlayer prepareToPlay];
    
    NSString *strNodPath = [self audioPathWithFullFileName:@"st_notice_nod.wav"];
    self.nodAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strNodPath] error:nil];
    self.nodAudioPlayer.volume = _fCurrentPlayerVolume;
    self.nodAudioPlayer.numberOfLoops = 0;
    [self.nodAudioPlayer prepareToPlay];
    
    NSString *strYawPath = [self audioPathWithFullFileName:@"st_notice_yaw.wav"];
    self.yawAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strYawPath] error:nil];
    self.yawAudioPlayer.volume = _fCurrentPlayerVolume;
    self.yawAudioPlayer.numberOfLoops = 0;
    [self.yawAudioPlayer prepareToPlay];
}

- (BOOL)setupCaptureSession
{
    
    self.session = [[AVCaptureSession alloc] init];
    // iPhone 4S, +
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    _fImageWidth = 640.0;
    _fImageHeight = 480.0;
    
    _fScale = [UIScreen mainScreen].scale;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    //captureVideoPreviewLayer.frame = self.previewframe;
    captureVideoPreviewLayer.frame = self.cbgView.bounds;
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.cbgView.layer addSublayer:captureVideoPreviewLayer];
    [self.cbgView bringSubviewToFront:self.blackMaskView];
    [self.cbgView bringSubviewToFront:self.imageMaskView];
//    [self.view.layer addSublayer:captureVideoPreviewLayer];
//    [self.view bringSubviewToFront:self.blackMaskView];
//    [self.view bringSubviewToFront:self.imageMaskView];
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionFront) {
                self.deviceFront = device;
            }
        }
    }
    
    int frameRate;
    CMTime frameDuration = kCMTimeInvalid;
    
    frameRate = 30;
    frameDuration = CMTimeMake( 1, frameRate );
    
    NSError *error = nil;
    if ( [self.deviceFront lockForConfiguration:&error] ) {
        self.deviceFront.activeVideoMaxFrameDuration = frameDuration;
        self.deviceFront.activeVideoMinFrameDuration = frameDuration;
        [self.deviceFront unlockForConfiguration];
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.deviceFront error:&error];
    self.deviceInput = input;
    
    
    if (!input) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidFailWithErrorType:detectionType:detectionIndex:data:stImages:)]) {
            dispatch_async(_callBackQueue, ^{
                [self.delegate livenessDidFailWithErrorType:LIVENESS_CAMERA_ERROR detectionType:[[_arrDetection firstObject] integerValue] detectionIndex:0 data:nil stImages:nil];
            });
        }
        return NO;
    }
    
    
    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    [self.dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    [self.dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    dispatch_queue_t queueBuffer = dispatch_queue_create("LIVENESS_BUFFER_QUEUE", NULL);
    
    [self.dataOutput setSampleBufferDelegate:self queue:queueBuffer];
    
    [self.session beginConfiguration];
    
    if ([self.session canAddOutput:self.dataOutput]) {
        [self.session addOutput:self.dataOutput];
    }
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    [self.session commitConfiguration];
    
    return YES;
}

- (UIImage *)imageWithFullFileName:(NSString *)strFileName
{
    NSString *strFilePath = [NSString pathWithComponents:@[self.strBundlePath , @"images" , strFileName]];
    NSLog(@"strFilePath=%@",strFilePath);
    return [UIImage imageWithContentsOfFile:strFilePath];
}

- (NSString *)audioPathWithFullFileName:(NSString *)strFileName
{
    NSString *strFilePath = [NSString pathWithComponents:@[self.strBundlePath , @"sounds" , strFileName]];
    return strFilePath;
}
- (void)displayViewsIfRunning:(BOOL)bRunning
{
    self.blackMaskView.hidden = bRunning;
    self.imageAnimationView.hidden = NO;
    self.lblPrompt.hidden = NO;
#pragma mark- 用于显示底部的步骤(最初)图示
//    self.stepBackGroundView.hidden = !bRunning;
//    self.stepBGViewBGView.hidden = !bRunning;
    self.stepBackGroundView.hidden = YES;
    self.stepBGViewBGView.hidden = YES;
    self.lblCountDown.hidden = self.bShowCountDownView ? !bRunning : YES;
    
    
    //    self.lblTrackerPrompt.hidden = bRunning;
    //    self.lblTrackerPrompt.text = @"";
}
- (void)showPromptWithDetectionType:(LivefaceDetectionType)iType detectionIndex:(int)iIndex
{
    //我添加的全局枚举
    self.livefaceDetectionType=&(iType);
    
    if (self.currentAudioPlayer) {
        
        [self stopAudioPlayer];
    }
    
    SZNumberLabel *lblNumber = [self.stepBackGroundView viewWithTag:kSTViewTagBase + iIndex];
    lblNumber.bHighlight = YES;
    
    if ([self.imageAnimationView isAnimating]) {
        [self.imageAnimationView stopAnimating];
    }
    
    CATransition *transion = [CATransition animation];
    transion.type = @"push";
    transion.subtype = @"fromRight";
    transion.duration = 0.5f;
    transion.removedOnCompletion = YES;
    [self.imageAnimationBGView.layer addAnimation:transion forKey:nil];
#pragma mark - 在此处将iType类型传出
//    self.livefaceDetectionType=&(iType);
//    [self call];
    self.lblTrackerPrompt.textColor = [UIColor blackColor];
    switch (iType) {
        case LIVE_YAW:
        {
            self.lblTrackerPrompt.text = @"Shake your head";
            self.imageAnimationView.animationDuration = 2.0f;
            self.imageAnimationView.animationImages = self.arrYawImages;
            self.currentAudioPlayer = self.yawAudioPlayer;
            [self nextAction];
            self.livefaceDetectionType=&(iType);

            break;
        }
        
        case LIVE_BLINK:
        {
            self.lblTrackerPrompt.text = @"Blink your eye";
            self.imageAnimationView.animationDuration = 1.0f;
            self.imageAnimationView.animationImages = self.arrBlinkImages;
            self.currentAudioPlayer = self.blinkAudioPlayer;
            [self nextAction];
            self.livefaceDetectionType=&(iType);

            break;
        }
        
        case LIVE_MOUTH:
        {
            self.lblTrackerPrompt.text = @"Open your mouth";
            self.imageAnimationView.animationDuration = 1.0f;
            self.imageAnimationView.animationImages = self.arrMothImages;
            self.currentAudioPlayer = self.mouthAudioPlayer;
            self.livefaceDetectionType=&(iType);
//            [self call];
            [self nextAction];

            break;
        }
        case LIVE_NOD:
        {
            self.lblTrackerPrompt.text = @"Nod your head";
            self.imageAnimationView.animationDuration = 2.0f;
            self.imageAnimationView.animationImages = self.arrPitchImages;
            self.currentAudioPlayer = self.nodAudioPlayer;
//            [self call];
            [self nextAction];
            self.livefaceDetectionType=&(iType);
           
            break;
        }
        case LIVE_NONE:
        {
            break;
        }
    }
    
    if (![self.imageAnimationView isAnimating]) {
        [self.imageAnimationView startAnimating];
    }
    
    if (self.currentAudioPlayer) {

        [self stopAudioPlayer];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
        [self.currentAudioPlayer play];
    }
}
- (void)stopAudioPlayer
{
    if ([self.currentAudioPlayer isPlaying]) {
        [self.currentAudioPlayer stop];
    }
    
    self.currentAudioPlayer.currentTime = 0;
}

- (void)clearStepViewAndStopSound
{
    if (self.currentAudioPlayer) {
        
        [self stopAudioPlayer];
    }
    for (SZNumberLabel *lblNumber in self.stepBackGroundView.subviews) {
        lblNumber.bHighlight = NO;
    }
}

- (void)setPlayerVolume
{
    [self.btnSound setImage:self.bVoicePrompt ? self.imageSoundOn : self.imageSoundOff forState:UIControlStateNormal];
    
    self.fCurrentPlayerVolume = self.bVoicePrompt ? 0.8 : 0;
    
    self.blinkAudioPlayer.volume = self.fCurrentPlayerVolume;
    self.mouthAudioPlayer.volume = self.fCurrentPlayerVolume;
    self.nodAudioPlayer.volume = self.fCurrentPlayerVolume;
    self.yawAudioPlayer.volume = self.fCurrentPlayerVolume;
    
}
- (void)cameraStart
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if (granted) {
                    [self.tracker startTracking];
                }else{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidFailWithErrorType:detectionType:detectionIndex:data:stImages:)]) {
                        dispatch_async(_callBackQueue, ^{
                            
                            [self.delegate livenessDidFailWithErrorType:LIVENESS_CAMERA_ERROR detectionType:LIVE_BLINK detectionIndex:0 data:nil stImages:nil];
                        });
                    }
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            [self.tracker startTracking];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidFailWithErrorType:detectionType:detectionIndex:data:stImages:)]) {
                dispatch_async(_callBackQueue, ^{
                    
                    [self.delegate livenessDidFailWithErrorType:LIVENESS_CAMERA_ERROR detectionType:LIVE_BLINK detectionIndex:0 data:nil stImages:nil];
                });
            }
            break;
        }
        default:
        break;
    }
    
    //    if (self.session && [self.session isRunning] && self.detector) {
    //        [self.detector startDetection];
    //    }
}
#pragma - mark -
#pragma - mark Event Response

- (void)onBtnBack
{
    [self cancelDetection];
}

- (void)onBtnStartDetect
{
    [self cameraStart];
}

- (void)onBtnSound
{
    self.bVoicePrompt = !self.bVoicePrompt;
    
    [self setPlayerVolume];
}


#pragma - mark -
#pragma - mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (captureImageFlag) {
        
        captureImageFlag=NO;
        
        UIImage *image=[self imageFromSampleBuffer:sampleBuffer];
        
        image=[ScreenShot image:image rotation:UIImageOrientationRight];
        
        _screenShotImg=[ScreenShot screenShot];
        
        _screenShotImg=[ScreenShot addImage:_screenShotImg toImage:image];
        
        UIImage *coverImg=[self imageWithFullFileName:@"st_mask_b@2x.png"];
        
        _screenShotImg=[ScreenShot addImage:_screenShotImg toImage:coverImg];
        
    }
    
    if (self.tracker) {
        [self.tracker trackWithCMSanmpleBuffer:sampleBuffer faceOrientaion:LIVE_FACE_LEFT];
    }
    if (self.detector) {
        [self.detector trackAndDetectWithCMSampleBuffer:sampleBuffer faceOrientaion:LIVE_FACE_LEFT];
    }
    
    //    录制视频
    //    [self.videoRecorder recordVideo:sampleBuffer captureOutput:captureOutput dataOutput:connection.output];
}

//-(void)record{
//
//    if (_sampleBuffer && _captureOutput && _connection && self.videoRecorder) {
//        [self.videoRecorder recordVideo:_sampleBuffer captureOutput:_captureOutput dataOutput:_connection.output];
//    }
//
//}

#pragma - mark -
#pragma - mark STLivenessDetectorDelegate

- (void)livenessFaceRect:(STRect *)rect{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(livenessFaceRect:)]) {
        dispatch_async(_callBackQueue, ^{
            [self.delegate livenessFaceRect:rect];
        });
    }
}

- (void)livenessTrackerStatus:(LivefaceErrorType)status{
    
    self.lblTrackerPrompt.textColor = [UIColor lightGrayColor];
    switch (status) {
        case LIVENESS_FINANCELICENS_FILE_NOT_FOUND:
        NSLog(@"...............1");
        case LIVENESS_FINANCELICENS_CHECK_LICENSE_FAIL:
        NSLog(@"...............2");
        case LIVENESS_MODELSBUNDLE_FILE_NOT_FOUND:
        NSLog(@"...............3");
        case LIVENESS_MODELSBUNDLE_CHECK_MODEL_FAIL:
        NSLog(@"...............4");
        case LIVENESS_INVALID_APPID:
        NSLog(@"...............5");
        case LIVENESS_AUTH_EXPIRE:
        {
            NSLog(@"...............6");
            if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidFailWithErrorType:detectionType:detectionIndex:data:stImages:)]) {
                dispatch_async(_callBackQueue, ^{
                    [self.delegate livenessDidFailWithErrorType:status detectionType:LIVE_BLINK detectionIndex:0 data:nil stImages:nil];
                });
            }
            break;
        }
        case LIVENESS_NOFACE:
        {
            NSLog(@"...............7");
            self.lblTrackerPrompt.text = @"Move your face into the box";
            break;
        }
        case LIVENESS_FACE_TOO_FAR:
        {
            NSLog(@"...............8");
            self.lblTrackerPrompt.text = @"Move the phone near your face";
            break;
        }
        case LIVENESS_FACE_TOO_CLOSE:
        {
            NSLog(@"...............9");
            self.lblTrackerPrompt.text = @"Move the phone away from your face";
            break;
        }
        
        case LIVENESS_DETECTING:
        {
            NSLog(@"...............10");
            self.lblTrackerPrompt.text = @"Ready to start detection";
            break;
        }
        case LIVENESS_SUCCESS:
        {
            NSLog(@"...............11");
            self.lblTrackerPrompt.text = @"";
            [self.tracker stopTracking];
            if (self.session && [self.session isRunning] && self.detector) {
                [self.detector startDetection];
            }
            break;
        }
        case LIVENESS_WILL_RESIGN_ACTIVE:
        {
            NSLog(@"...............12");
            self.lblTrackerPrompt.text = @"";
            [self.tracker stopTracking];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please keep the program running in the foreground and try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert show];
            break;
        }
        default:
        NSLog(@"...............13");
        break;
    }
}

- (void)livenessDidStartDetectionWithDetectionType:(LivefaceDetectionType)iDetectionType detectionIndex:(int)iDetectionIndex
{
    
    [self displayViewsIfRunning:YES];
    [self showPromptWithDetectionType:iDetectionType detectionIndex:iDetectionIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidStartDetectionWithDetectionType:detectionIndex:)]) {
        dispatch_async(_callBackQueue, ^{
            [self.delegate livenessDidStartDetectionWithDetectionType:iDetectionType detectionIndex:iDetectionIndex];
        });
    }
}

- (void)livenessTimeDidPast:(double)dPast durationPerModel:(double)dDurationPerModel
{
    if (dDurationPerModel != 0) {
        self.lblCountDown.text = [NSString stringWithFormat:@"%d" , ((int)dDurationPerModel - (int)dPast)];
        if (self.delegate && [self.delegate respondsToSelector:@selector(livenessTimeDidPast:durationPerModel:)]) {
            dispatch_async(_callBackQueue, ^{
                [self.delegate livenessTimeDidPast:dPast durationPerModel:dDurationPerModel];
            });
        }
    }
}

- (void)videoFrameRate:(int)rate{
    
    //    printf("%d FPS\n",rate);
    
}

- (void)livenessDidSuccessfulGetData:(NSData *)data stImages:(NSArray *)arrSTImage
{
    
    
    [self clearStepViewAndStopSound];
    [self displayViewsIfRunning:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(livenessDidSuccessfulGetData:stImages:)]) {
        dispatch_async(_callBackQueue, ^{
            [self.delegate livenessDidSuccessfulGetData:data stImages:arrSTImage];
        });
    }
    
    self.faceImage=arrSTImage[0];
    
    //    CGFloat width=self.faceImage.image.size.width;
    //    CGFloat height=self.faceImage.image.size.height;
    //
    //    CGFloat imgX=width*0.12;
    //    CGFloat imgY=height*0.12;
    //
    //    CGFloat imgW=width-2*imgX;
    //    CGFloat imgH=height-imgY*3;
    //
    //    CGRect imgRect=CGRectMake(imgX, imgY, imgW, imgH);
    //
    //    self.faceImage.image=[self imageFromImage:self.faceImage.image inRect:imgRect];
    //
    //
    //    //    CGSize size=CGSizeMake(self.faceImage.image.size.width*0.8, self.faceImage.image.size.height*0.8);
    //
    //    self.faceImage.image=[self scaleImage:self.faceImage.image toScale:0.7];
    
    
//    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
//    
//    int isSecDect=[[userDefault valueForKey:@"secDetect"] intValue];
//    
//    SettingModel *setting=[SettingModel shareSettingModel];
//    
//    BOOL isLiveCheck=setting.isLivingCheck;
    
    [self secondDectSubbmit];
    
    liveRlt=YES;
    
    liveScore=100;
    
    msg=@"";
}
-(void)livenessDidCancelWithDetectionType:(LivefaceDetectionType)iDetectionType detectionIndex:(int)iDetectionIndex{
    
}
//检测失败的回调(例如:请眨眼...十秒钟过去仍没检测到眨眼,会关闭)
-(void)livenessDidFailWithErrorType:(LivefaceErrorType)iErrorType detectionType:(LivefaceDetectionType)iDetectionType detectionIndex:(int)iDetectionIndex data:(NSData *)data stImages:(NSArray *)arrSTImage{
    
    // UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"Detection failed" message:@"Please redo face detection" preferredStyle:UIAlertControllerStyleAlert];
    
    // [alertVC addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //     [self dismissViewControllerAnimated:YES completion:nil];
    // }]];
    
    // [self presentViewController:alertVC animated:YES completion:nil];

    [self dismissViewControllerAnimated:YES completion:nil]; 

    id<STLivenessDetectorDelegate> strongDelegate = self.delegate; 

    if ([strongDelegate respondsToSelector:@selector(livenessDidFailWithErrorType:detectionType:detectionIndex:data:stImages:)]) { 
        [strongDelegate livenessDidFailWithErrorType:iErrorType detectionType:iDetectionType detectionIndex:iDetectionIndex data:data stImages:arrSTImage]; 
    } 
}
#pragma mark - 视频流转为图像

#define clamp(a) (a>255?255:(a<0?0:a))

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationLeftMirrored];
    CGImageRelease(quartzImage);
    
    return image;
}
-(void)secondDectSubbmit{
    
    //    将图片转为data格式
    //NSData *faceImageData=UIImageJPEGRepresentation(self.faceImage.image, 1.0);
    //    将data转化为base64格式的字符串
    //NSString *faceImageStr=[faceImageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    //该代理方法将图片image传到上一页面
    
    if([_imageDelegate respondsToSelector:@selector(getLiveImage:FromLiveController:)]){
        [_imageDelegate getLiveImage:self.faceImage.image FromLiveController:self];
    }
    

    
    
    //                    先进行后台二次成像检测
    NSLog(@"正在提交.....");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self dismissViewControllerAnimated:YES completion:nil];

    });

}
#pragma mark -WKNavigationDelegate
-(void)didFinishNavigation:(WKWebView *)webView{
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"bh_js"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };

}
//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSString *url=[[request URL] absoluteString];
//     NSLog(@"%@",url);
//    //代码中根据返回的URL或者scheme来判断处理不同逻辑
//    if ([url isEqualToString:@"file:///"])
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    return YES;
//}

#pragma mark - JS-OC delegate


//传递
- (void)nextAction{
    
    
    NSLog(@"nextAction");
    // 之后在回调js的方法Callback把内容传出去
    JSValue *Callback = self.jsContext[@"nextAction"];

    NSString*a=[NSString stringWithFormat:@"%d",(int)*self.livefaceDetectionType];
    NSString *stringdata = [NSString stringWithFormat:@"%@",a];
    int data=[stringdata intValue];
    //传值给web端
    [Callback callWithArguments:@[@(data)]];
}
- (void)finishByJs{
    NSLog(@"finishByJs");

    // 之后在回调js的方法Callback把内容传出去
    JSValue *Callback = self.jsContext[@"finishByJs"];

    //传值给web端
    [Callback callWithArguments:nil];
    [self cancelDetection];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

@end
