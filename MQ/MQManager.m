//
//  MQManager.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/19.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "MQManager.h"
#import "TxtLookUp.h"
#import "MapManager.h"
#import "Toast.h"
#import "MuiColManager.h"
#import "MQToolKit.h"

@interface MQManager()
{
    MapControl* m_mapControl;
    TxtLookUp* mTxtLookUp;
    UITextField* mTextField;
    
    int mMessagePushCount;
    NSMutableArray* mMessageArr;
    NSMutableSet* mPlotSet;
    NSMutableDictionary* mLocationUpPos;
    
    NSMutableArray* mQueueArr;
    NSString* mUsrId;
}
@end
@implementation MQManager
@synthesize textLookUp,messageSend,mapManager,messagePush;

static NSString* MQExchange = @"MQDemo_topic_exchange";
static NSString* txtMessageQueue = @"";
static BOOL isConnect = NO, isReceive = NO;;
//static NSString* routingkey ;
-(id)initWithMapControl:(MapControl*)mapControl{
    
    if(self = [super init]){
        m_mapControl = mapControl;
        amqManager = [[AMQPManager alloc]init];
        mTxtLookUp = [[TxtLookUp alloc]init];
        mMessageArr = [[NSMutableArray alloc]initWithCapacity:10];
        mLocationUpPos = [[NSMutableDictionary alloc]initWithCapacity:10];
        mQueueArr = [[NSMutableArray alloc]initWithCapacity:5];
        mPlotSet = [[NSMutableSet alloc]initWithCapacity:20];//[[NSMutableArray alloc]initWithCapacity:10];
        //mMessagePush = [[NSMutableArray alloc]initWithCapacity:10];;
        mTxtLookUp.datasource = mMessageArr;
        mMessagePushCount = 0;
    }
    return self;
}

-(void)touchEvent:(UIButton*)btn{
    
    if(!self.mapManager.isReceiveMessage)
    {
        [Toast show:@"请打开消息接收"];
        return;
    }
    
    if(![MQToolKit isNetworkEnabled]){
        [Toast show:@"亲,当前网络不可用"];
        return;
    }
    
    if(btn.tag == 14){
        self.textLookUp.hidden = NO;
        mMessagePushCount = 0;
        self.messagePush.hidden = YES;
        self.messageSend.hidden = YES;
    }else if(btn.tag==15){
         self.textLookUp.hidden = YES;
        self.messageSend.hidden = NO;
    }else if (btn.tag==13){
        [self sendMessage:nil type:1];
    }else if (btn.tag==16){
        Point2D* pos = self.mapManager.locationJWD;
        NSString* posStr = [pos toJson];
        [self sendMessage:posStr type:2];
    }
}
-(void)p_click:(UIButton*)btn{
    if(btn.tag == 3){
        if(mTxtLookUp.detail.hidden == NO){
            mTxtLookUp.detail.hidden = YES;
            mTxtLookUp.tableView.hidden = NO;
        }else
            self.textLookUp.hidden = YES;
    }else if (btn.tag == 2){
        self.messageSend.hidden = YES;
        [mTextField resignFirstResponder];
    }else{
        self.messageSend.hidden = YES;
        [self sendMessage:mTextField.text type:0];
        mTextField.text = @"";
        [mTextField resignFirstResponder];
    }
}
-(void)load{
    for(UIView* view in self.textLookUp.subviews){
        if([view isKindOfClass:[UIButton class]]){
            UIButton* btn = view;
            [btn addTarget:self action:@selector(p_click:) forControlEvents:UIControlEventTouchUpInside];
        }else if (view.tag == 1)
             mTxtLookUp.tableView = view;
        else if (view.tag==2){
            mTxtLookUp.detail = view;
        }
    }
   
    mTxtLookUp.tableView.delegate = mTxtLookUp;
    mTxtLookUp.tableView.dataSource = mTxtLookUp;
    [mTxtLookUp load];
    
    for(UIView* view in self.messageSend.subviews){
        if(view.tag==6){
            for(UIView* each in view.subviews)
                if(each.tag == 1 || each.tag == 2){
                    UIButton* btn = each;
                    [btn addTarget:self action:@selector(p_click:) forControlEvents:UIControlEventTouchUpInside];
                }
        }
        if (view.tag==3){
            mTextField = view;
            mTextField.delegate = self;
            CGRect rect = mTextField.frame;
            rect.size.height += 170;
            mTextField.frame = rect;
        }
    }
    
    self.messagePush.layer.borderWidth = 1;
    self.messagePush.layer.cornerRadius = 13;
    self.messagePush.layer.borderColor = [[UIColor redColor] CGColor];
}

