//
//  MQManager.h
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/19.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SuperMap.h"
#import "AMQPManager.h"
#import "AMQPSender.h"
#import "AMQPReceiver.h"

@class MapManager;
@interface MQManager : NSObject<UITextFieldDelegate>
{
    AMQPManager* amqManager;
    AMQPSender* amqpSender;
    
    NSString* txtMessageQueue,*geometryQueue,*locationQueue,*mulMediaQueue; //声明四个队列来处理不同信息
}

@property(nonatomic,strong)UIView* messageSend;
@property(nonatomic,strong)UIView* textLookUp;
@property(nonatomic,strong)UIView* messagePush;
@property(nonatomic,strong)MapManager* mapManager;
-(id)initWithMapControl:(MapControl*)mapControl;
-(void)load;
-(void)connect;
-(void)touchEvent:(UIButton*)btn;

-(void)receiveMessage;
-(void)sendMessage:(NSString*)message type:(int)type;//文本0 plot 1，location 2 多媒体3
-(void)clear;
@end
