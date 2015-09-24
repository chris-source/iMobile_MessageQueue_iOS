//
//  TxtLookUp.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/20.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "TxtLookUp.h"
#import "TxtLookUpCell.h"

@interface TxtLookUp()
{
    UILabel* mDetailName,*mDetailTime,*mDetailContext;
}
@end
@implementation TxtLookUp
@synthesize tableView,datasource,detail;
#pragma mark - Table view data source

-(void)load{
    [self.tableView reloadData];
    
    for(UIView* view in self.detail.subviews){
        if(view.tag==1)
            mDetailName = view;
        else if (view.tag==2)
            mDetailTime = view;
        else{
            mDetailContext = view;
            [((UILabel*)mDetailContext) setNumberOfLines:0];
            // 缩略方式
            ((UILabel*)mDetailContext).lineBreakMode = NSLineBreakByTruncatingTail;
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

// 设置单元格行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 51;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.datasource count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString* indentifier = @"myCell";
     TxtLookUpCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
 
     if (cell == nil){
         cell = [[[NSBundle mainBundle] loadNibNamed:@"TxtLookUpCell" owner:self options:nil] objectAtIndex:0];;//[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
     }
    // cell.textLabel.text = @"test";
     NSArray* arr = self.datasource[indexPath.row];
     cell.lable1.text = [NSString stringWithFormat:@"%i",indexPath.row+1];
     cell.lable2.text = arr[1];//[NSString stringWithFormat:@"消息%i",indexPath.row];
     cell.lable3.text = arr[0];//[NSString stringWithFormat:@"发送者:%i",indexPath.row];
     return cell;
 }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* arr = self.datasource[indexPath.row];
    self.tableView.hidden = YES;
    self.detail.hidden = NO;
    
    mDetailName.text = [NSString stringWithFormat:@"发送者:%@",arr[0]];
    mDetailTime.text = arr[2];
    mDetailContext.text = arr[1];
}

@end
