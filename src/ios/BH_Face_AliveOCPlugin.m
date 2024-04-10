//
//  BH_Face_AliveOCPlugin.m
//  HelloWorld
//
//  Created by DF-Mac on 17/4/27.
//
//

#import "BH_Face_AliveOCPlugin.h"
#import "STLivenessController.h"
#import "SettingModel.h"
@interface BH_Face_AliveOCPlugin()<STLivenessDetectorDelegate,STLivenessControllerDelegate>

@property (nonatomic, strong) NSString *callBackID;

@end


@implementation BH_Face_AliveOCPlugin
-(void)bh_face_alive:(CDVInvokedUrlCommand *)command{
    
    //删除上次存储的文件
    [self deleteFile];
    
    _callBackID = command.callbackId;
    NSString *pathUrl = command.arguments[0];
    NSArray * liveTH = command.arguments[1];
    NSArray * liveSqArr = command.arguments[2];
    
    NSArray * liveToolArr = command.arguments[3];
    NSArray *liveCongigArr = command.arguments[4];
    
    NSLog(@"liveTHT=%@",liveTH.firstObject);
    NSLog(@"liveTHH=%@",liveTH.lastObject);
    
    NSMutableArray *liveMSqArr=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<liveSqArr.count; i++) {
        //此部分将传入的nsnumber类型,例:5不是对象，加个@5，会将其转化成对象[NSNumber numberWithInt:5]，@就是一种简便写法，
        [liveMSqArr addObject:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",liveSqArr[i]] intValue]+1]];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //根据实际情况而定,这里在mainBundle中获取
        // 资源路径
        NSString *strResourcesBundlePath = [[NSBundle mainBundle] pathForResource:@"st_liveness_resource" ofType:@"bundle"];
        NSLog(@"strResourcesBundlePath:%@",strResourcesBundlePath);
        
        
        // 获取模型路径
        NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"M_Finance_Composite_General_Liveness_1.0" ofType:@"model"];
        // 获取授权文件路径
        NSString *strFinanceLicensePath =  [[NSBundle mainBundle]pathForResource:@"SenseID_Liveness" ofType:@"lic"];
        //初始化10.0可修改
        NSString* durationString = liveCongigArr.firstObject;
        double duration = durationString.doubleValue;
        STLivenessController* liveVC;
        if (duration) {
            liveVC=[[STLivenessController alloc]initWithDuration:duration resourcesBundlePath:strResourcesBundlePath modelPath:strModelPath financeLicensePath:strFinanceLicensePath];
        }else{
            liveVC=[[STLivenessController alloc]initWithDuration:0 resourcesBundlePath:strResourcesBundlePath modelPath:strModelPath financeLicensePath:strFinanceLicensePath];
        }
        
        //        STLivenessController* liveVC=[[STLivenessController alloc]initWithDuration:10.0 resourcesBundlePath:strResourcesBundlePath modelPath:strModelPath financeLicensePath:strFinanceLicensePath];
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat safeBottom = ([[UIScreen mainScreen] bounds].size.height<812) ? 0 : 34;
                
        //设置视频区的大小
        int top = [liveTH.firstObject intValue];
        int height = [liveTH.lastObject intValue];
        int toolBottomhidden=[liveToolArr.lastObject intValue];
        int toolTophidden=[liveToolArr.firstObject intValue];
        
        liveVC.top=top;
        
        liveVC.height = screenHeight - liveVC.top - 100 - statusBarHeight - 10 - safeBottom;;
        liveVC.toolViewHidden=toolBottomhidden;
        liveVC.toolTopViewHidden=toolTophidden;
        
        //设置url
        //        NSURL* startURL = [NSURL URLWithString:@"second.html"];
        NSURL* startURL = [NSURL URLWithString:pathUrl];
        
        NSString* startFilePath = [self.commandDelegate pathForResource:[startURL path]];
        if (startFilePath) {
            NSURL *appURL = [NSURL fileURLWithPath:startFilePath];
            liveVC.urlPath=startURL;
        }
        //设置顺序
        //        NSMutableArray *arr= [NSMutableArray array];
        //        if (setting.isDownHead) {
        //            [arr addObject:@(LIVE_NOD)];
        //        }
        //        if (setting.isOpenMouth) {
        //            [arr addObject:@(LIVE_MOUTH)];
        //        }
        //        if (setting.isShakeHead) {
        //            [arr addObject:@(LIVE_YAW)];
        //        }
        //NSArray *arr=@[@(LIVE_MOUTH) , @(LIVE_YAW) , @(LIVE_NOD)];
        NSArray *arr=@[@(2) , @(1) , @(3)];
        NSArray *randomArr=[self randomlyWithAliveTypeArray:arr];
        
        NSMutableArray *muArr=[NSMutableArray array];
        
        [muArr addObject:@(LIVE_BLINK)];
        
        for (NSNumber *obj in randomArr) {
            
            [muArr addObject:obj];
            
        }
        
        //可以根据实际需求自由组合,第一个动作需要为眨眼
        NSArray *arrLivenessSequence = nil;
        
        if(liveMSqArr.count){
            arrLivenessSequence=liveMSqArr;
        }else{
            arrLivenessSequence=muArr;
        }
        // 设置代理,回调线程,动作序列
        [liveVC setDelegate:self callBackQueue:dispatch_get_main_queue() detectionSequence:arrLivenessSequence];
        //设置难易程度,不设置默认为1
        NSString * complexityString=liveCongigArr[1];
        int complexity=complexityString.intValue;
        if (complexity) {
            [liveVC setComplexity:complexity];
        }
        
        //        [liveVC setComplexity:3];
        //设置传回的图片的代理方法,获得图片
        liveVC.imageDelegate = self;
        
        // 设置默认语音提示状态,如不设置默认为开启
        NSString * voicePromptString=liveCongigArr.lastObject;
        BOOL voicePrompt=voicePromptString.intValue;
        liveVC.bVoicePrompt = voicePrompt;
        //设置导航栏
        //UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:liveVC];
        [self.viewController presentViewController:liveVC animated:YES completion:nil];
    });
    //    [self.commandDelegate runInBackground:^{
    //        
    //    }];
    //    [self.commandDelegate sendPluginResult:result callbackId:callBackID];
    //    //将获得的原始图片保存到本地路径
    
}

