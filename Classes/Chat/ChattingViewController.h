//
//  ChattingViewController.h
//  SureFire
//
//  Created by soumya ranjan sahu on 29/01/15.
//  Copyright (c) 2015 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChattingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, sendMessageDelegate, UIActionSheetDelegate, UITextFieldDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *chatTextField;
@property (strong, nonatomic) IBOutlet UIView *chatBackView;

@property (retain, nonatomic) NSMutableArray *messageArray;
@property (retain, nonatomic) NSString *userFbId;
@property (strong, nonatomic) NSString *friendFbId;
@property (strong, nonatomic) NSString *currentMessage;
@property (retain, nonatomic) NSString *ChatPersonNane;
@property (strong , nonatomic) NSString *matchedUserProfileImagePath;
@property (nonatomic) BOOL scrollToBottom;
@property (nonatomic) BOOL isFirstTime;
@property (strong, nonatomic) UIView *customSlidingView;
@property (strong, nonatomic) NSMutableDictionary *dictUser;
@property (strong , nonatomic) NSString *status;

@property (nonatomic,strong)User *userFriend;

- (IBAction)buttonSendTapped:(id)sender;

@end
