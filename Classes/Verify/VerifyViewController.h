//
//  VerifyViewController.h
//  SureFire
//
//  Created by Matthieu on 1/15/16.
//  Copyright © 2016 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyViewController : UIViewController<PPRevealSideViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate>
{
    NSURL *videoURL;
}
@property (weak, nonatomic) IBOutlet UIView *viewNonVerified;
@property (weak, nonatomic) IBOutlet UIButton *btnVerifyNow;
- (IBAction)clickStartVerify:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *viewPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestCode;
- (IBAction)clickRequestCode:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *viewEnterCode;
@property (weak, nonatomic) IBOutlet UITextField *txtVerificationCode;
@property (weak, nonatomic) IBOutlet UIButton *btnResendCode;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@property (weak, nonatomic) IBOutlet UIView *viewSendVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnSendVideo;
@property (weak, nonatomic) IBOutlet UIView *viewVideoContainer;
- (IBAction)clickSendVideo:(id)sender;


- (IBAction)clickResendCode:(id)sender;
- (IBAction)clickConfirmCode:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *viewPending;
@property (weak, nonatomic) IBOutlet UIButton *btnUnsubscribeInPending;

@property (weak, nonatomic) IBOutlet UIView *viewVerified;
@property (weak, nonatomic) IBOutlet UIButton *btnUnsubscribeInVerified;

-(void) purchaseFinished;
-(void) purchaseFailed;
- (void) showView:(UIView*) v;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollFirstPgae;
@property (weak, nonatomic) IBOutlet UIPageControl *pcFirstPage;
- (IBAction)onPageControlClicked:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPhoneNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSmscode;

@end
