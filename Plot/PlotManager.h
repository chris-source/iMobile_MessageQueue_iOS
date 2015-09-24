//
//  PlotManager.h
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/18.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperMap.h"

@interface PlotManager : NSObject<GeometrySelectedDelegate>

@property(nonatomic,strong)UIView* plotView;
-(id)initWithMapControl:(MapControl*)mapControl;
-(void)touchEvent:(UIButton*)btn;
-(void)load;
-(void)drawPlot:(int)lib code:(int)code;
@end
