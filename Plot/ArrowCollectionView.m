//
//  ArrowCollectionView.m
//  PlotDemo
//
//  Created by imobile-xzy on 15/7/28.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "ArrowCollectionView.h"
#import "Toast.h"
#import "SuperMap.h"
#import "PlotManager.h"

@implementation ArrowCollectionView
@synthesize cellArr,libID,path;
@synthesize collectionView = mCollectionView;
-(id)initWithFrame:(CGRect)frame{
    
    if(self=[super init]){
        
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        mCollectionView=[[UICollectionView alloc] initWithFrame:frame  collectionViewLayout:flowLayout];
        
        mCollectionView.dataSource = self;
        mCollectionView.delegate = self;
        [mCollectionView setBackgroundColor:[UIColor clearColor]];
        
        //注册Cell，必须要有
        [mCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        
        self.libID = -1;
    }
    return self;
}

#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.cellArr count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 53, 50, 10)];

    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:10];
    label.textAlignment = NSTextAlignmentCenter;
    NSString* codeStr = [self.cellArr[indexPath.row] stringByReplacingOccurrencesOfString:@".png" withString:@""];
    label.text = codeStr;//[NSString stringWithFormat:@"%d",indexPath.row];
    
    NSString* filePath = [self.path stringByAppendingString:self.cellArr[indexPath.row]];
    NSData* data = [[NSData alloc]initWithContentsOfFile:filePath];
    UIImageView* img = [[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
    img.frame = CGRectMake(0, 0, 50, 50);
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:img];
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 60);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}
#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.libID == -1){
      //  Toast* toast = [[Toast alloc]init];
        [Toast show:@"亲,符号数据还在加载中..."];
        return;
    }
    NSString* codeStr = [self.cellArr[indexPath.row] stringByReplacingOccurrencesOfString:@".png" withString:@""];
   // [self.mapControl setAction:CREATE_PLOT];
    [self.manager drawPlot:self.libID code:[codeStr intValue] ];
   // [self.manager setPlotSymbol:self.libID symbolCode:[codeStr intValue]];
    
   // Toast* toast = [[Toast alloc]init];
    [Toast show:@"开始绘制..."];
 //   NSLog(@"item======%@",codeStr);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
