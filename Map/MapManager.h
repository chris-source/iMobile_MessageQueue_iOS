//
//  MapManager.h
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/17.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperMap.h"

@class MuiColManager;
@class MQManager;
@interface MapManager : NSObject<locationChangedDelegate,MapParameterChangedDelegate,TouchableViewDelegate>
{
    MapControl* m_mapControl;
    DynamicView* mDynamicView;
    ScaleView* mScaleView;
    LocationManagePlugin *m_loc;
}

@property(nonatomic,strong)MQManager* mQManager;
@property(nonatomic,strong)MuiColManager* mulColManager;
@property(nonatomic)BOOL isReceiveMessage;
@property(nonatomic,strong)Point2D* locationPos,*locationJWD;
-(id)initWithMapcontrol:(MapControl*)mapControl;
-(void)load;
-(void)location;
-(void)drawLocationUpPos:(NSDictionary*)points;
@end
