//
//  HJScanNumberViewController.m
//  OpenCV_Tesseract_demo
//
//  Created by 张昭 on 30/11/2016.
//  Copyright © 2016 张昭. All rights reserved.
//

#import "HJScanNumberViewController.h"
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleMLKit/MLKit.h>
#import "ScanView.h"
#import "UIImage+Orientation_scan.h"
#import "ScanHeader.h"
#import <DXPFontManagerLib/FontManager.h>
#import "HJScanConfig.h"

@interface HJScanNumberViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) MLKTextRecognizer *textDetector;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *myImage;

@property (nonatomic, assign) BOOL flag;
@property (nonatomic, strong) NSString *sendCompleteSuccess; // 确保只发送一次

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *backImgView;
@property (nonatomic, strong) UILabel *titleLab;
//闪光灯
@property (nonatomic, strong) UIButton *btnFlash;
@property (nonatomic, assign) BOOL isOpenFlash;
@end


@implementation HJScanNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.flag = YES;
    self.isOpenFlash = NO;
    self.myImage = [[UIImage alloc] init];
    self.sendCompleteSuccess = @"false";
    
    [self initAVCaptureSession];
    
//    WS(weakSelf);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        weakSelf.textDetector = [MLKTextRecognizer textRecognizerWithOptions:nil];
        self.textDetector = [MLKTextRecognizer textRecognizer];
//        MLKCommonTextRecognizerOptions
//    });
}

- (void)backAction {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	if (self.session) {
		WS_scan(weakSelf);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
            //            dispatch_async(dispatch_get_main_queue(),^{
            //            });
            [weakSelf.session startRunning];
        });
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
//    [self.view addSubview:self.btnFlash];
    
    self.view.backgroundColor = RGBA_scan(0, 0, 0, 0.6);
    
    [self.view addSubview:self.headerView];
    // 导航
    [self.headerView addSubview:self.navView];
    [self.navView addSubview:self.backImgView];
    [self.navView addSubview:self.titleLab];
    
    [self layoutViewUI];
    
    self.btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnFlash setFrame:CGRectMake((self.view.frame.size.width - 50)/2, SCREEN_HEIGHT_scan/2+130/2+50, 50, 50)];
    [_btnFlash setImage:[HJScanConfig shareInstance].imgFlash forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnFlash];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:YES];
	if (self.session) {
		[self.session stopRunning];
	}
}

- (void)layoutViewUI {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.leading.mas_equalTo(self.view.mas_leading).offset(0);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(0);
        make.height.mas_equalTo(navigationBarAndStatusBarHeight_scan + 129);
    }];
    
    // 导航条
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_top).offset(statusBarHeight_scan);
        make.height.mas_equalTo(44);
        make.leading.trailing.mas_equalTo(0);
    }];
    
    [self.backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.leading.mas_equalTo(self.navView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.navView.mas_centerY);
    }];
    
}

- (void)initAVCaptureSession {
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.captureVideoDataOutput]) {
        [self.session addOutput:self.captureVideoDataOutput];
    }
    // 初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 预览图层大小
	self.previewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH_scan, SCREEN_HEIGHT_scan);
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    // 扫描框大小
	ScanView *scanView = [[ScanView alloc] initWithFrame:CGRectMake(24+6, SCREEN_HEIGHT_scan/2-130/2, SCREEN_WIDTH_scan-24*2-6*2, 130)];
    [self.view addSubview:scanView];
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(24, SCREEN_HEIGHT_scan/2-130/2 - 30, SCREEN_WIDTH_scan-24*2, 20)];
    tipLab.numberOfLines = 0;
	tipLab.text = [HJScanConfig shareInstance].scanNumberTitle;
    tipLab.textColor = UIColorFromRGB_scan(0xCACCD5);
    tipLab.textAlignment = NSTextAlignmentCenter;
	tipLab.font = [FontManager setNormalFontSize:14];
    [self.view addSubview:tipLab];
    
    UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(24, SCREEN_HEIGHT_scan/2-130/2-6, SCREEN_WIDTH_scan-24*2, 130+12)];
	leftImgView.image = [HJScanConfig shareInstance].scanBorderImg;
    [self.view addSubview:leftImgView];
}

// 打开和关闭闪光灯
- (void)openOrCloseFlash {
    // Start session configuration
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    // Set torch to on
    [self.device setTorchMode:self.isOpenFlash ? AVCaptureTorchModeOff:   AVCaptureTorchModeOn];
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
    
    self.isOpenFlash = !self.isOpenFlash;
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.flag) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer); //1920
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                        width, height, 8, bytesPerRow, colorSpace,
                                                        kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef newImage = CGBitmapContextCreateImage(newContext);
        
        if (!_image) {
            _image = [[UIImage alloc] init];
        }
        _image = [UIImage imageWithCGImage:newImage scale:1 orientation:UIImageOrientationRight];
        [self getThePicAndWord:_image];
        
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(newImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }
}

