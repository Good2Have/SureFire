//
//  UserSettings.h
//  Tinder
//
//  Created by Elluminati - macbook on 27/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject
{
    
}
@property(nonatomic,copy)NSString *sex;
@property(nonatomic,copy)NSString *prRad;
@property(nonatomic,copy)NSString *prSex;
@property(nonatomic,copy)NSString *prLAge;
@property(nonatomic,copy)NSString *prUAge;
@property(nonatomic,copy)NSString *distance;
@property(nonatomic,copy)NSString *verifyStatus;
@property(nonatomic,copy)NSString *showAll;

+(UserSettings *)currentSetting;

@end


