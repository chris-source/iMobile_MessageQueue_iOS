//
//  MapManager.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/17.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "MapManager.h"
#import "SuperMap.h"
#import "ScaleView.h"
#import "Toast.h"
#import "MQToolkit.h"

#import "MuiColManager.h"
#import "PlotManager.h"
#import "MQManager.h"


@interface MapManager()
{
    Point2D* mLocatePos;
    Point2D* mLocateJWD;//经纬度坐标
    NSMutableArray* btnArr;
    UIView* mulCal,*plot;
   // UIButton* mBtnStopVoice;
    MuiColManager* mMulColManager;
    PlotManager* mPlotManager;
    MQManager* mMQManager;
}
@end

@implementation MapManager
@synthesize isReceiveMessage,locationPos=mLocatePos,locationJWD=mLocateJWD;
@synthesize mulColManager = mMulColManager,mQManager=mMQManager;
//是否在漫游move
static BOOL isMoveing = NO;
//是否有选中
static BOOL isSelected = NO;
//是否双指
static BOOL isDoubleFinger = NO;
static BOOL isFirstShow = YES;
-(id)initWithMapcontrol:(MapControl*)mapControl{
    
    if(self=[super init]){
        m_mapControl = mapControl;
        mDynamicView = [[DynamicView alloc]initWithMapControl:m_mapControl];
        mScaleView = [[ScaleView alloc]initWithMapControl:m_mapControl];
        mScaleView.xOffset += 70;
        mScaleView.yOffset -= 10;
        mScaleView.levelEnable = YES;
        m_loc = [[LocationManagePlugin alloc]init];
        m_loc.locationChangedDelegate = self;
        [m_loc openGpsDevice];
        
        mLocatePos = [[Point2D alloc]initWithX:-1 Y:-1];
        mLocateJWD = [[Point2D alloc]initWithX:-1 Y:-1];
        btnArr = [[NSMutableArray alloc]initWithCapacity:20];
        m_mapControl.map.delegate = self;
        m_mapControl.delegate = self;
        mMulColManager= [[MuiColManager alloc]initWithMapControl:mapControl];
        mMulColManager.mapManager = self;
        mPlotManager = [[PlotManager alloc]initWithMapControl:mapControl];
        
        mMQManager = [[MQManager alloc]initWithMapControl:mapControl];
        mMQManager.mapManager = self;
    }
    return self;
}

