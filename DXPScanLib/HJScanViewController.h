//
//  HJScanViewController.h
//  LibyanaCLP
//
//  Created by 李标 on 2023/11/16.
//

#import <UIKit/UIKit.h>
#import <LBXScan/LBXScanViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJScanViewController : LBXScanViewController

@property (nonatomic, assign) int scanType; //  1 QrCode   2. Bar Code   3 Number

@property (nonatomic, copy) void (^scanResultBlock)(NSString *result);
@end

NS_ASSUME_NONNULL_END
