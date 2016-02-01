//
//  QuestionVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 26/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "QuestionVC.h"
#import "ViewQA.h"
#import "JSON.h"
#import "NSUserDefaults+RMSaveCustomObject.h"
@interface QuestionVC ()

@end

@implementation QuestionVC

@synthesize arrSelectedAns;

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}


- (void)showMessageIcon
{
    [APPDELEGATE addrightButton:self.navigationItem];
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"Match Questions"];
    [APPDELEGATE addBackButton:self.navigationItem];
    [APPDELEGATE addrightButton:self.navigationItem];
    
    arrQuestions=[[NSMutableArray alloc]init];
    arrSelectedAns=[[NSMutableArray alloc]init];
    [self getAllQuestions];
    currentPage=0;
    self.btnPrev.hidden=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageIcon) name:@"MessageCount" object:nil];

    [ChatViewController checkMetches];
    
}

#pragma mark -
#pragma mark - Methods

-(void)getAllQuestions
{
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_QUESTION withParamData:dictParam withBlock:^(id response, NSError *error) {
        [arrQuestions removeAllObjects];
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                NSArray *arr=[response objectForKey:@"detail_que"];
                if (arr) {
                    [arrQuestions addObjectsFromArray:arr];
                }
            }
        }
        [self setScrollView];
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
}

-(void)setScrollView
{
    [self.scrQue setContentSize:CGSizeMake(self.scrQue.frame.size.width*[arrQuestions count], self.scrQue.frame.size.height)];
    
    int x=0;
    for (int i=0; i<[arrQuestions count]; i++)
    {
        CGRect rect=self.scrQue.frame;
        rect.origin.x=x;
        ViewQA *v=[[ViewQA alloc]initWithFrame:rect];
        v.tag=i+1000;
        v.parent=self;
        if (i == [arrQuestions count]-1) {
            [v setAllViews:[arrQuestions objectAtIndex:i] Submit:YES];
        }else{
            [v setAllViews:[arrQuestions objectAtIndex:i] Submit:NO];
        }
        
        [self.scrQue addSubview:v];
        x+=rect.size.width;
    }
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickClose:(id)sender
{
    arrSelectedAns = [[NSUserDefaults standardUserDefaults] rm_customObjectForKey:@"arrayAnswers"];
    
    if ([arrSelectedAns count]==0) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        SBJsonWriter *jsonWriter = [SBJsonWriter new];
        NSString *jsonString = [jsonWriter stringWithObject:arrSelectedAns];
        if (jsonString!=nil)
        {
            [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Submitting..."];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:jsonString forKey:PARAM_ENT_JSON];
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            
            [afn getDataFromPath:METHOD_GET_QUESTION_ANS_INSERT withParamData:dictParam withBlock:^(id response, NSError *error) {
                if (response) {
                    Show_AlertView(@"Success", @"Answers submitted succesfully");
                }
                [[ProgressIndicator sharedInstance]hideProgressIndicator];
                HomeViewController *c= [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                
                c.didUserLoggedIn = YES;
                c._loadViewOnce = NO;
                UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
                [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                               animated:YES];
                
                PP_RELEASE(c);
                PP_RELEASE(n);
               
            }];
        }
        else{
           
        }
    }
}

-(IBAction)onClickPrev:(id)sender{
    [self.scrQue setContentOffset:CGPointMake(self.scrQue.frame.size.width*(currentPage-1), 0.0f) animated:YES];
}

-(IBAction)onClickNext:(id)sender{
    
    [self.scrQue setContentOffset:CGPointMake(self.scrQue.frame.size.width*(currentPage+1), 0.0f) animated:YES];
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrQue.frame.size.width;
    currentPage = floor((self.scrQue.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (currentPage==0) {
        self.btnPrev.hidden=YES;
        self.btnNext.hidden=NO;
    }
    else if (currentPage==[arrQuestions count]-1) {
        self.btnNext.hidden=YES;
        self.btnPrev.hidden=NO;
    }
    else{
        self.btnNext.hidden=NO;
        self.btnPrev.hidden=NO;
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

