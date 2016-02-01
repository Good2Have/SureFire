//
//  AsyncImageView.m
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCacheObject.h"
#import "ImageCache.h"

//
// Key's are URL strings.
// Value's are ImageCacheObject's
//
static ImageCache *imageCache = nil;

@implementation AsyncImageView


- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
    }
    self.clipsToBounds = YES;
    self.imgContentMode = UIViewContentModeScaleToFill;
//    [self.layer setBorderWidth:0.5];
//    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    return self;
}

- (void)awakeFromNib
{
    self.clipsToBounds = YES;
    self.imgContentMode = UIViewContentModeScaleToFill;
//    [self.layer setBorderWidth:0.5];
//    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}

+(void)cacheImageFromURL:(NSURL*)url {

    NSString *urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage == nil) {
    
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
                UIImage *image = [UIImage imageWithData:data];
                UIImage *cachedImage = [imageCache imageForKey:urlString];
                if (cachedImage == nil && image != nil) {
                                       
                    [imageCache insertImage:image withSize:[data length] forKey:urlString];
                }
        }];
    }
}

+(CGSize)getCachedImageActualSizeFromURL:(NSURL*)url {
    
    NSString *urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        
        CGSize imageSize = [cachedImage size];
        CGSizeMake(MIN([cachedImage size].width, 320), MIN([cachedImage size].height, 320));
        return imageSize;
    }
    return CGSizeMake(320, 320);
}

-(void)loadImageFromURL:(NSURL*)url {
    isActualSize = NO;
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data != nil) {
        [data release];
        data = nil;
    }
    
    if (imageCache == nil) // lazily create image cache
        imageCache = [[ImageCache alloc] initWithMaxSize:30*1024*1024];  // 2 MB Image cache
    
    
    [[self subviews]  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [urlString release];
    urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        
        if ([[self subviews] count] > 0) {
            
            [[[self subviews] objectAtIndex:0] removeFromSuperview];
        }
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:cachedImage] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = self.imgContentMode;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        CGSize imgSize = self.bounds.size;
        
        imgSize.height=self.frame.size.width*imgSize.height/imgSize.width;
        imgSize.width=self.frame.size.width;
        
        imageView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
        
        self.bounds = imageView.frame;
        
        [imageView setNeedsLayout]; // is this necessary if superview gets setNeedsLayout?
        [self setNeedsLayout];
        
//        if([self.Delegate respondsToSelector:@selector(AsyncImageLoadSuccessfully:)]) {
//            [self.Delegate AsyncImageLoadSuccessfully:self];
//        }
        
        return;
    }
    
#define SPINNY_TAG 5555
    
    UIActivityIndicatorView *spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinny.tag = SPINNY_TAG;
    spinny.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [spinny startAnimating];
    [self addSubview:spinny];
    [spinny release];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)setPlaceholderImage:(UIImage *)placeHolderImage
{
    if (placeHolderImage != nil) {
        UIImageView *phImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [phImage setImage:placeHolderImage];
        [self addSubview:phImage];
    }
}

-(void)loadImageFromURL:(NSURL*)url PlaceHolderImage:(UIImage *)placeHolderImage {
    
    isActualSize = NO;
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data != nil) {
        [data release];
        data = nil;
    }
    
    if (imageCache == nil) // lazily create image cache
        imageCache = [[ImageCache alloc] initWithMaxSize:30*1024*1024];  // 2 MB Image cache
    
    
    [[self subviews]  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (placeHolderImage != nil) {
        UIImageView *phImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [phImage setImage:placeHolderImage];
        [self addSubview:phImage];
    }
    
    [urlString release];
    urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        if ([[self subviews] count] > 0) {
            [[[self subviews] objectAtIndex:0] removeFromSuperview];
        }
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:cachedImage] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = self.imgContentMode;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        CGSize imgSize = self.bounds.size;
        
        imgSize.height=self.frame.size.width*imgSize.height/imgSize.width;
        imgSize.width=self.frame.size.width;
        
        imageView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
        
        self.bounds = imageView.frame;
        
        [imageView setNeedsLayout]; // is this necessary if superview gets setNeedsLayout?
        [self setNeedsLayout];
        
//        if([self.Delegate respondsToSelector:@selector(AsyncImageLoadSuccessfully:)]) {
//            [self.Delegate AsyncImageLoadSuccessfully:self];
//        }
        
        return;
    }
    
#define SPINNY_TAG 5555   
    
    UIActivityIndicatorView *spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinny.tag = SPINNY_TAG;
    spinny.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [spinny startAnimating];
    [self addSubview:spinny];
    [spinny release];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