-(void)encode:(CDVInvokedUrlCommand *)command{
    [self.commandDelegate runInBackground:^{
        
        
        NSString *callBackID = command.callbackId;
        
        CDVPluginResult *result=nil;
        
        //NSString *fileNamePathss = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) firstObject] stringByAppendingPathComponent:@"/faceImage.jpg"];//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径
        
        //NSArray *fileNamePathsArr=command.arguments[0];
        
        NSString*fileNamePaths=command.arguments[0];;
        
        if (fileNamePaths==nil) {
            
            fileNamePaths = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) firstObject] stringByAppendingPathComponent:@"/faceImage.jpg"];//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径
        }
        NSData *data=[NSData dataWithContentsOfFile:fileNamePaths options:0 error:NULL];//从FileNamePaths中读取出数据
        if(data!=nil){
            UIImage *image=[UIImage imageWithData:data];
            
            NSLog(@"宽:%f,高:%f",image.size.width,image.size.height);
            //    将图片转为data格式
            NSData *faceImageData=UIImageJPEGRepresentation(image, 0.2);
            //    将data转化为base64格式的字符串
            NSString *faceImageStr=[faceImageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
            
            //返回的是压缩后的base64字符串
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:faceImageStr];
        }else{
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:result callbackId:callBackID];
    }];
}

-(NSArray *)randomlyWithAliveTypeArray:(NSArray *)aliveTypeArray{
    
    //    生成随机数组
    NSMutableArray *numArr=[NSMutableArray array];
    
    while (numArr.count<aliveTypeArray.count) {
        
        NSInteger num=arc4random()%aliveTypeArray.count;
        if ([numArr indexOfObject:@(num)] != NSNotFound) {
            continue;
        }
        [numArr addObject:@(num)];
    }
    NSMutableArray *muOrderArr=[NSMutableArray array];
    for (NSNumber *num in numArr) {
        NSInteger index=[num integerValue];
        [muOrderArr addObject:aliveTypeArray[index]];
    }
    NSLog(@"随即数组:%@",muOrderArr);
    return [muOrderArr copy];
}
// 删除沙盒里的文件
-(void)deleteFile {
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    //文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"faceImage.jpg"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
        
    }
}
/**
 传回活体验证所获取的图片
 
 @param img            获得的图片
 @param viewcontroller 活体验证的控制器
 */
-(void)getLiveImage:(UIImage *)img FromLiveController:(UIViewController *)viewcontroller{
    NSLog(@"---Image");
    //    将图片转为data格式
    NSData *faceImageData=UIImageJPEGRepresentation(img, 1.0);
    
    // NSString *faceImageBase64String =  [faceImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    //将图片保存到本地,并且返回图片的位置
    //将获得的原始图片保存到本地路径
//    NSString *fileNamePaths = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) firstObject] stringByAppendingPathComponent:@"/faceImage.jpg"];//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径
//
//    [faceImageData writeToFile:fileNamePaths atomically:YES];
    
    // CDVPluginResult*result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:faceImageBase64String];
    //将图片保存到本地,并且返回图片的位置
    //将获得的原始图片保存到本地路径
    NSString *fileNamePaths = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) firstObject] stringByAppendingPathComponent:@"/faceImage.jpg"];//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径
    
    [faceImageData writeToFile:fileNamePaths atomically:YES];
    if (self.completion) {
        self.completion(YES, @{@"imagePath": fileNamePaths});
    }
    CDVPluginResult*result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fileNamePaths];
    [self.commandDelegate sendPluginResult:result callbackId:_callBackID];
    
    _callBackID=nil;
}

#pragma mark - STLivenessDetectorDelegate
- (void)livenessDidStartDetectionWithDetectionType:(LivefaceDetectionType)iDetectionType detectionIndex:(int)iDetectionIndex{
    
}
-(void)livenessDidSuccessfulGetData:(NSData *)data stImages:(NSArray *)arrSTImage{
    
}
-(void)livenessDidCancelWithDetectionType:(LivefaceDetectionType)iDetectionType detectionIndex:(int)iDetectionIndex{
    
}
-(void)livenessDidFailWithErrorType:(LivefaceErrorType)iErrorType detectionType:(LivefaceDetectionType)iDetectionType detectionIndex:(int)iDetectionIndex data:(NSData *)data stImages:(NSArray *)arrSTImage{
    
    NSDictionary* dictionary = @{}; 

    if (iErrorType == LIVENESS_TIMEOUT) { 
        dictionary = @{ @"errContent": @"-1" }; 
    } else if (iErrorType == LIVENESS_NOFACE) { 
        dictionary = @{ @"errContent": @"-3" }; 
    } else { 
        dictionary = @{ @"errContent": @"0" }; 
    } 
    if (self.completion) {
        self.completion(NO, dictionary);
    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary: dictionary]; 
    [self.commandDelegate sendPluginResult:result callbackId:_callBackID]; 
    _callBackID=nil; 
}

@end
