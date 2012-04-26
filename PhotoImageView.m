//
//  PhotoImageView.m
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//
#define ZOOM_VIEW_TAG 0x101
#import "PhotoImageView.h"
#import "PhotoScrollView.h"
#import "Playlist.h"
#import <QuartzCore/QuartzCore.h>

@interface RotateGesture : UIRotationGestureRecognizer {}
@end

@implementation RotateGesture
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer*)gesture{
	return NO;
}
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
	return YES;
}
@end


@interface PhotoImageView (Private)
- (void)layoutScrollViewAnimated;
@end


@implementation PhotoImageView 

@synthesize imageView=_imageView;
@synthesize scrollView=_scrollView;
@synthesize index;
@synthesize fuzzy,fullScreen;
@synthesize playlist;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.opaque = YES;
		PhotoScrollView *scrollView = [[PhotoScrollView alloc] initWithFrame:self.bounds];
		scrollView.backgroundColor = [UIColor blackColor];
		scrollView.opaque = YES;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		_scrollView = scrollView;

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
		imageView.opaque = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = nil;
        imageView.clearsContextBeforeDrawing = YES;
		[_scrollView addSubview:imageView];
		_imageView = imageView;
       
//		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//       // [activityView startAnimating];
//		activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 15.0f, (CGRectGetHeight(self.frame)/2) - 15.0f , 30.0f, 30.0f);
//		activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//		[self addSubview:activityView];
//		_activityView = activityView;
		
		//RotateGesture *gesture = [[RotateGesture alloc] initWithTarget:self action:@selector(rotate:)];
		//[self addGestureRecognizer:gesture];
		
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showCopyMenu:)];
        [self addGestureRecognizer:gr];
	}
    return self;
}

- (void)layoutSubviews{
	[super layoutSubviews];
		
	if (_scrollView.zoomScale == 1.0f) {
		[self layoutScrollViewAnimated];
	}
	
}

- (void)loadIndex: (NSUInteger) _index {
    //NSLog(@"Asset Loading");
    // set the tag for async operation result check
    // [_activityView startAnimating];
    self.tag = _index;
    // reset our zoomScale to 1.0 before doing any further calculations
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = nil;
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        [self doLoadImage: nil checkIndex: _index];
    //    });
    [self performSelectorInBackground:@selector(doLoadIndexStr:) withObject:[NSString stringWithFormat:@"%d", _index]];
}

- (void)doLoadIndex: (NSUInteger) _index {
  //  NSLog(@"doLoadIndex: %d", _index);
    
    self.fullScreen = nil;
    self.fuzzy = [self.playlist fuzzyImageAtIndex:_index forFullScreenImage:^(UIImage *img) {
        //NSLog(@"======== FullScreen Loaded ===========");
        self.fullScreen = img;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doLoadImage: nil checkIndex: _index];
        });
    }];  
    //[self doLoadImage: nil checkIndex: _index];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doLoadImage: nil checkIndex: _index];
    });
}

- (void)doLoadIndexStr: (NSString*) _index {
    [self doLoadIndex: [_index integerValue]];
}

- (void)doLoadImage: (UIImage *) image checkIndex: (NSUInteger) _index {
    if (self.tag != _index) {
        NSLog(@"Skipping non-matched image loading process: %d", _index);
        return;
    }
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
//    if (image == nil) {
//        self.imageView.image = fullScreen != nil ? fullScreen : fuzzy;
//    } else {
//        self.imageView.image = image;
//    }
//    NSLog(@"image is %@",self.imageView.image);
//     //[_activityView stopAnimating];
//        NSLog(@"iamgesize is %@",NSStringFromCGSize(self.imageView.image.size));
//        [self layoutScrollViewAnimated];
    
    
    
        //    self.contentSize = [self.imageView.image size];
    //    
    ////    NSLog(@"Content Size: %fx%f", self.contentSize.width, self.contentSize.height);
    //    if (self.contentSize.width > 0 && self.contentSize.height > 0) {
    //        [self setMaxMinZoomScalesForCurrentBounds];
    //        self.zoomScale = self.minimumZoomScale;
    ////        NSLog(@"Minimum Zoom Scale: %f", self.minimumZoomScale);
    //    }
    //
}

-(void)updateUI:(UIImage *)image{
    if (image == nil) {
        self.imageView.image = fullScreen != nil ? fullScreen : fuzzy;
    } else {
        self.imageView.image = image;
    }
//    NSLog(@"image is %@",self.imageView.image);
//    [_activityView stopAnimating];
//    CGSize imageSize = self.imageView.image.size;
//    NSLog(@"iamgesize is %@",NSStringFromCGSize(imageSize));
    [self layoutScrollViewAnimated];
}

