//
//  ViewController.h
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/15.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperMap.h"

@interface ViewController : UIViewController
{
    IBOutlet MapControl *m_mapcontrol;
    
    Workspace *_workspace;
    DatasourceConnectionInfo *m_ConnectionInfo;
    WorkspaceConnectionInfo *m_Info;
    Datasource *m_datasource;
    DatasetVector *m_dataset;
    Datasets *m_datasets;
}

@end

