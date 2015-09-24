//
//  ViewController.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/15.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "ViewController.h"
#import "ZipArchive.h"
#import "MapManager.h"
#import "Toast.h"

@interface ViewController ()
{
    BOOL isInitOk;
    Toast* toast;
    
    __weak IBOutlet UIView *mBtnBackView;
    __weak IBOutlet UIButton *btnUpPos;
    __weak IBOutlet UIButton *btnTurnMessage;
    __weak IBOutlet UIButton *btnStopVoice;
    __weak IBOutlet UIView *mPlotView;
    
    __weak IBOutlet UIView *mTextLookUp;
    __weak IBOutlet UIButton *btnBack;
    MapManager* mMapManger;
    
}
@end

@implementation ViewController

-(void)p_initView{
    
    mBtnBackView.layer.borderWidth = 1;
    mBtnBackView.layer.cornerRadius = 8;
    mBtnBackView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    btnUpPos.layer.borderWidth = 1;
    btnUpPos.layer.cornerRadius = 8;
    btnUpPos.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btnTurnMessage.layer.borderWidth = 1;
    btnTurnMessage.layer.cornerRadius = 8;
    btnTurnMessage.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    btnStopVoice.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    
    mPlotView.layer.borderWidth = 1;
//    mPlotView.layer.cornerRadius = 8;
    mPlotView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    mPlotView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    
    btnBack.layer.borderWidth = 1;
    btnBack.layer.cornerRadius = 13;
    btnBack.layer.borderColor = [[UIColor redColor] CGColor];
    
    mTextLookUp.layer.borderWidth = 1;
    mTextLookUp.layer.cornerRadius = 8;
    mTextLookUp.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    mTextLookUp.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);

}

-(void)p_init{
    m_mapcontrol.userInteractionEnabled = NO;
    isInitOk = NO;
    [Environment setOpenGLMode:NO];
    
    //copy license
    NSString *srclic = [[NSBundle mainBundle] pathForResource:@"Trial_License" ofType:@"slm"];
    NSString* deslic = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",@"Trial_License.slm"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:deslic isDirectory:nil]){
        if(![[NSFileManager defaultManager] copyItemAtPath:srclic toPath:deslic error:nil])
            NSLog(@"拷贝数据失败");
    }
    
    //copy demoData
    
    NSString *srcfileName = [[NSBundle mainBundle] pathForResource:@"demoData" ofType:@"zip"];
    
    NSString* desFile = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@",@""];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[desFile stringByAppendingString:@"demoData"] isDirectory:nil]){
        if(![[NSFileManager defaultManager] copyItemAtPath:srcfileName toPath:[desFile stringByAppendingString:@"demoData.zip"] error:nil])
            NSLog(@"拷贝数据失败");
        else{
            ZipArchive *za = [[ZipArchive alloc] init];
            if ( [za UnzipOpenFile: [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@",@"demoData.zip"]] ){
                if( [za UnzipFileTo: desFile overWrite: YES] )
                    [[NSFileManager defaultManager] removeItemAtPath:[desFile stringByAppendingString:@"demoData.zip"] error:nil];
                [za UnzipCloseFile];
            }
        }
    }
    
    //初始化工作空间
    if (_workspace == nil) {
        _workspace = [[Workspace alloc]init];
        [m_mapcontrol mapControlInit];
        [m_mapcontrol.map setWorkspace:_workspace];
    }
    
    NSString* workspace = [desFile stringByAppendingString:@"demoData/mqdemo.smwu"];
    
    m_Info = [[WorkspaceConnectionInfo alloc]init];
    m_Info.server = workspace;
    m_Info.type = SM_SMWU;
    isInitOk = [_workspace open:m_Info];
    if(!isInitOk){
        NSLog(@"打开工作空间失败");
    }
}

/**
 *打开地图
 */
static BOOL isOpenMap = NO;
-(void)openMap{
    
    if (isInitOk)
    {
         isOpenMap = [m_mapcontrol.map open:[_workspace.maps get:1]];
        if (isOpenMap)
        {
            m_mapcontrol.map.isFullScreenDrawModel = YES;
            m_mapcontrol.map.isAntialias = YES;
            //设置默认地图全幅
            NSLog(@"Open Map Success!");
            [m_mapcontrol setAction:SELECT];
            [m_mapcontrol.map viewEntire];
            //  m_mapControl.refreshEndDelegate = self;
            [m_mapcontrol.map.layers getLayerAtIndex:0].selectable = YES;
            [m_mapcontrol.map.layers getLayerAtIndex:1].selectable = NO;
            [m_mapcontrol.map.layers getLayerAtIndex:2].selectable = NO;
        }
        else
        {
            NSLog(@"Open Map Failed!");
        }
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_initView];
}

-(void)viewDidAppear:(BOOL)animated{
    
//    [MDataCollector playVoice:[NSHomeDirectory() stringByAppendingString:@"/Documents/Lenovo.acc"]];
    if(!isOpenMap){
        [Toast showIndicatorView];
        [Toast show:@"数据加载中..."];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        // 执行异步任务
        dispatch_async(queue, ^(void){
            [self p_init];
            [self p_stopIndicatorView];
        });
    }
}
-(void)p_stopIndicatorView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Toast hideIndicatorView];
        toast = nil;
        
        [self openMap];
        [m_mapcontrol.map refresh];
        mMapManger = [[MapManager alloc]initWithMapcontrol:m_mapcontrol];
        [mMapManger load];
        m_mapcontrol.userInteractionEnabled = YES;
        
        
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static MDataCollector* col;
/**
 *全幅地图
 */
-(IBAction)btnFullmap:(id)sender{
    
    [m_mapcontrol.map viewEntire];
    [m_mapcontrol.map refresh];
}

/**
 *缩小地图
 */
-(IBAction)btnZoomOut:(id)sender{
    
    [m_mapcontrol zoomTo:m_mapcontrol.map.scale*0.5 time:100];
    [self refresh];
  //  [MDataCollector playVoice:[NSHomeDirectory() stringByAppendingString:@"/Documents/1439794439662.acc"]];
}

/**
 *放大地图
 */
-(IBAction)btnZoomIn:(id)sender{
    
    [m_mapcontrol zoomTo:m_mapcontrol.map.scale*2.0 time:80];
    [self refresh];
  //  [col stopCaptureAudio];
}

/**
 *定位
 */
-(IBAction)btnLocation:(id)sender{
    
    [mMapManger location];
//    col = [[MDataCollector alloc]init];
//    col.localFilePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/test.acc"];
//    [col startCaptureAudio];
}
static NSTimer* myTimer;
-(void)refresh{
    myTimer = [NSTimer  timerWithTimeInterval:0.15 target:self selector:@selector(mapRefesh)userInfo:nil repeats:NO];
    [[NSRunLoop  currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
}
-(void)mapRefesh
{
    [m_mapcontrol.map refresh];
    [myTimer invalidate];
    myTimer = nil;
}
@end
