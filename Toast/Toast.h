//
//  Toast.h
//  SpatialAnalystDemo
//
//  Created by imobile on 14-6-26.
//  Copyright (c) 2014年 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Toast : UIView
{
  
}
+(void)show:(NSString*)message;
+(void)show:(NSString*)message pos:(NSString*)pos;
+(void)show:(NSString*)title message:(NSString*)message;
+(void)showIndicatorView;
+(void)hideIndicatorView;
@end
