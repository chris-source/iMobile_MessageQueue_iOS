//
//  ArrowCollectionView.h
//  PlotDemo
//
//  Created by imobile-xzy on 15/7/28.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapControl;
@class PlotManager;
@interface ArrowCollectionView : NSObject<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView* mCollectionView;
}
@property(nonatomic,strong)UICollectionView* collectionView;
@property(nonatomic,strong)NSArray* cellArr;
@property(nonatomic,strong)NSString* path;
@property(nonatomic,assign)int libID;
//@property(nonatomic,strong)MapControl* mapControl;
@property(nonatomic,strong)PlotManager* manager;
-(id)initWithFrame:(CGRect)frame;
@end
