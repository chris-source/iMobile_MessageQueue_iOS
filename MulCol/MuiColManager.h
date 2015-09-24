//
//  MuiColManager.h
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/18.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperMap.h"

@class MapManager;
@interface MuiColManager : NSObject<MDataCollectorMediaFileListener,DownLoadDelegate,UploadDelegate>
{
    @public
    MDataCollector* mMDataCol;
}
@property(nonatomic)BOOL isLogin;
@property(nonatomic,strong)UIButton* btnStopVoice;
@property(nonatomic,strong)MapManager* mapManager;
-(id)initWithMapControl:(MapControl*)mapControl;
-(void)load;
-(void)dealRecord:(Recordset*)rd;
-(void)touchEvent:(UIButton*)btn;

-(void)login;
-(void)uploadMediaFile;
-(void)updataMediaDataset;
-(void)commitMediaDataset;
@end
