//
//  MuiColManager.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/18.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "MuiColManager.h"
#import "Toast.h"
#import "MapManager.h"
#import "MQManager.h"

@interface MuiColManager()
{
    MapControl* m_mapControl;
    DatasetVector* mDataset;
    DataUploadService* mDataUploadService;
    DataDownloadService* mDownloadService;
    NSString* mUrl;
}
@end
@implementation MuiColManager
@synthesize btnStopVoice,isLogin,mapManager;

-(id)initWithMapControl:(MapControl*)mapControl{
    
    if(self=[super init]){
        m_mapControl = mapControl;
        mMDataCol = [[MDataCollector alloc]init];
        mMDataCol.delegate = self;
        Datasource* ds = [m_mapControl.map.workspace.datasources get:1];
        if(![mMDataCol setMediaDataset:ds datasetName:@"MQDemo_MediaDataset"])
            NSLog(@"设置数据集失败!");
        self.isLogin = NO;
        
        mDataUploadService = [[DataUploadService alloc]init];
        mDataUploadService.uploadDelegate = self;
        mDownloadService = [[DataDownloadService alloc]init];
        mDownloadService.downLoadDelegate = self;
        mDataset = (DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:0];
        
        mUrl = @"http://support.supermap.com.cn:8092/iportal/services/data-mqdemo/rest/data/datasources/multimedia/datasets/MQDemo_MediaDataset.rjson";
    }
    return  self;
}


-(void)load{
    
}
-(void)touchEvent:(UIButton*)btn{
    
    int index = btn.tag;
    
    switch (index) {
        case 21://take photo
            [mMDataCol captureImage];
            break;
        case 22://take video
            [mMDataCol captureVideo];
            break;
        case 23:{//take voice
            [mMDataCol startCaptureAudio];
            self.btnStopVoice.hidden = NO;
            //Toast* toast = [[Toast alloc]init];
            [Toast show:@"开始音频采集，点击按钮保存" pos:@"bottom"];
            break;
        }case 24:
            [mMDataCol stopCaptureAudio];
            self.btnStopVoice.hidden = YES;
            break;
        default:
            break;
    }
}

#pragma mark 多媒体采集
-(void)dealRecord:(Recordset*)rd{
    
   // DatasetVector* pDatasetVector = (DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:0];
    
    if(!rd.isBOF){
        NSString* fileName =(NSString*)[rd getFieldValueWithIndex:[rd.fieldInfos indexOfWithFieldName:@"MediaFileName"]];
        
        if(fileName == nil)
            return;
        
        fileName = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@",mDataset.description,fileName];
        
        BOOL isDir;
        BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:&isDir];
        
        if(!isDirExist || isDir){
            [Toast show:@"多媒体文件还在传输中,请稍后打开"];
        }else
            //调用显示
            [MDataCollector playMultiMedia:fileName];
    }
    [rd dispose];
}

static NSString* m_IPortalURI = @"http://support.supermap.com.cn:8092/iportal";
static NSString* m_IPortalUserName = @"supermap";
static NSString* m_IPortalPassword = @"bdpc123";
-(void)login{
    
    if(self.isLogin)
        return;
    if(![mMDataCol login:m_IPortalURI username:m_IPortalUserName password:m_IPortalPassword]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [Toast show:@"连接iportal服务失败"];
        });
    }else{
       // [self updataMediaDataset];
        self.isLogin = YES;
    }
    
}

-(void)uploadMediaFile{
    if(self.mapManager.isReceiveMessage)
        [mMDataCol uploadMediaFiles:m_mapControl.map.bounds];
}

#pragma mark 数据服务
-(void)updataMediaDataset{
    if(self.mapManager.isReceiveMessage)
        [mDownloadService updateDatasetFrom:mUrl toDatasetVector:mDataset];
}
-(void)commitMediaDataset{
    if(self.mapManager.isReceiveMessage)
        [mDataUploadService commitDatasetFrom:mDataset toDatasetURL:mUrl];
}

#pragma mark 回调
//
//1 上传多媒体文件
//2 提交本地数据集
//3 更新数据集
//4 下载多媒体文件
//5 通知更新

static BOOL hasNewMediaFile = NO;
-(void)onCaptureMediaFile:(BOOL)isSuccess fileName:(NSString*)mediaFileName type:(int)type{
    
    if(isSuccess){
        hasNewMediaFile = YES;
        if(self.mapManager.isReceiveMessage){
            //todo up
            [mMDataCol uploadMediaFilesByFileName:mediaFileName];
        }else
            [m_mapControl.map refresh];
    }
}
//上传完成后回调
-(void)onUploadMediaFiles:(NSString* )response{
    static int i = 0;
    NSLog(@"上传: %i",++i);
    [self commitMediaDataset];
}
-(void)commitDatasetEndFrom:(DatasetVector*)dataset toDatasetURL:(NSString*)urlDataset exception:(NSException*)exception returningResponse:(NSURLResponse *)response error:(NSError *)error{
    static int i = 0;
     NSLog(@"数据服务提交完成 %i",++i);
    [self updataMediaDataset];
}
-(void)updateDatasetEndFrom:(NSString*)urlDataset toDatasetVector:(DatasetVector*)dataset exception:(NSException*)exception returningResponse:(NSURLResponse *)response error:(NSError *)error{
    static int i = 0;
    NSLog(@"数据服务更新完成 %i",++i);
    [mMDataCol downloadMediaFiles:m_mapControl.map.bounds];
    
}
//下载完成后回调
-(void)onDownloadMediaFiles:(NSString* )response{
    static int i = 0;
    NSLog(@"下载 %i",++i);
    [m_mapControl.map refresh];
    NSString* msg = @"{content_type=1}";
    msg = [msg stringByAppendingFormat:@"{uri=%@,username=%@,passwd=%@}",m_IPortalURI,m_IPortalUserName,m_IPortalPassword];
    if(hasNewMediaFile){
        [self.mapManager.mQManager sendMessage:msg type:3];
        hasNewMediaFile = NO;
    }
   
}

@end
