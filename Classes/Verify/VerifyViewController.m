//
//  VerifyViewController.m
//  SureFire
//
//  Created by Matthieu on 1/15/16.
//  Copyright © 2016 AppDupe. All rights reserved.
//

#import "VerifyViewController.h"
#import "MKStoreManager.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VerifyViewController
{
    MPMoviePlayerController *player;
}

@synthesize viewNonVerified, viewPhoneNumber, viewEnterCode, viewVerified, viewPending, viewSendVideo;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setTitle:@"Verification"];
    [APPDELEGATE addBackButton:self.navigationItem];

    self.scrollFirstPgae.delegate = self;
    [self.scrollFirstPgae setPagingEnabled:YES];
    [self.scrollFirstPgae setScrollEnabled:YES];
    
    self.btnVerifyNow.layer.cornerRadius = 5.0f;
    self.btnVerifyNow.layer.masksToBounds = YES;
    
    self.btnRequestCode.layer.cornerRadius = 5.0f;
    self.btnRequestCode.layer.masksToBounds = YES;
    
    self.btnResendCode.layer.cornerRadius = 5.0f;
    self.btnResendCode.layer.masksToBounds = YES;
    
    self.btnConfirm.layer.cornerRadius = 5.0f;
    self.btnConfirm.layer.masksToBounds = YES;
    
    self.btnUnsubscribeInPending.layer.cornerRadius = 5.0f;
    self.btnUnsubscribeInPending.layer.masksToBounds = YES;
    
    self.btnUnsubscribeInVerified.layer.cornerRadius = 5.0f;
    self.btnUnsubscribeInVerified.layer.masksToBounds = YES;
    
    self.btnSendVideo.layer.cornerRadius = 5.0f;
    self.btnSendVideo.layer.masksToBounds = YES;
    
    [self showView:viewNonVerified];
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Verify..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_CHECKVERIFICATION withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
            if ([[response objectForKey:@"success"] boolValue])
            {
                int status = [[response objectForKey:@"bVerify"] integerValue];
                if (status == 1) {
                    [self showView:viewPhoneNumber];
                }else if(status == 2){
                    [self showView:viewPending];
                }else if(status == 3){
                    [self showView:viewVerified];
                }
            }
         }
     }];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"samplevideo" ofType:@"mp4"];
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    [self.viewVideoContainer addSubview:player.view];
    
    [player setControlStyle:MPMovieControlStyleNone];
    
    player.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.viewVideoContainer addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.viewVideoContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0]];
    [self.viewVideoContainer addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewVideoContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [self.viewVideoContainer addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.viewVideoContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0]];
    [self.viewVideoContainer addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewVideoContainer attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    
    [self.viewVideoContainer addSubview:player.view];
}

-(void)viewDidAppear:(BOOL)animated
{
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrollFirstPgae.frame.size.width;
    float fractionalPage = self.scrollFirstPgae.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pcFirstPage.currentPage = page;
}

- (IBAction)clickStartVerify:(id)sender {
    [self purchaseFinished];
    //[[MKStoreManager sharedManager] purchase_verify:self];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.view.frame.size.height == 480 || self.view.frame.size.height == 960){
        if(!self.viewPhoneNumber.hidden){
            self.constraintPhoneNumber.constant = 0;
            [UIView animateWithDuration:0.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionCurlUp
                             animations:^{
                                 self.constraintPhoneNumber.constant = -50;
                             }
                             completion:^(BOOL finished){
                             }];
        }else if(!self.viewEnterCode.hidden){
            self.constraintSmscode.constant = 0;
            [UIView animateWithDuration:0.5
                                  delay:0
                                options: UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.constraintSmscode.constant = -50;
                             }
                             completion:^(BOOL finished){
                             }];
        }
    }
}

