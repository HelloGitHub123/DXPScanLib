//
//  HJScanConfig.h
//  DXPScanLib
//
//  Created by 李标 on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import <LBXScan/LBXScanViewStyle.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJScanConfig : NSObject

+ (instancetype)shareInstance;

/**
 @brief  矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，< 0 表示扫码区域下移, >0 表示扫码区域上移
 */
@property (nonatomic, assign) CGFloat centerUpOffset;

/**
 @brief  扫码区域的4个角类型
 */
@property (nonatomic, assign) LBXScanViewPhotoframeAngleStyle photoframeAngleStyle;

/**
 @brief  扫码区域4个角的线条宽度,默认6，建议8到4之间
 */
@property (nonatomic, assign) CGFloat photoframeLineW;

//扫码区域4个角的宽度和高度
@property (nonatomic, assign) CGFloat photoframeAngleW;
@property (nonatomic, assign) CGFloat photoframeAngleH;

/**
 @brief  是否需要绘制扫码矩形框，默认YES
 */
@property (nonatomic, assign) BOOL isNeedShowRetangle;

/**
 *  默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
 */
@property (nonatomic, assign) CGFloat whRatio;

/**
 @brief  扫码动画效果:线条或网格
 */
@property (nonatomic, assign) LBXScanViewAnimationStyle anmiationStyle;

//4个角的颜色
@property (nonatomic, strong) UIColor* colorAngle;

/**
 *  动画效果的图像，如线条或网格的图像，如果为nil，表示不需要动画效果
 */
@property (nonatomic,strong,nullable) UIImage *animationImage;

#pragma mark -非识别区域颜色,默认 RGBA (0,0,0,0.5)
/**
 must be create by [UIColor colorWithRed: green: blue: alpha:]
 */
@property (nonatomic, strong) UIColor *notRecoginitonArea;

#pragma mark - UI 配置
// 扫描二维码 + 条形码
@property (nonatomic, copy) NSString *QRCodeTitle; // 二维码标题
@property (nonatomic, copy) NSString *BRCodeTitle; // 条码标题
@property (nonatomic, strong) UIImage *imgFlash; // 电筒图标
@property (nonatomic, strong) UIImage *backImg; // 返回按钮
// 扫码数字
@property (nonatomic, strong) UIImage *scanBorderImg; // 扫描区域边角的图片
@property (nonatomic, copy) NSString *scanNumberTitle; // 扫描标题

@end

NS_ASSUME_NONNULL_END