-(void)loadImagewithActualSizeFromURL:(NSURL *)url
{
    isActualSize = YES;
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data != nil) {
        [data release];
        data = nil;
    }
    
    if (imageCache == nil) // lazily create image cache
        imageCache = [[ImageCache alloc] initWithMaxSize:30*1024*1024];  // 2 MB Image cache
    
    [[self subviews]  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [urlString release];
    urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        
        if ([[self subviews] count] > 0) {
            [[[self subviews] objectAtIndex:0] removeFromSuperview];
        }
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:cachedImage] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = self.imgContentMode;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        CGSize imageSize = [imageView.image size];
        self.backgroundColor = [UIColor whiteColor];
        float multiPlyX = 1.0f, multiPlyY = 1.0;
        float y = 0.0f, x = 0.0f;
        
        if (imageSize.width > self.bounds.size.width) {
            multiPlyX = (imageSize.width/self.bounds.size.width);
        }
//        else {
//            x = (self.bounds.size.width - imageSize.width)/2;
//        }
        
        if (imageSize.height > self.bounds.size.height) {
            multiPlyY = (imageSize.height/self.bounds.size.height);
        }
//        else {
//            y = (self.bounds.size.height - imageSize.height)/2;
//        }
        
        float width = 0.0f, height = 0.0f;
        
        if (multiPlyY > multiPlyX) {
            width = imageSize.width/multiPlyY;
            height = imageSize.height/multiPlyY;
        }
        else {
            width = imageSize.width/multiPlyX;
            height = imageSize.height/multiPlyX;
        }
        
        x = (self.bounds.size.width - width)/2;
        y = (self.bounds.size.height - height)/2;
        
        imageView.frame = CGRectMake(x, y, width, height);
        [imageView setNeedsLayout]; // is this necessary if superview gets setNeedsLayout?
        [self setNeedsLayout];
        
//        if([self.Delegate respondsToSelector:@selector(AsyncImageLoadSuccessfully:)]) {
//            [self.Delegate AsyncImageLoadSuccessfully:self];
//        }
        
        return;
    }
    
#define SPINNY_TAG 5555   
    
    UIActivityIndicatorView *spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinny.tag = SPINNY_TAG;
    spinny.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [spinny startAnimating];
    [self addSubview:spinny];
    [spinny release];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    [connection release];
    connection = nil;
    
    UIView *spinny = [self viewWithTag:SPINNY_TAG];
    [spinny removeFromSuperview];
    
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    UIImage *image = [UIImage imageWithData:data];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage == nil && image != nil) {
        
        [imageCache insertImage:image withSize:[data length] forKey:urlString];
    }
    
    if(image == nil) {
    
        image = [UIImage imageNamed:@"nopreview"];
        self.imgContentMode = UIViewContentModeScaleAspectFit;
    }
    
    UIImageView *imageView1 = [[[UIImageView alloc] 
                               initWithImage:image] autorelease];
    imageView1.backgroundColor = [UIColor clearColor];
    imageView1.contentMode = self.imgContentMode;
    imageView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:imageView1];
    
    imageView1.frame = self.bounds;
    
    if (isActualSize) {
        
        self.backgroundColor = [UIColor whiteColor];
        CGSize imageSize = [image size];
        float multiPlyX = 1.0f, multiPlyY = 1.0;
        float y = 0.0f, x = 0.0f;
        
        if (imageSize.width > self.bounds.size.width) {
            multiPlyX = (image.size.width/self.bounds.size.width);
        }
        
        if (image.size.height > self.bounds.size.height) {
            multiPlyY = (image.size.height/self.bounds.size.height);
        }
        
        float width = 0.0f, height = 0.0f;
        
        if (multiPlyY > multiPlyX) {
            width = imageSize.width/multiPlyY;
            height = imageSize.height/multiPlyY;
        }
        else {
            width = imageSize.width/multiPlyX;
            height = imageSize.height/multiPlyX;
        }
        
        x = (self.bounds.size.width - width)/2;
        y = (self.bounds.size.height - height)/2;
        
        imageView1.frame = CGRectMake(x, y, width, height);
    }
    else {
        CGSize imgSize = self.bounds.size;
        
        imgSize.height=self.frame.size.width*imgSize.height/imgSize.width;
        imgSize.width=self.frame.size.width;
        
        imageView1.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
        
        self.bounds = imageView1.frame;
    }
    [imageView1 setNeedsLayout]; // is this necessary if superview gets setNeedsLayout?
    [self setNeedsLayout];
    [data release];
    data = nil;
    
    
    if([self.Delegate respondsToSelector:@selector(AsyncImageLoadSuccessfully:)]) {
        [self.Delegate AsyncImageLoadSuccessfully:self];
    }
}

@end
