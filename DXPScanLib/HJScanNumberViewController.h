//
//  HJScanNumberViewController.h
//  OpenCV_Tesseract_demo
//
//  Created by 张昭 on 30/11/2016.
//  Copyright © 2016 张昭. All rights reserved.
//  VC卡识别

#import <UIKit/UIKit.h>

@interface HJScanNumberViewController : UIViewController

@property (nonatomic, copy) void (^scanResultBlock)(NSString *result);
@end