-(void)connect{
    
    UIDevice* device = [[UIDevice alloc]init];
    mUsrId = [device.identifierForVendor.UUIDString stringByAppendingString:device.name];
    
    if(!isConnect)
    {
            if(![amqManager connection:@"182.92.150.115" port:5672 hostname:@"/sm/sensors" usrname:@"supermap" password:@"supermap123" clientId:mUsrId])
                // if(![amqManager connection:@"192.168.18.162" port:5672 hostname:@"/" usrname:@"xiezhiyan" password:@"xzy@imobile" clientId:mUsrId])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Toast show:@"连接消息总线服务失败"];
                });
                return;
            }else{
                isConnect = YES;
                if(![amqManager declareExchange:MQExchange Type:Topic]){
                    NSLog(@"创建交换机失败");
                }
                
                txtMessageQueue = [[NSString stringWithFormat:@"%@_txtMessage_%@",device.name,device.identifierForVendor.UUIDString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                locationQueue = [[NSString stringWithFormat:@"%@_locationUp_%@",device.name,device.identifierForVendor.UUIDString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                geometryQueue = [[NSString stringWithFormat:@"%@_plot_%@",device.name,device.identifierForVendor.UUIDString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                mulMediaQueue = [[NSString stringWithFormat:@"%@_mulMedia_%@",device.name,device.identifierForVendor.UUIDString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                NSLog(@"%@",txtMessageQueue);
                
                if(![amqManager declareQueue:txtMessageQueue]){
                    NSLog(@"txtMessageQueue创建队列失败");
                }
                if(![amqManager declareQueue:locationQueue]){
                    NSLog(@"locationQueue创建队列失败");
                }
                if(![amqManager declareQueue:geometryQueue]){
                    NSLog(@"geometryQueue创建队列失败");
                }
                if(![amqManager declareQueue:mulMediaQueue]){
                    NSLog(@"mulMediaQueue创建队列失败");
                }
                
                if(![amqManager bindQueue:txtMessageQueue exchange:MQExchange routingkey:@"txtMessage"]){
                    NSLog(@"绑定失败");
                }
                if(![amqManager bindQueue:locationQueue exchange:MQExchange routingkey:@"locationUp"]){
                    NSLog(@"绑定失败");
                }
                if(![amqManager bindQueue:geometryQueue exchange:MQExchange routingkey:@"plot"]){
                    NSLog(@"绑定失败");
                }
                if(![amqManager bindQueue:mulMediaQueue exchange:MQExchange routingkey:@"mulMedia"]){
                    NSLog(@"绑定失败");
                }
                
                amqpSender  = [amqManager newSender];
           }
        
    }
    
    if([mQueueArr count]==0 && isConnect){
        AMQPReceiver* amqpReceiver = [amqManager newReceiver:txtMessageQueue];
        [mQueueArr addObject:amqpReceiver];
        amqpReceiver = [amqManager newReceiver:locationQueue];
        [mQueueArr addObject:amqpReceiver];
        amqpReceiver = [amqManager newReceiver:geometryQueue];
        [mQueueArr addObject:amqpReceiver];
        amqpReceiver = [amqManager newReceiver:mulMediaQueue];
        [mQueueArr addObject:amqpReceiver];
    }

}

-(void)sendMessage:(NSString*)message type:(int)type{
    
    if(type==0)
        [amqpSender sendMessage:MQExchange routingKey:@"txtMessage" message:[NSString stringWithFormat:@"{content_type=3}%@",message]];
    else if (type==2)
        [amqpSender sendMessage:MQExchange routingKey:@"locationUp" message:[NSString stringWithFormat:@"{content_type=0}%@",message]];
    else if (type == 1){
        
        NSString* msg = nil;
        Recordset* rd = [((DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:1]) recordset:NO cursorType:DYNAMIC];
        
        NSString* plotID ;
        while (![rd isEOF]) {
            msg = @"{content_type=2}";
            plotID = (NSString*)[rd getFieldValueWithString:@"PlotID"];//rd getFieldValue("PlotID").toString();
            if ([mPlotSet containsObject:plotID]){
                [rd moveNext];
                continue;
            }
            GeometryType type = rd.geometry.getType;
            NSString* geoJson = [rd.geometry toXML];
            msg = [msg stringByAppendingFormat:@"{PlotID=%@}{type=%i}%@",plotID,type,geoJson];
            [mPlotSet addObject:plotID];
            [amqpSender sendMessage:MQExchange routingKey:@"plot" message:msg];
            [rd moveNext];
        }
        [rd dispose];
    }else if (type == 3)
        [amqpSender sendMessage:MQExchange routingKey:@"mulMedia" message:message];
}

-(void)dealThreadTask:(AMQPReceiver*)receiver{
    
    while (1) {
        sleep(2);
        if (!self.mapManager.isReceiveMessage) {
            [receiver dispose];
            [mQueueArr removeObject:receiver];
            receiver = nil;
            return;
        }
        NSString* userId = nil,*message = nil;
        [receiver receiveMessage:&userId message:&message];
        
        if(message==nil || userId==nil)
            continue;
        
        NSRange range = [message rangeOfString:@"content_type="];
        NSString* type = nil;
        if(range.length == 0)
            type = nil;
        else{
            NSRange rangeTmp = {range.location+range.length,1};
            type = [message substringWithRange:rangeTmp];
        }
        
            
        if([type isEqualToString:@"3"]){
            
            if(![userId isEqualToString:mUsrId]){
                    message = [message substringFromIndex:range.length+range.location+2];
                    NSDate* date = [NSDate date];
                    NSString* time = [NSString stringWithFormat:@"格林威治时间:%@",date];
                    [mMessageArr addObject:@[userId,message,time]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [mTxtLookUp.tableView reloadData];
                        if(self.textLookUp.hidden == YES){
                            self.messagePush.hidden = NO;
                            mMessagePushCount++;
                            ((UILabel*)self.messagePush.subviews[0]).text = [NSString stringWithFormat:@"%i",mMessagePushCount];
                        }
                });
            }
        }else if ([type isEqualToString:@"0"]){//位置上传
            
            if(![userId isEqualToString:mUsrId])
            {
                Point2D* pos = [[Point2D alloc]init];
                NSString* json = [message substringFromIndex:range.length+range.location+2];
                NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                [pos fromJson:object];
                mLocationUpPos[userId] = pos;
                [self.mapManager drawLocationUpPos:mLocationUpPos];
                NSLog(@"位置上传");
            }
        }else if ([type isEqualToString:@"2"]){
            if(![userId isEqualToString:mUsrId]){
                [self dealXMLData:message];
            }
        }else if ([type isEqualToString:@"1"]){
            if(![userId isEqualToString:mUsrId])
            [self.mapManager.mulColManager updataMediaDataset];
        }
        
    }

}
-(void)refresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_mapControl.map refresh];
    });
}
-(void)dealXMLData:(NSString*)xml{
    
    NSError* error;
    NSString* re = @"PlotID=([0-9]+)\\}\\{type=([0-9]+)\\}";
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:re options:NSRegularExpressionCaseInsensitive error:&error];
    NSString* str=xml;
    
    NSString* plotID;
    NSString* geometryType;
    NSRange range;
    
    if(regex){
        NSArray* results = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [str length])];
        
        if([results count]>0){
            for (NSTextCheckingResult* b in results)
            {
                 range = b.range;
                 plotID = [str substringWithRange:[b rangeAtIndex:1]];
                 geometryType = [str substringWithRange:[b rangeAtIndex:2]];
            }
            
        }else
            return;
    }
    
    NSString* xmlStr = [xml substringFromIndex:range.location+range.length];
    if(plotID==nil || geometryType==nil || xmlStr==nil){
        NSLog(@"Geometry 格式不合法");
    }else{
        DatasetVector* dv = ((DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:1]) ;
        Recordset* rd = [dv queryWithFilter:[NSString stringWithFormat:@"PlotID='%@'",plotID] Type:STATIC];
        int count = [rd recordCount];
        [rd dispose];
        rd = nil;
        if(count>0){
            return;
        }
        GeometryType type = (GeometryType)[geometryType integerValue];
        Geometry* geo;
        GeoStyle* style = [[GeoStyle alloc]init];
        [style setFillForeColor:[[Color alloc]initWithR:189 G:235 B:255]];
        [style setLineWidth:1.0];

        if(type == GT_GEOREGION){
            geo = [[GeoRegion alloc]init];
            [style setLineColor:[[Color alloc]initWithR:91 G:89 B:91]];
        }else if (type == GT_GEOLINE){
            geo = [[GeoLine alloc]init];
            [style setLineColor:[[Color alloc]initWithR:127 G:127 B:127]];
        }else{
            geo = [[GeoGraphicObject alloc]init];
        }
        BOOL res = NO;
        if([geo fromXML:xmlStr]){
            Recordset* rd = [((DatasetVector*)[[m_mapControl.map.workspace.datasources get:1].datasets get:1]) recordset:NO cursorType:DYNAMIC];
            if (type != GT_PLOT)
                [geo setStyle:style];
            res = [rd addNew:geo];
            [rd edit];
            [rd setStringWithName:@"PlotID" StringValue:plotID];
            [rd update];
            [rd dispose];
            [self refresh];
        }
    }

}
-(void)receiveMessage{

//    if(isReceive)
//        return;
    
    for(AMQPReceiver* receiver in mQueueArr){
        dispatch_queue_t concurrentQueue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue,^{
            [self dealThreadTask:receiver];
        });
    }
 //   isReceive = YES;
}

-(void)clear{
    self.textLookUp.hidden = YES;
    self.messageSend.hidden = YES;
    [mPlotSet removeAllObjects];
}
static double offsetY = 100;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    CGRect rect = self.messageSend.frame;
    rect.origin.y -= offsetY;
    self.messageSend.frame = rect;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    CGRect rect = self.messageSend.frame;
//    rect.origin.y += offsetY;
//    self.messageSend.frame = rect;
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect rect = self.messageSend.frame;
    rect.origin.y += offsetY;
    self.messageSend.frame = rect;
}
@end
