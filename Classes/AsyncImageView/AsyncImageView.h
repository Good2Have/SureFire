//
//  AsyncImageView.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


//
// Code heavily lifted from here:
// http://www.markj.net/iphone-asynchronous-table-image/
//

#import <UIKit/UIKit.h>

@protocol AsyncImageViewDelegate;

@interface AsyncImageView : UIView {
    NSURLConnection *connection;
    NSMutableData *data;
    NSString *urlString;// key for image cache dictionary
    BOOL isActualSize;
}

@property (nonatomic, retain) NSString *atCentre;
@property (nonatomic, strong) id <AsyncImageViewDelegate> Delegate;
@property (nonatomic) UIViewContentMode imgContentMode;

-(void)loadImageFromURL:(NSURL*)url;
-(void)loadImageFromURL:(NSURL*)url PlaceHolderImage:(UIImage *)placeHolderImage;
-(void)loadImagewithActualSizeFromURL:(NSURL*)url;
+(void)cacheImageFromURL:(NSURL*)url;
+(CGSize)getCachedImageActualSizeFromURL:(NSURL*)url;
- (void)setPlaceholderImage:(UIImage *)placeHolderImage;

@end

@protocol AsyncImageViewDelegate

@optional
- (void)AsyncImageLoadSuccessfully:(AsyncImageView *)sender;
@end
