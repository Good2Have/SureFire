//
//  User.h
//  Tinder
//
//  Created by Elluminati - macbook on 07/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    
}
@property(nonatomic,copy)NSString *fbid;
@property(nonatomic,copy)NSString *first_name;
@property(nonatomic,copy)NSString *last_name;
@property(nonatomic,copy)NSString *sex;
@property(nonatomic,copy)NSString *push_token;
@property(nonatomic,copy)NSString *curr_lat;
@property(nonatomic,copy)NSString *curr_long;
@property(nonatomic,copy)NSString *dob;
@property(nonatomic,copy)NSString *profile_pic;
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *emailForPaypal;

@property(nonatomic,assign)int numberOfSparkAlertPending;
@property(nonatomic,assign)int numberOfFriends;

@property(nonatomic,assign)int flag;

@property(nonatomic,assign)int freeCredits;
@property(nonatomic,assign)int purchasedCredits;


+(User *)currentUser;
-(void)setUser;
-(void)setAvalableCredits;

@end
