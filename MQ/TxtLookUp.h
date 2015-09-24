//
//  TxtLookUp.h
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/20.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TxtLookUp : NSObject<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSArray* datasource;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UIView* detail;

-(void)load;
@end
