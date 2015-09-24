//
//  TxtLookUpCell.m
//  MessageDemo
//
//  Created by imobile-xzy on 15/8/20.
//  Copyright (c) 2015年 imobile-xzy. All rights reserved.
//

#import "TxtLookUpCell.h"

@implementation TxtLookUpCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.lable3 setNumberOfLines:0];
    // 缩略方式
    self.lable3.lineBreakMode = NSLineBreakByTruncatingTail;
//    [self.lable2 setNumberOfLines:0];
//    // 缩略方式
//    self.lable2.lineBreakMode = NSLineBreakByTruncatingTail;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