static int tag = -1;
-(void)drawLocationUpPos:(NSDictionary*)points{
    
    for(int i=0;i<tag;i++)
        [mDynamicView removeElementWithTag:[NSString stringWithFormat:@"%i",i]];
    
    tag = 0;
    Point2D* pos;
    for(NSString* key in points.allKeys){
        DynamicStyle* style = [[DynamicStyle alloc]init];
        style.radius = 15;
        style.bitmap = [UIImage imageNamed:@"location.png"];
        DynamicPoint* dynPoint = [[DynamicPoint alloc]init];
        pos = [self p_exchangePos:points[key]];
        [dynPoint addPoint:pos];
        dynPoint.tag = [NSString stringWithFormat:@"%i",tag++];
        dynPoint.style = style;
        [mDynamicView addElement:dynPoint];
    }
    [self refresh];
}
-(void)load{
    
    for(UIView* view in m_mapControl.subviews){
        
        if( (view.tag>=1 && view.tag<=3)){
            for(UIView* each in view.subviews){
                if([each isKindOfClass:[UIButton class]]){
                    UIButton* btn = (UIButton*)each;
                 //   NSLog(@"~~~%i",btn.tag);
                    [btn removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
                    [btn addTarget:self action:@selector(touchEvent:) forControlEvents:UIControlEventTouchUpInside];
                    if(btn.tag>=11 && btn.tag<=15)
                        [btnArr addObject:btn];
                }else if (each.tag == 101){
                    mMQManager.messagePush = each;
                }
            }
            if(view.tag == 2)
                mulCal = view;
            else if (view.tag == 3)
                plot = view;
            
        }else if (view.tag==16 || view.tag==17 || view.tag==24){
            UIButton* btn = (UIButton*)view;
            [btn removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(touchEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            if(view.tag == 24)
                mMulColManager.btnStopVoice = view;
        }else if (view.tag == 4){//plot
            mPlotManager.plotView = view;
        }else if (view.tag == 5){
            mMQManager.textLookUp = view;
        }else if (view.tag==6){
            mMQManager.messageSend = view;
        }
    }
    
    [mPlotManager load];
    [mMulColManager load];
    [mMQManager load];
}

-(void)location{
    if(mLocatePos.x==-1 || mLocatePos.y==-1){
       // Toast* toast = [[Toast alloc]init];
        [Toast show:@"亲，暂时无法获取位置"];
        return;
    }
    [self p_drawCurPos:mLocatePos angle:0];
    [m_mapControl panTo:mLocatePos time:400];
}

-(Point2D*)p_exchangePos:(Point2D*)pt
{
    if ([m_mapControl.map.prjCoordSys type]!= PCST_EARTH_LONGITUDE_LATITUDE) {//若投影坐标不是经纬度坐标则进行转换
        Point2Ds *points = [[Point2Ds alloc]init];
        [points add:pt];
        PrjCoordSys *srcPrjCoorSys = [[PrjCoordSys alloc]init];
        [srcPrjCoorSys setType:PCST_EARTH_LONGITUDE_LATITUDE];
        CoordSysTransParameter *param = [[CoordSysTransParameter alloc]init];
        
        //根据源投影坐标系与目标投影坐标系对坐标点串进行投影转换，结果将直接改变源坐标点串
        [CoordSysTranslator convert:points PrjCoordSys:srcPrjCoorSys PrjCoordSys:[m_mapControl.map prjCoordSys] CoordSysTransParameter:param CoordSysTransMethod: (CoordSysTransMethod)9603 ];
        pt = [points getItem:0];
    }
    
    return pt;
}
#pragma mark GPS信息回调
-(void)locationChanged:(GPSData *)oldData newGps:(GPSData *)newData{
    
    Point2D *pt = [[Point2D alloc]initWithX:newData.dLongitude Y:newData.dLatitude];
    mLocateJWD.x = pt.x;
    mLocateJWD.y = pt.y;
    
    pt = [self p_exchangePos:pt];
    mLocatePos.x = pt.x;
    mLocatePos.y = pt.y;
    
    if(isFirstShow){
        [self p_drawCurPos:mLocatePos angle:0];
        isFirstShow = NO;
    }
}

#pragma mark 回调
-(void) scaleChanged:(double) newscale{
    
    [self p_drawCurPos:mLocatePos angle:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    isSelected = NO;
    if([touches count]>1)
        isDoubleFinger = YES;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    isMoveing = YES;
    isSelected = YES;
    if([touches count]>1)
        isDoubleFinger = YES;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([touches count]>1)
        isDoubleFinger = YES;
    //只是移动地图，不做选择处理
    if(isMoveing)
    {
        isMoveing = NO;
        return;
    }
    
    if(!isDoubleFinger && !isSelected){
        UITouch *touch = [touches anyObject];
        // 初始化起始点和结束点
        CGPoint point = [touch locationInView:m_mapControl];
        Recordset* rd = [self p_query:CGPointMake(point.x, point.y)];
    //    NSLog(@"%.12f \n %.12f",[(NSNumber*)[rd getFieldValueWithString:@"SmX"] doubleValue],[(NSNumber*)[rd getFieldValueWithString:@"SmY"] doubleValue]);
        [mMulColManager dealRecord:rd];
    }
     isDoubleFinger = NO;
}
#pragma mark private
//自定义选择算法
-(Recordset*)p_query:(CGPoint)point //dataset:(NSString*)datasetName
{
    double dLenthTele;
    Recordset* rd;
    double telerance = 15;
    Point2D* touchCenter = [m_mapControl.map pixelTomap:point];
    Point2D* leftBottom = [m_mapControl.map pixelTomap:CGPointMake(point.x-telerance*[UIScreen mainScreen].scale, point.y+telerance*[UIScreen mainScreen].scale)];
    double dx = ABS((touchCenter.x-leftBottom.x));
    double dy = ABS((touchCenter.y-leftBottom.y));
    dLenthTele = sqrt(dx*dx + dy*dy);

    //NSLog(@"%f",dLenthTele);
    rd = [(DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:0] queryWithBounds:m_mapControl.map.bounds Type:STATIC];
    int i=0,j=-1;
    double lenth=0;
    while(rd!=nil && ![rd isEOF]){
        Point2D* tmpPos = [[rd geometry] getInnerPoint];
        Point2Ds *points = [[Point2Ds alloc]init];
        [points add:tmpPos];
        PrjCoordSys *srcPrjCoorSys = [[PrjCoordSys alloc]init];
        [srcPrjCoorSys setType:PCST_EARTH_LONGITUDE_LATITUDE];
        CoordSysTransParameter *param = [[CoordSysTransParameter alloc]init];
        
        //根据源投影坐标系与目标投影坐标系对坐标点串进行投影转换，结果将直接改变源坐标点串
        [CoordSysTranslator convert:points PrjCoordSys:srcPrjCoorSys PrjCoordSys:[m_mapControl.map prjCoordSys] CoordSysTransParameter:param CoordSysTransMethod: (CoordSysTransMethod)9603 ];
        tmpPos = [points getItem:0];
        double dx = ABS((tmpPos.x-touchCenter.x));
        double dy = ABS((tmpPos.y-touchCenter.y));
        double dLength = sqrt(dx*dx + dy*dy);
        
        if(dLength <= dLenthTele){
            if(lenth == 0){
                lenth = dLength;
                j=i;
            }else if (dLength < lenth){
                lenth = dLength;
                j = i;
            }
        }
        i++;
        [rd moveNext];
    }
    [rd moveTo:j];
    
    return rd;
}


-(void)p_clear
{
    for(UIButton* btn in btnArr){
        btn.selected = NO;
        mulCal.hidden = YES;
        plot.hidden = YES;
    }
}

-(void)p_submit{
    
    if(m_mapControl.action==VERTEXEDIT ||
       m_mapControl.action==CREATE_FREE_POLYLINE||
       m_mapControl.action==CREATE_FREE_DRAWPOLYGON||
       m_mapControl.action==CREATE_FREE_DRAW||
       m_mapControl.action==CREATE_PLOT
       ){
        [m_mapControl submit];
        Recordset* rd = [((DatasetVector*)[m_mapControl.map.layers getLayerAtIndex:0].dataset) recordset:NO cursorType:DYNAMIC];
        [rd moveLast];
        [rd edit];
        NSDate *date = [NSDate date];
        NSString *time = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
        [rd setStringWithName:@"PlotID" StringValue:time];
        [rd update];
        [rd dispose];
        [m_mapControl setAction:SELECT];
        [m_mapControl.map refresh];
    }
    
}
-(void)touchEvent:(UIButton*)btn{
    
    NSLog(@"%i",btn.tag);
    static BOOL turn = YES;
    static BOOL turn1 = YES;
    [self p_clear];
    int index = btn.tag;
    
    //多媒体采集
    if(index>20 && index<30){
         [mMulColManager touchEvent:btn];
        turn = YES;
        turn1 = YES;
        return;
    }
    
    //标绘
    if(index>30 && index<40){
        [mPlotManager touchEvent:btn];
        turn = YES;
        turn1 = YES;
        return;
    }
    
    [self p_submit];
    switch (index) {
        case 11:{
            if(turn){//多媒体采集二级菜单
                btn.selected = YES;
                mulCal.hidden = NO;
                turn1 = YES;
            }
            turn = !turn;
            break;
        }case 12:{//标绘二级菜单
            if(turn1){
                btn.selected = YES;
                plot.hidden = NO;
                turn = YES;
            }
            turn1 = !turn1;
            break;
        }
        case 13://发送数据
        case 14://消息查看
        case 15://文本消息
        case 16://位置上传
            [mMQManager touchEvent:btn];
            break;
        case 17://消息开关
        {
            [self p_turnOnMessage:btn];
            break;
        }default:
            break;
    }

}

-(void)p_turnOnMessage:(UIButton*)btn{
    
    if(![MQToolKit isNetworkEnabled]){
        [Toast show:@"亲,当前网络不可用"];
        return;
    }
    if(!btn.selected){
        
        //todo connect
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        // 执行异步任务
        dispatch_async(queue, ^(void){
            [mMQManager connect];
            [mMQManager receiveMessage];
            [mMulColManager login];
            [mMulColManager uploadMediaFile];
        });
    
        self.isReceiveMessage = YES;
        btn.selected = YES;
        [Toast show:@"开启消息接收"];
    }else{
        self.isReceiveMessage = NO;
        btn.selected = NO;
        [mMQManager clear];
        [Toast show:@"关闭消息接收"];
    }
 
}
-(Point2D*)p_drawCurPos:(Point2D*)pos angle:(double)angle{
    
   
//    [mDynamicView removeElementWithTag:@"circile"];
//    
//    double dX = pos.x-510;
//    Point2D* posTmp = [[Point2D alloc]initWithX:dX Y:pos.y];
//    
//    CGPoint pixPos2= [m_mapControl.map mapToPixel:posTmp];
//    CGPoint pixPos1= [m_mapControl.map mapToPixel:pos];
//    
//    int radious = pixPos1.x-pixPos2.x;
//    
//    DynamicStyle* style = [[DynamicStyle alloc]init];
//    style.radius = radious;
//    style.brushColor = [UIColor colorWithRed:189.0f/255.0f green:204.0f/255.0f blue:209.0f/255.0f alpha:0.3f];
//    
//    DynamicPoint* point = [[DynamicPoint alloc]init];
//    [point addPoint:pos];
//    
//    point.style = style;
//    point.tag = @"circile";
    
    [mDynamicView removeElementWithTag:@"curPos"];
    DynamicPoint* currentPos = [[DynamicPoint alloc]init];
    [currentPos addPoint:pos];
    
    
   DynamicStyle* style = [[DynamicStyle alloc]init];
    
    style.radius = 15;
    style.bitmap = [UIImage imageNamed:@"navi_start.png"];
    currentPos.style=style;
    currentPos.style.rotaAngle = angle;
    currentPos.tag = @"curPos";
    [mDynamicView addElement:currentPos];
    
    [self refresh];
    
    return pos;
    
}

-(void)refresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_mapControl.map refresh];
    });
}
@end
