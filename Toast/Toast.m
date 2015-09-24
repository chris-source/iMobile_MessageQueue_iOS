//
//  Toast.m
//  SpatialAnalystDemo
//
//  Created by imobile on 14-6-26.
//  Copyright (c) 2014年 imobile. All rights reserved.
//

#import "Toast.h"
#import "Toast+UIView.h"
@implementation Toast

static UIView* mCurrentView;
static UIInterfaceOrientation _interfaceOrientation;
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        mCurrentView = [self getCurrentRootViewController].view;
//    }
//    return self;
//}

+(void)show:(NSString*)message pos:(NSString*)pos
{
    dispatch_async(dispatch_get_main_queue(), ^{
    mCurrentView = [Toast getCurrentRootViewController].view;
    [mCurrentView makeToast:message
                   duration:1.5
                   position:pos
                      title:nil];
    });
}

+(void)show:(NSString*)message
{
     dispatch_async(dispatch_get_main_queue(), ^{
        mCurrentView = [Toast getCurrentRootViewController].view;
        [mCurrentView makeToast:message
                    duration:1.5
                    position:@"center"
                       title:nil];
     });

}
+(void)show:(NSString*)title message:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        mCurrentView = [Toast getCurrentRootViewController].view;
        [mCurrentView makeToast:message
                       duration:1.5
                       position:@"center"
                          title:title];
    });
    
}
+(void)showIndicatorView
{
    mCurrentView = [Toast getCurrentRootViewController].view;
    [mCurrentView showIndicatorView];
}
+(void)hideIndicatorView
{
    mCurrentView = [Toast getCurrentRootViewController].view;
    [mCurrentView hideIndicatorView];
}
+(UIViewController *)getCurrentRootViewController {
    
    UIViewController *result;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        
        result = nextResponder;
    
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        result = topWindow.rootViewController;
    else
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;
    
}
@end
