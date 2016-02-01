//
//  SenderChatCell.m
//  SureFire
//
//  Created by soumya ranjan sahu on 29/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import "SenderChatCell.h"

@implementation SenderChatCell

- (void)awakeFromNib
{
    [self.userImageView.layer setCornerRadius:24];
    [self.userImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.userImageView.layer setBorderWidth:2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
