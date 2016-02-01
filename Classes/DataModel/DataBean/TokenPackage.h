//
//  TokenPackage.h
//  Tinder
//
//  Created by Sanskar on 18/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokenPackage : NSObject

@property(nonatomic,copy) NSString *plan_id;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *amount;
@property(nonatomic,copy) NSString *tokens;
@property(nonatomic,copy) NSString *description;

-(id)initWithDict:(NSDictionary *)dictData;

@end