-(void)setClearImage{
    ALAsset *asset = [self.playlist assetAtIndex:index];
    CGImageRef imageRef = [asset defaultRepresentation].fullScreenImage;
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    self.imageView.image = image;
    [self layoutScrollViewAnimated];
}

-(void)savePhoto{
    
    UIImageWriteToSavedPhotosAlbum(self.fullScreen, nil, nil, nil);

}

#pragma mark -
#pragma mark Parent Controller Fading
- (void)resetBackgroundColors{
	
	self.backgroundColor = [UIColor blackColor];
	self.superview.backgroundColor = self.backgroundColor;
	self.superview.superview.backgroundColor = self.backgroundColor;

}


#pragma mark -
#pragma mark Layout
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation{

	if (self.scrollView.zoomScale > 1.0f) {
		
		CGFloat height, width;
		height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
	} else {
		
		[self layoutScrollViewAnimated];
	}
}

- (void)layoutScrollViewAnimated{


    if (CGSizeEqualToSize(self.imageView.image.size, CGSizeZero)) {
        return;
    }
    if (self.scrollView.zoomScale == 1) {
        self.scrollView.scrollEnabled = NO;
    }else{
        self.scrollView.scrollEnabled = YES;
    }

	CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
	
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
	self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
	self.imageView.frame = self.scrollView.bounds;

    //NSLog(@"self.imageview is %@,image is %@,scrollView is %@,self.frame is%@  %d",NSStringFromCGRect(self.imageView.frame),NSStringFromCGSize(self.imageView.image.size),NSStringFromCGRect(self.scrollView.frame),NSStringFromCGRect(self.frame),index);
}

- (void)showCopyMenu:(UILongPressGestureRecognizer *) gestureRecognizer {
    [self becomeFirstResponder];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        // bring up editing menu.
        if(theMenu){
            theMenu = nil;
        }
        theMenu = [UIMenuController sharedMenuController];
        CGRect selectionRect = CGRectMake(location.x, location.y, 0.0f, 0.0f);
        [theMenu setTargetRect:selectionRect inView:self];
        [theMenu setMenuVisible:YES animated:YES]; 
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{   
    if (action == @selector(cut:))
        return NO;
    else if (action == @selector(copy:))
        return YES;
    else if (action == @selector(paste:))
        return NO;
    else if (action == @selector(select:) || action == @selector(selectAll:)) 
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

-(void)copy:(id)sender{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.fullScreen];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (data) {
        [pasteBoard setData:data forPasteboardType:@"fullScreenImage"];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.scrollView.dragging) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoViewToggleBars" object:nil];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (theMenu.isMenuVisible) {
        theMenu.menuVisible = NO;
    }
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)killZoomAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	if([finished boolValue]){
		
		[self.scrollView setZoomScale:1.0f animated:NO];
		self.imageView.frame = self.scrollView.bounds;
		[self layoutScrollViewAnimated];
		
	}
	
}

