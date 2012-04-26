//
//  PhotoScrollView.m
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PhotoScrollView.h"
#import "PhotoImageView.h"

@implementation PhotoScrollView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.scrollEnabled = NO;
		self.pagingEnabled = NO;
		self.clipsToBounds = NO;
		self.maximumZoomScale = 2.0f;
		self.minimumZoomScale = 1.0f;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.alwaysBounceVertical = NO;
		self.alwaysBounceHorizontal = NO;
		self.bouncesZoom = YES;
		self.bounces = YES;
		self.scrollsToTop = NO;
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showCopyMenu:)];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (void)showCopyMenu:(UILongPressGestureRecognizer *) gestureRecognizer {
    [self becomeFirstResponder];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        // bring up editing menu.
        if (theMenu) {
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
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:((PhotoImageView*)self.superview).fullScreen];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (data) {
        [pasteBoard setData:data forPasteboardType:@"fullScreenImage"];
    }
}

- (void)zoomRectWithCenter:(CGPoint)center{
		if (self.zoomScale > 1.0f) {
		[((PhotoImageView*)self.superview) killScrollViewZoom];
		return;
	}
    
	CGRect rect;
	rect.size = CGSizeMake(self.frame.size.width / PV_ZOOM_SCALE, self.frame.size.height / PV_ZOOM_SCALE);
	rect.origin.x = MAX((center.x - (rect.size.width / 2.0f)), 0.0f);		
	rect.origin.y = MAX((center.y - (rect.size.height / 2.0f)), 0.0f);

	CGRect frame = self.frame;//[self.superview convertRect:self.frame toView:self.superview];

	CGFloat borderX = frame.origin.x;
	CGFloat borderY = frame.origin.y;
	
	if (borderX > 0.0f && (center.x < borderX || center.x > self.frame.size.width - borderX)) {
        
		if (center.x < (self.frame.size.width / 2.0f)) {
			
			rect.origin.x += (borderX/PV_ZOOM_SCALE);
			
		} else {
			
			rect.origin.x -= ((borderX/PV_ZOOM_SCALE) + rect.size.width);
			
		}	
	}
	
	if (borderY > 0.0f && (center.y < borderY || center.y > self.frame.size.height - borderY)) {
        
		if (center.y < (self.frame.size.height / 2.0f)) {
			
			rect.origin.y += (borderY/PV_ZOOM_SCALE);
			
		} else {
            
			rect.origin.y -= ((borderY/PV_ZOOM_SCALE) + rect.size.height);
			
		}
		
	}
	[self zoomToRect:rect animated:YES];	
    
}

- (void)toggleBars{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoViewToggleBars" object:nil];
}


#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"pause" 
                                                       object:self 
                                                     userInfo:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
    if (theMenu.isMenuVisible) {
        theMenu.menuVisible = NO;
    }
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 1) {
		[self performSelector:@selector(toggleBars) withObject:nil afterDelay:.3];
	} else if (touch.tapCount == 2) {
        if (self.zoomScale == 1) {
            self.scrollEnabled = YES;
        }else{
            self.scrollEnabled = NO;
        }
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleBars) object:nil];
		[self zoomRectWithCenter:[[touches anyObject] locationInView:self.superview]];
        
	}
}

@end
