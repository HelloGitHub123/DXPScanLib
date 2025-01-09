//
//  HJScanConfig.m
//  DXPScanLib
//
//  Created by 李标 on 2025/1/9.
//

#import "HJScanConfig.h"

@interface HJScanConfig ()

@end

static HJScanConfig *manager = nil;

@implementation HJScanConfig

+ (instancetype)shareInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[HJScanConfig alloc] init];
	});
	return manager;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.centerUpOffset = 0.f;
		self.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
		self.photoframeLineW = 3;
		self.photoframeAngleW = 18;
		self.photoframeAngleH = 18;
		self.isNeedShowRetangle = YES;
		self.whRatio = 1;
		self.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
		self.colorAngle = [UIColor colorWithRed:190./255. green:160./255. blue:121./255. alpha:1.0];
		self.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
		
		self.notRecoginitonArea =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
		
		self.QRCodeTitle = @"Scan QR Code automatically within the frame.";
		self.BRCodeTitle = @"Scan barcode automatically within the frame.";
		self.scanNumberTitle = @"Scan number automatically within the frame.";
	}
	return self;
}




@end