- (void)killScrollViewZoom{
	if (CGSizeEqualToSize(self.imageView.image.size, CGSizeZero)) {
        return;
    }

	if (!self.scrollView.zoomScale > 1.0f) return;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(killZoomAnimationDidStop:finished:context:)];
	[UIView setAnimationDelegate:self];
    CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
		
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
		
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;

	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.imageView.frame = self.scrollView.bounds;
	[UIView commitAnimations];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.imageView;
       
}
/*
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    if (scrollView.zoomScale > 1.0f) {				
		CGFloat height, width;	
         
         if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
         width = CGRectGetWidth(self.bounds);
         } else {
         width = CGRectGetMaxX(self.imageView.frame);
         
         }
         
         if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
         height = CGRectGetHeight(self.bounds);
         } else {
         height = CGRectGetMaxY(self.imageView.frame);
         
         if (self.imageView.frame.origin.y < 0.0f) {
         } else {
         }
         }
        CGFloat height, width, originX, originY;
		//height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		//width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
        
		
		if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
			width = CGRectGetWidth(self.bounds);
			originX = 0.0f;
		} else {
			width = CGRectGetMaxX(self.imageView.frame);
			
			if (self.imageView.frame.origin.x < 0.0f) {
                originX = 0.0f;
            } else {
                originX = self.imageView.frame.origin.x;
            }	
		}
		
		if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
			height = CGRectGetHeight(self.bounds);
			originY = 0.0f;
		} else {
			height = CGRectGetMaxY(self.imageView.frame);
			
			if (self.imageView.frame.origin.y < 0.0f) {
				originY = 0.0f;
			} else {
				originY = self.imageView.frame.origin.y;
			}
		}
        
        
		CGRect frame = self.scrollView.frame;
        self.scrollView.frame = CGRectMake(originX, originY, width, height);
		//self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		if (!CGRectEqualToRect(frame, self.scrollView.frame)) {		
			CGFloat offsetY, offsetX;
            
			if (frame.origin.y < self.scrollView.frame.origin.y) {
				offsetY = self.scrollView.contentOffset.y - (self.scrollView.frame.origin.y - frame.origin.y);
			} else {				
				offsetY = self.scrollView.contentOffset.y - (frame.origin.y - self.scrollView.frame.origin.y);
			}
			
			if (frame.origin.x < self.scrollView.frame.origin.x) {
				offsetX = self.scrollView.contentOffset.x - (self.scrollView.frame.origin.x - frame.origin.x);
			} else {				
				offsetX = self.scrollView.contentOffset.x - (frame.origin.x - self.scrollView.frame.origin.x);
			}
            
			if (offsetY < 0) offsetY = 0;
			if (offsetX < 0) offsetX = 0;
			
			//self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
		}
	} else {
		[self layoutScrollViewAnimated];
	}
}*/
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView.zoomScale > 1.0f) {				
		/*CGFloat height, width;	
		
		if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
			width = CGRectGetWidth(self.bounds);
		} else {
			width = CGRectGetMaxX(self.imageView.frame);
			
        }
		
		if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
			height = CGRectGetHeight(self.bounds);
		} else {
			height = CGRectGetMaxY(self.imageView.frame);
			
			if (self.imageView.frame.origin.y < 0.0f) {
			} else {
			}
		}*/
        CGFloat height, width, originX, originY;
		//height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		//width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
        
		
		if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
			width = CGRectGetWidth(self.bounds);
			originX = 0.0f;
		} else {
			width = CGRectGetMaxX(self.imageView.frame);
			
			if (self.imageView.frame.origin.x < 0.0f) {
                originX = 0.0f;
             } else {
                 originX = self.imageView.frame.origin.x;
             }	
		}
		
		if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
			height = CGRectGetHeight(self.bounds);
			originY = 0.0f;
		} else {
			height = CGRectGetMaxY(self.imageView.frame);
			
			if (self.imageView.frame.origin.y < 0.0f) {
				originY = 0.0f;
			} else {
				originY = self.imageView.frame.origin.y;
			}
		}

        
		CGRect frame = self.scrollView.frame;
       // NSLog(@"scrollView frame is %@",NSStringFromCGRect(self.scrollView.frame));
        self.scrollView.frame = CGRectMake(originX, originY, width, height);
		//self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		if (!CGRectEqualToRect(frame, self.scrollView.frame)) {
			CGFloat offsetY, offsetX;
            //NSLog(@"the content offset is %f %f",self.scrollView.contentOffset.x,self.scrollView.contentOffset.y);
			if (frame.origin.y < self.scrollView.frame.origin.y) {
				offsetY = self.scrollView.contentOffset.y - (self.scrollView.frame.origin.y - frame.origin.y);
			} else {				
				offsetY = self.scrollView.contentOffset.y - (frame.origin.y - self.scrollView.frame.origin.y);
			}
			
			if (frame.origin.x < self.scrollView.frame.origin.x) {
				offsetX = self.scrollView.contentOffset.x - (self.scrollView.frame.origin.x - frame.origin.x);
			} else {				
				offsetX = self.scrollView.contentOffset.x - (frame.origin.x - self.scrollView.frame.origin.x);
			}
			if (offsetY < 0) offsetY = 0;
			if (offsetX < 0) offsetX = 0;
			
			self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
		}
	} else {
		[self layoutScrollViewAnimated];
	}
}


#pragma mark -
#pragma mark RotateGesture

/*- (void)rotate:(UIRotationGestureRecognizer*)gesture{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		
		[self.layer removeAllAnimations];
		_beginRadians = gesture.rotation;
		self.layer.transform = CATransform3DMakeRotation(_beginRadians, 0.0f, 0.0f, 1.0f);
		
	} else if (gesture.state == UIGestureRecognizerStateChanged) {
		
		self.layer.transform = CATransform3DMakeRotation((_beginRadians + gesture.rotation), 0.0f, 0.0f, 1.0f);

	} else {
		
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		animation.duration = 0.3f;
		animation.removedOnCompletion = NO;
		animation.fillMode = kCAFillModeForwards;
		animation.delegate = self;
		[animation setValue:[NSNumber numberWithInt:202] forKey:@"AnimationType"];
		[self.layer addAnimation:animation forKey:@"RotateAnimation"];
		
	} 

	
}*/

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	if (flag) {
		
		if ([[anim valueForKey:@"AnimationType"] integerValue] == 101) {
			
			[self resetBackgroundColors];
			
		} else if ([[anim valueForKey:@"AnimationType"] integerValue] == 202) {
			
			self.layer.transform = CATransform3DIdentity;
			
		}
	}
	
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
		
	[[NSNotificationCenter defaultCenter] removeObserver:self];
		
}


@end
