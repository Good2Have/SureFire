//
//  TokenPackage.m
//  Tinder
//
//  Created by Sanskar on 18/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "TokenPackage.h"

@implementation TokenPackage

@synthesize plan_id,name,amount,tokens,description;

-(id)initWithDict:(NSDictionary *)dictData
{
    self=[super init];
    if (self) {
        if (dictData) {
            plan_id = [dictData objectForKey:@"plan_id"];
            name=[dictData objectForKey:@"name"];
            amount=[dictData objectForKey:@"amount"];
            tokens=[dictData objectForKey:@"no_of_credit"];
            description=[dictData objectForKey:@"description"];
        }
    }
    return self;
}


@end
