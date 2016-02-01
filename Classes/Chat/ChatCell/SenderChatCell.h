//
//  SenderChatCell.h
//  SureFire
//
//  Created by soumya ranjan sahu on 29/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SenderChatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *chatBubbleImageView;

@end