- (void)getThePicAndWord:(UIImage *)image {
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:[self cropImageFromImage:image]];
    [self.textDetector processImage:visionImage completion:^(MLKText * _Nullable text, NSError * _Nullable error) {
        
        
        NSString *scanValue = text.text;
        
        NSString *fixResult = [self removeSpaceAndNewline:scanValue];
        // 判断字符串中的数字
        NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:scanValue options:NSMatchingReportProgress range:NSMakeRange(0, scanValue.length)];

        NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *str = [[scanValue componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
        if (tNumMatchCount == 13 || tNumMatchCount == 15) {
            NSString *resultStr = str;
            self.flag = !self.flag;
            if (fixResult) {
                WS_scan(weakSelf);
                NSDictionary *dict = @{@"resultStr":resultStr};
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.sendCompleteSuccess isEqualToString:@"false"]) {
                        if (weakSelf.scanResultBlock) {
                            
                            NSLog(@"识别出数字为:_______%@",resultStr);
                            
                            weakSelf.scanResultBlock(resultStr);
                        }
                        weakSelf.sendCompleteSuccess = @"true";
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        
    }];
    
    
//	NSArray<GMVTextBlockFeature *> *features = [self.textDetector featuresInImage:[self cropImageFromImage:image] options:nil];
//	for (GMVTextBlockFeature *textBlock in features) {
//		NSString *scanValue = textBlock.value;
//		NSString *fixResult = [self removeSpaceAndNewline:scanValue];
//		// 判断字符串中的数字
//		NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
//		NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:scanValue options:NSMatchingReportProgress range:NSMakeRange(0, scanValue.length)];
//
//		NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
//		NSString *str = [[scanValue componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
//		if (tNumMatchCount == 13 || tNumMatchCount == 15) {
//			NSString *resultStr = str;
//			self.flag = !self.flag;
//			if (fixResult) {
//                WS(weakSelf);
//				NSDictionary *dict = @{@"resultStr":resultStr};
//				dispatch_async(dispatch_get_main_queue(), ^{
//					if ([weakSelf.sendCompleteSuccess isEqualToString:@"false"]) {
//                        if (weakSelf.scanResultBlock) {
//                            weakSelf.scanResultBlock(resultStr);
//                        }
//                        weakSelf.sendCompleteSuccess = @"true";
//					}
//					[weakSelf.navigationController popViewControllerAnimated:YES];
//				});
//			}
//		}
//	}
}

#pragma mark -- 裁剪
- (UIImage *)cropImageFromImage:(UIImage *)img {
    static CGFloat cardWidth =  400;
    static CGFloat cardHeight = 400 / 1.59; //1.59是银行卡的宽高比例
	
    CGFloat h = img.size.height * 500 / img.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(500, h));
    [img drawInRect:CGRectMake(0, 0, 500, h)];
    UIImage *scaleImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat y = (scaleImg.size.height - cardHeight) / 2-24;
    
    CGImageRef sourceImageRef = [scaleImg CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(40, y, cardWidth, cardHeight));
    
    CGImageRef resultImgRef = CGImageCreateWithImageInRect(newImageRef, CGRectMake(50, 130, cardWidth-50, 40));  //150--80 截取图片的高
    UIImage *mm = [UIImage imageWithCGImage:resultImgRef];
    CGImageRelease(newImageRef);
    CGImageRelease(resultImgRef);
    return mm;
}

#pragma mark --去除字符串中的空格和换行
- (NSString*)removeSpaceAndNewline:(NSString*)str {
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //去除特殊符号
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／:;()¥「」＂、[]{}#%-*+=_\\|~$€^•'@#$%^&*()_+'\""];
    NSString *trimmedString = [temp stringByTrimmingCharactersInSet:set];
    return trimmedString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- lazy load
- (AVCaptureSession *)session {
	if (!_session) {
		_session = [[AVCaptureSession alloc] init];
	}
	return _session;
}

- (AVCaptureVideoDataOutput *)captureVideoDataOutput {
	if (!_captureVideoDataOutput) {
		NSString *key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
		NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
		NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
		
		_captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
		[_captureVideoDataOutput setVideoSettings:videoSettings];
		
		dispatch_queue_t queue;
		queue = dispatch_queue_create("cameraQueue", NULL);
		[_captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
	}
	return _captureVideoDataOutput;
}

- (AVCaptureDeviceInput *)videoInput {
	if (!_videoInput) {
		NSError *error;
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.device = device;
		//更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
		[device lockForConfiguration:nil];
		//设置闪光灯为自动
		[device setFlashMode:AVCaptureFlashModeAuto];
		[device unlockForConfiguration];
		_videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
	}
	return _videoInput;
}

//- (UIButton *)btnFlash {
//    if (!_btnFlash) {
//        // 计算闪光灯的位置
//        CGRect frame = self.view.frame;
//        int XRetangleLeft = self.style.xScanRetangleOffset;
//        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
//        if (self.style.whRatio != 1) {
//            CGFloat w = sizeRetangle.width;
//            CGFloat h = w / self.style.whRatio;
//            NSInteger hInt = (NSInteger)h;
//            h  = hInt;
//            sizeRetangle = CGSizeMake(w, h);
//        }
//        //扫码区域Y轴最小坐标
//        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
//        CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
//
//        _btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_btnFlash setFrame:CGRectMake((self.view.frame.size.width - 50)/2, YMaxRetangle + 50, 50, 50)];
//        [_btnFlash setImage:[UIImage imageNamed:@"icon_flash"] forState:UIControlStateNormal];
//        [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _btnFlash;
//}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = [UIColor clearColor];
    }
    return _navView;
}

- (UIButton *)backImgView {
    if (!_backImgView) {
        _backImgView = [UIButton buttonWithType:UIButtonTypeCustom];
		[_backImgView setImage:[HJScanConfig shareInstance].backImg forState:UIControlStateNormal];
        _backImgView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_backImgView addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backImgView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
    }
    return _headerView;
}

@end
