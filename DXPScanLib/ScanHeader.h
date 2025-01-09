//
//  ScanHeader.h
//  DXPScanLib
//
//  Created by 李标 on 2024/10/21.
//

#ifndef ScanHeader_h
#define ScanHeader_h

#define navigationBarAndStatusBarHeight_scan self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height

#define statusBarHeight_scan [[UIApplication sharedApplication] statusBarFrame].size.height

//颜色
#define UIColorFromRGB_scan(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBA_scan(r,g,b,a)            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB_scan(r,g,b)               [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]


#define WS_scan(weakSelf)    __weak __typeof(&*self)weakSelf = self


//屏幕的宽高
#define SCREEN_WIDTH_scan             [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT_scan            [UIScreen mainScreen].bounds.size.height

#define _image_scan(x)                [UIImage imageNamed:x]

#endif /* ScanHeader_h */
