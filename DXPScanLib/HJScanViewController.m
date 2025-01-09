//
//  HJScanViewController.m
//  LibyanaCLP
//
//  Created by 李标 on 2023/11/16.
//

#import "HJScanViewController.h"
#import <Masonry/Masonry.h>
#import "ScanHeader.h"
#import <DXPFontManagerLib/FontManager.h>
#import "HJScanConfig.h"

@interface HJScanViewController ()

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *backImgView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *titleLable;
//闪光灯
@property (nonatomic, strong) UIButton *btnFlash;
@end

@implementation HJScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self.view addSubview:self.btnFlash];
    
    [self.view addSubview:self.headerView];
    // 导航
    [self.headerView addSubview:self.navView];
    [self.navView addSubview:self.backImgView];
    [self.navView addSubview:self.titleLab];
    
    [self.view addSubview:self.titleLable];
    
    [self layoutViewUI];
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

#pragma mark -- 方法
// 开关闪光灯
- (void)openOrCloseFlash {
    [super openOrCloseFlash];
}

#pragma mark - 退出
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -实现类继承该方法，作出对应处理
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array {
    if (!array ||  array.count < 1) {
        [self popAlertMsgWithScanResult:nil];
        return;
    }
    //经测试，可以ZXing同时识别2个二维码，不能同时识别二维码和条形码
    //    for (LBXScanResult *result in array) {
    //
    //        NSLog(@"scanResult:%@",result.strScanned);
    //    }

    LBXScanResult *scanResult = array[0];
    NSString*strResult = scanResult.strScanned;
    self.scanImage = scanResult.imgScanned;
    if (!strResult) {
        [self popAlertMsgWithScanResult:nil];
        return;
    }
    //TODO: 这里可以根据需要自行添加震动或播放声音提示相关代码
    //...
    [self showNextVCWithScanResult:scanResult];
}

- (void)popAlertMsgWithScanResult:(NSString*)strResult {
    if (!strResult) {
        strResult = @"扫描识别失败";
        NSLog(@"%@",strResult);
    }
    __weak __typeof(self) weakSelf = self;
    [weakSelf reStartDevice];
}

- (void)showNextVCWithScanResult:(LBXScanResult*)strResult {
    NSLog(@"扫描结果为：%@",strResult.strScanned);
    if (self.scanResultBlock) {
        [self.navigationController popViewControllerAnimated:YES];
        self.scanResultBlock(strResult.strScanned);
    }
}

#pragma mark -- lazy
- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.numberOfLines = 0;
		_titleLable.font = [FontManager setNormalFontSize:14];
        _titleLable.textColor = UIColorFromRGB_scan(0xCACCD5);
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.text = self.scanType == 1 ? [HJScanConfig shareInstance].QRCodeTitle : [HJScanConfig shareInstance].BRCodeTitle;
        
        // 计算闪光灯的位置
        CGRect frame = self.view.frame;
        int XRetangleLeft = self.style.xScanRetangleOffset;
        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
        if (self.style.whRatio != 1) {
            CGFloat w = sizeRetangle.width;
            CGFloat h = w / self.style.whRatio;
            NSInteger hInt = (NSInteger)h;
            h  = hInt;
            sizeRetangle = CGSizeMake(w, h);
        }
        //扫码区域Y轴最小坐标
        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
        [_titleLable setFrame:CGRectMake(24, YMinRetangle - 30, SCREEN_WIDTH_scan-24*2, 20)];
        
    }
    return _titleLable;
}

- (UIButton *)btnFlash {
    if (!_btnFlash) {
        // 计算闪光灯的位置
        CGRect frame = self.view.frame;
        int XRetangleLeft = self.style.xScanRetangleOffset;
        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
        if (self.style.whRatio != 1) {
            CGFloat w = sizeRetangle.width;
            CGFloat h = w / self.style.whRatio;
            NSInteger hInt = (NSInteger)h;
            h  = hInt;
            sizeRetangle = CGSizeMake(w, h);
        }
        //扫码区域Y轴最小坐标
        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
        CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
        
        _btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFlash setFrame:CGRectMake((self.view.frame.size.width - 50)/2, YMaxRetangle + 50, 50, 50)];
        [_btnFlash setImage:[HJScanConfig shareInstance].imgFlash forState:UIControlStateNormal];
        [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnFlash;
}

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
