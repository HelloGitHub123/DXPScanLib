//
//  UIImage+Orientation.h
//  OpenCV_Tesseract_demo
//
//  Created by summer on 2019/7/4.
//  Copyright © 2019年 张昭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Orientation_scan)

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation ;
+ (UIImage*)img:(UIImage *)img rotate:(UIImageOrientation)orient;
//- (UIImage *)hts_imageFlippedForRightToLeftLayoutDirection;
@end

NS_ASSUME_NONNULL_END
