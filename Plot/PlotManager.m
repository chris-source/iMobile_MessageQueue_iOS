//
//  PlotManager.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/18.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "PlotManager.h"
#import "ArrowCollectionView.h"
#import "Toast.h"

@interface PlotManager()
{
    MapControl* m_mapControl;
    
    ArrowCollectionView* mArrowView,*mPointView;
    
    int lib1,lib2;
}
@end
@implementation PlotManager
@synthesize plotView;

-(id)initWithMapControl:(MapControl*)mapControl{
    
    if(self=[super init]){
        m_mapControl = mapControl;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(p_doubleClick)];
        tapGesture.numberOfTapsRequired = 2;
        [m_mapControl addGestureRecognizer:tapGesture];
       // UIPinchGestureRecognizer* pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(p_pinClick)];
       // [m_mapControl addGestureRecognizer:pinGesture];
        m_mapControl.geometrySelectedDelegate = self;
    }
    
    return self;
}

-(void)p_doubleClick{
  
    if (SmId != -1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除当前对象？" message:@"取消结束选择" delegate:self cancelButtonTitle:@"取消选择" otherButtonTitles:@"删除",nil];
        [alert show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        DatasetVector* dv = ((DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:1]) ;
        Recordset* rd = [dv queryWithFilter:[NSString stringWithFormat:@"SmId=%i",SmId] Type:DYNAMIC];
        [rd edit];
        [rd delete];
        [rd update];
        [rd dispose];
    }
    [m_mapControl setAction:SELECT];
    [m_mapControl.map refresh];
    SmId = -1;
}
//static BOOL isSelected = NO;
static int SmId = -1;
-(void)geometrySelected:(int)geometryID LayerIndex:(int)layerIndex{
    SmId = geometryID;
    [Toast show:@"双击地图其他地方,取消或者删除"];
}
-(void)p_click{
    self.plotView.hidden = YES;
}
-(void)load{
    
    lib1 = [m_mapControl addPlotLibrary: [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/demoData/%@",@"JB.plot"]];
    lib2 = [m_mapControl addPlotLibrary:[NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/demoData/%@",@"TY.plot"]];
    
    UIButton* btn = ((UIButton*)((UIView*)self.plotView.subviews[0]).subviews[0]);
    [btn addTarget:self action:@selector(p_click) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *srcfileName = [[NSBundle mainBundle] pathForResource:@"codesLib" ofType:@"bundle"];
    NSString* arrowFiles = [srcfileName stringByAppendingString:@"/点标/"];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:arrowFiles error:nil];
    
    mPointView = [[ArrowCollectionView alloc] initWithFrame:CGRectMake(0, 40, 417, 280)];
    mPointView.cellArr = fileList;
    mPointView.path = arrowFiles;
    mPointView.libID = lib1;

    srcfileName = [[NSBundle mainBundle] pathForResource:@"codesLib" ofType:@"bundle"];
    NSString* arrowFiles1 = [srcfileName stringByAppendingString:@"/通用符号库/二、箭头/"];
    NSArray *fileList1 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:arrowFiles1 error:nil];
    
    mArrowView = [[ArrowCollectionView alloc] initWithFrame:CGRectMake(0, 40, 417, 280)];
    mArrowView.cellArr = fileList1;
    mArrowView.path = arrowFiles1;
    mArrowView.libID = lib2;
    mArrowView.manager = self;
    mPointView.manager = self;
    [self.plotView addSubview:mArrowView.collectionView];
    [self.plotView addSubview:mPointView.collectionView];
}

-(void)drawPlot:(int)lib code:(int)code
{
    [m_mapControl setAction:CREATE_PLOT];
    [m_mapControl setPlotSymbol:lib symbolCode:code];
    self.plotView.hidden = YES;
}
-(void)touchEvent:(UIButton*)btn{
    
    int index = btn.tag;
    
    //Color* color = [[Color alloc]initWithR:127 G:127 B:127];
    [m_mapControl setStrokeWidth:1.0];
    switch (index) {
        case 31://点符号
            [m_mapControl setStrokeWidth:0.5];
            self.plotView.hidden = NO;
            mPointView.collectionView.hidden = NO;
            mArrowView.collectionView.hidden = YES;
            break;
        case 32://绘线
            m_mapControl.action = CREATE_FREE_POLYLINE;
            break;
        case 33://绘面
            m_mapControl.action = CREATE_FREE_DRAWPOLYGON;
            break;
        case 34://涂鸦
        {
            m_mapControl.action = CREATE_FREE_DRAW;
            break;
        }
        case 35://箭头
            [m_mapControl setStrokeWidth:0.5];
            self.plotView.hidden = NO;
            mPointView.collectionView.hidden = YES;
            mArrowView.collectionView.hidden = NO;

            break;
        case 36://清除
        {
            Recordset* rd = [((DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:1]) recordset:NO cursorType:DYNAMIC];
            [rd deleteAll];
            [rd dispose];
            [m_mapControl.map refresh];
            break;
        }default:
            break;
    }
}
@end
