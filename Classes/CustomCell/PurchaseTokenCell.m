//
//  PurchaseTokenCell.m
//  Tinder
//
//  Created by Sanskar on 18/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "PurchaseTokenCell.h"

@implementation PurchaseTokenCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellData:(TokenPackage *)tokenData
{
    [Helper setToLabel:_lblPackageName Text:tokenData.name WithFont:HESTERISTICO_BOLD FSize:18 Color:TEMPLTE2_RED_COLOR];
    [Helper setToLabel:_lblPackageAmmount Text:[NSString stringWithFormat:@"Amount $%@",tokenData.amount] WithFont:SEGOUE_UI FSize:14 Color:nil];
    [Helper setToLabel:_lblPackageTokens Text:[NSString stringWithFormat:@"%@ Sparks",tokenData.tokens] WithFont:SEGOUE_UI FSize:14 Color:nil];
}

@end