- (IBAction)clickRequestCode:(id)sender {
    if(self.txtPhoneNumber.text.length < 10){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                        message:@"Please input correct Phone Number."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:self.txtPhoneNumber.text forKey:PARAM_ENT_PHONE_NUMBER];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_VERIFYUSER withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"success"] boolValue])
             {
                 [self.txtPhoneNumber resignFirstResponder];
                 [UIView animateWithDuration:0.5
                                       delay:0
                                     options: UIViewAnimationCurveEaseIn
                                  animations:^{
                                      self.constraintPhoneNumber.constant = 0;
                                  }
                                  completion:^(BOOL finished){
                                  }];
                 [self showView:viewEnterCode];
             }else{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                                 message:@"Please try again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                             message:@"Please try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (IBAction)clickSendVideo:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *videoRecorder = [[UIImagePickerController alloc] init];
        videoRecorder.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoRecorder.delegate = self;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
            videoRecorder.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        videoRecorder.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        videoRecorder.videoQuality = UIImagePickerControllerQualityTypeMedium;
        videoRecorder.videoMaximumDuration = 10;
        
        [self presentModalViewController:videoRecorder animated:YES];
    }
    else
    {
        //No camera is availble
    }
}

- (IBAction)clickResendCode:(id)sender {
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:self.txtPhoneNumber.text forKey:PARAM_ENT_PHONE_NUMBER];
    
    [self.txtVerificationCode resignFirstResponder];
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.constraintSmscode.constant = 0;
                     }
                     completion:^(BOOL finished){
                     }];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_VERIFYRESENDSMSCODE withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance]hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"success"] boolValue])
             {
             }else{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                                 message:@"Please try again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                             message:@"Please try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (IBAction)clickConfirmCode:(id)sender {
    if(self.txtVerificationCode.text.length != 6){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                        message:@"Verification Code is 6 digits. Please input again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:self.txtVerificationCode.text forKey:PARAM_ENT_SMS_CODE];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_VERIFYSMSCODE withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance] hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"success"] boolValue])
             {
                 [self.txtVerificationCode resignFirstResponder];
                 CGRect rt = self.viewEnterCode.frame;
                 rt.origin.y = 0;
                 [UIView animateWithDuration:0.5
                                       delay:1.0
                                     options: UIViewAnimationCurveEaseOut
                                  animations:^{
                                      self.viewEnterCode.frame = rt;
                                  }
                                  completion:^(BOOL finished){
                                  }];
                 [player play];
                 [self showView:viewSendVideo];
             }else{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                                 message:@"Please try again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                             message:@"Please try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (void) purchaseFinished
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    	
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_PURCHASEDVERIFY withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[ProgressIndicator sharedInstance] hideProgressIndicator];
         if (response)
         {
             if ([[response objectForKey:@"success"] boolValue])
             {
                 [self showView:viewPhoneNumber];
             }
         }
     }];
}

-(void) purchaseFailed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed Purchase"
                                                    message:@"Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *mType = [info valueForKey:UIImagePickerControllerMediaType];
    if([mType isEqualToString:@"public.movie"]){
        videoURL = [info objectForKey:@"UIImagePickerControllerMediaURL"];
        
        NSData *data = [NSData dataWithContentsOfURL:videoURL];
        
        NSString *temp = [data base64EncodedStringWithOptions:0];
        [MBProgressHUD showHUDAddedTo:self.viewSendVideo animated:YES];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        [dictParam setObject:temp forKey:PARAM_ENT_VERIFY_VIDEO];
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_UPLOADVERIFYVIDEO withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.viewSendVideo animated:YES];
             if (response)
             {
                 if ([[response objectForKey:@"success"] boolValue])
                 {
                     [player stop];
                     [self showView:viewPending];
                 }else{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                     message:@"Please upload video again."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
             }else{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                 message:@"Please upload video again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
}

- (void) showView:(UIView*) v
{
    viewNonVerified.hidden = YES;
    viewPhoneNumber.hidden = YES;
    viewEnterCode.hidden = YES;
    viewPending.hidden = YES;
    viewVerified.hidden = YES;
    viewSendVideo.hidden = YES;
    v.hidden = NO;
}

- (IBAction)onPageControlClicked:(id)sender {
    int page = self.pcFirstPage.currentPage;
    CGRect frame = self.scrollFirstPgae.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollFirstPgae scrollRectToVisible:frame animated:YES];
}

@end