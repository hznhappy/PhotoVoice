//
//  PhotoViewController.m
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoImageView.h"
#import "PhotoScrollView.h"
#import "Playlist.h"
#import "Asset.h"
#import "DataManager.h"
@interface PhotoViewController (Private)

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)updateNavigation;
- (void)playPhoto;
@end

@implementation PhotoViewController


@synthesize scrollView=_scrollView;
@synthesize currentPageIndex;
@synthesize playlist;
@synthesize playPhotoTransition;

#pragma mark -
#pragma mark Init method

- (id)init{
	if ((self = [super init])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"PhotoViewToggleBars" object:nil];
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;		
        recycledPages = [[NSMutableSet alloc] init];
        visiblePages  = [[NSMutableSet alloc] init];
        Playlist *tempPlaylist = [[Playlist alloc]init];
        myApp = [UIApplication sharedApplication].delegate;
        self.playlist = tempPlaylist;
        self.playlist.storeAssets = myApp.dataManager.assets;
        self.playlist.assets = myApp.dataManager.libAssets;
    }
    
    return self;
}


- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
	self.scrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	self.scrollView.contentSize = [self contentSizeForPagingScrollView];
	for (PhotoImageView *page in visiblePages) {
        if (page.scrollView.zoomScale>1.0) {
            [page killScrollViewZoom];
        }
        page.frame = [self frameForPageAtIndex:page.index];
    }
    
	// Adjust contentOffset to preserve page location based on values collected prior to location
	self.scrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	performingLayout = NO;
    
}


#pragma mark -
#pragma mark View Controller Methods

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self performLayout];
    [self updateNavigation];
}

-(void)viewDidAppear:(BOOL)animated{

}
- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
   
    [self cancelPlayPhotoTimer];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack. 
        [self cancelControlHiding];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadTableData" object:nil];
    }
    [self.navigationController setToolbarHidden:YES animated:YES];		
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.hidesBottomBarWhenPushed = YES;
    self.wantsFullScreenLayout = YES;
	self.view.backgroundColor = [UIColor blackColor];
	if (!_scrollView) {
		
		_scrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
		_scrollView.delegate=self;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_scrollView.multipleTouchEnabled=YES;
		_scrollView.scrollEnabled=YES;
		_scrollView.directionalLockEnabled=YES;
		_scrollView.canCancelContentTouches=YES;
		_scrollView.delaysContentTouches=YES;
		_scrollView.clipsToBounds=YES;
		_scrollView.alwaysBounceHorizontal=YES;
		_scrollView.bounces=YES;
		_scrollView.pagingEnabled=YES;
		_scrollView.showsVerticalScrollIndicator=NO;
		_scrollView.showsHorizontalScrollIndicator=NO;
		_scrollView.backgroundColor = self.view.backgroundColor;
        _scrollView.contentSize = [self contentSizeForPagingScrollView];
        _scrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
		[self.view addSubview:_scrollView];
    }
    playingPhoto = NO;
    [self updatePages];
    [self hideControlsAfterDelay];
}

#pragma mark -
#pragma mark Pagging Methods

-(void)updatePages{
    // Calculate which pages are visible
    CGRect visibleBounds = self.scrollView.bounds;
    int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > self.playlist.storeAssets.count - 1) iFirstIndex = self.playlist.storeAssets.count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > self.playlist.storeAssets.count - 1) iLastIndex = self.playlist.storeAssets.count - 1;

    
    // Recycle no-longer-visible pages 
    for (PhotoImageView *page in visiblePages) {
        if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
			[recycledPages addObject:page];
			/*NSLog(@"Removed page at index %i", page.index);*/
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}

    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
   for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            PhotoImageView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[PhotoImageView alloc] init];
                page.playlist = self.playlist;
            }
            [self.scrollView addSubview:page];
            [self configurePage:page forIndex:index];
            [visiblePages addObject:page];
        }
    }    
    
}

- (void)configurePage:(PhotoImageView *)page forIndex:(NSUInteger)index{
    CGRect rect = [self frameForPageAtIndex:index];
    page.index = index;
    page.imageView.image = nil;
    page.frame = rect;
    if (!playingPhoto) {
        [page loadIndex:index];
    }else{
        [page setClearImage];
    }
    [self playAudioWithIndex:index];
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index{
    BOOL foundPage = NO;
    for (PhotoImageView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (PhotoImageView *)pageDisplayedAtIndex:(NSUInteger)index {
	PhotoImageView *thePage = nil;
	for (PhotoImageView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; 
            break;
		}
	}
	return thePage;
}


- (PhotoImageView *)dequeueRecycledPage{
    PhotoImageView *page = [recycledPages anyObject];
    if (page) {
        [recycledPages removeObject:page];
    }
    return page;
}

#pragma mark -
#pragma mark Frame Methods
- (CGRect)frameForPagingScrollView{
    //NSLog(@"view bounds is %@",NSStringFromCGRect(self.view.bounds));
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

 - (CGRect)frameForPageAtIndex:(NSUInteger)index{
     CGRect bounds = self.scrollView.bounds;
     CGRect pageFrame = bounds;
     pageFrame.size.width -= (2 * PADDING);
     pageFrame.origin.x = (bounds.size.width * index) + PADDING;
     return pageFrame;

 }

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = self.scrollView.bounds;
    //NSLog(@"%@ is scrollView BOUNDS",NSStringFromCGSize(bounds.size));
    return CGSizeMake(bounds.size.width * self.playlist.storeAssets.count, bounds.size.height);
}


- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = self.scrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
   // NSLog(@"contentOffeset is %f",newOffset);
	return CGPointMake(newOffset, 0);
}

#pragma mark - Play Audio methods
-(void)playAudioWithIndex:(NSInteger)index{
    if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    audioPlayer = nil;
    NSError *error;
    NSURL *url =[NSURL URLWithString:((Asset*)[self.playlist.storeAssets objectAtIndex:index]).audioUrl];
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    audioPlayer.delegate = self;
    if (error) {
        NSLog(@"audio paly error:%@",error);
    }else{
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }

}
#pragma mark -
#pragma mark Control Methods
- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	if (index < self.playlist.storeAssets.count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		self.scrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)hideControls { [self setBarsHidden:!_barsHidden animated:YES]; }



#pragma mark - 
#pragma mark Rotate orientation methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _rotating = YES;
    pageIndexBeforeRotation = currentPageIndex;
    if (_barsHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    currentPageIndex = pageIndexBeforeRotation;
    [self performLayout];
    if (_barsHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
	//[self hideControlsAfterDelay];
   // NSLog(@"scroll frame is %@ and bounds %@  and contentsize %@",NSStringFromCGRect(self.scrollView.frame),NSStringFromCGRect(self.scrollView.bounds),NSStringFromCGSize(self.scrollView.contentSize));
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //[self performLayout];
    _rotating = NO;
}



#pragma mark -
#pragma mark Bar Methods
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
	if (hidden&&_barsHidden) return;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    if (hidden) {
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.alpha = 0;
            //self.navigationController.toolbar.alpha = 0;
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.alpha = 1;
            //self.navigationController.toolbar.alpha = 1;
        }];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGRect frame = self.navigationController.navigationBar.frame;
        frame.origin.y = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
        self.navigationController.navigationBar.frame = frame;
    }
       [self cancelControlHiding];
    if (!hidden) {
        [self hideControlsAfterDelay];
    }
	_barsHidden=hidden;	
    
}


- (void)toggleBarsNotification:(NSNotification*)notification{
    [self setBarsHidden:!_barsHidden animated:YES];
    [self cancelPlayPhotoTimer];
}

#pragma mark -
#pragma mark Photo View Methods                                  
- (void)updateNavigation {	
	if ([self.playlist.storeAssets count] > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", currentPageIndex+1, [self.playlist.storeAssets count]];
	} else {
		self.title = @"";
	}
	
}
#pragma mark - AVAudioPlay delegate Methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self playPhoto];
    [self playAudioWithIndex:currentPageIndex];
    playingPhoto = YES;
}
#pragma mark -
#pragma mark UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (performingLayout || _rotating) return;
    //NSLog(@"scroll frame is %@ and bounds %@  and contentsize %@",NSStringFromCGRect(self.scrollView.frame),NSStringFromCGRect(self.scrollView.bounds),NSStringFromCGSize(self.scrollView.contentSize));
    [self updatePages];
    // Calculate current page
    CGRect visibleBounds = scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));    if (index < 0) index = 0;
	if (index > self.playlist.storeAssets.count - 1) index = self.playlist.storeAssets.count - 1;
    if (index != currentPageIndex) {
        currentPageIndex = index;
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setBarsHidden:YES animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self updateNavigation];
}

#pragma mark -
#pragma mark Actions

-(void)messagePhoto{
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc]init];
     messageController.messageComposeDelegate = self;
//     messageController.recipients = [NSArray arrayWithObject:@"23234567"];  
//     messageController.body = @"iPhone OS4";
    NSData *data = UIImagePNGRepresentation(((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).imageView.image);
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    messageController.body = string;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     [self presentModalViewController:messageController animated:YES];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissModalViewControllerAnimated:YES];
    NSString *mailError = nil;
    switch (result)
    {
        case MessageComposeResultCancelled:
                
            break;
        case MessageComposeResultSent:
            
            break;
        case MessageComposeResultFailed:mailError = @"Send messages failed,please try again...";
            
            break;
        default:
        
            break;
    }
    if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)emailPhoto{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation(((PhotoImageView*)[self pageDisplayedAtIndex:currentPageIndex]).imageView.image)] mimeType:@"png" fileName:@"Photo.png"];
   NSString *subject = [NSString stringWithFormat:@"Photo:"];
    
    
    [mailViewController setSubject:subject];
    mailViewController.mailComposeDelegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self presentModalViewController:mailViewController animated:YES];
	
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	[self dismissModalViewControllerAnimated:YES];
    
	NSString *mailError = nil;
	
	switch (result) {
		case MFMailComposeResultSent: ; break;
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}
	
	if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

#pragma mark -
#pragma mark UIActionSheet Methods

- (IBAction)actionButtonHit:(id)sender{
	
	UIActionSheet *actionSheet;
   //NSString *a=NSLocalizedString(@"Email", @"title");
   // NSString *b=NSLocalizedString(@"Message", @"title");
   // NSString *d=NSLocalizedString(@"Copy", @"title");
   // NSString *e=NSLocalizedString(@"Cancel", @"title");
	if ([MFMailComposeViewController canSendMail]){ //&& [MFMessageComposeViewController canSendText]) {		
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", nil];
		
	} 
//    else if([MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText]) {		
//        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:e destructiveButtonTitle:nil otherButtonTitles:a, nil];
//		
//	}else if(![MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {		
//        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:e destructiveButtonTitle:nil otherButtonTitles:b, nil];
//		
//    }
    else {
		
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
		
	}
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	
	[actionSheet showInView:self.view];
	[self setBarsHidden:YES animated:YES];
	
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	//[self setBarsHidden:NO animated:YES];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} 
    if ([MFMailComposeViewController canSendMail] ){//&& [MFMessageComposeViewController canSendText]) {		
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self emailPhoto];
        }
//        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
//            [self messagePhoto];	
//        } 
    } 
//    else if([MFMailComposeViewController canSendMail] && ![MFMessageComposeViewController canSendText]) {		
//        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
//            [self emailPhoto];
//        } 
//    }else if(![MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {		
//        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
//            [self messagePhoto];
//        }
//    }
}

#pragma mark -
#pragma mark Timer method
-(void)cancelPlayPhotoTimer{
    if (timer) {
		[timer invalidate];
		timer = nil;
	}
    playingPhoto = NO;
}


-(void)fireTimer{
    [self cancelPlayPhotoTimer];
    playingPhoto = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(playPhoto) userInfo:playPhotoTransition repeats:YES];
}


-(void)playPhoto{
      if (!_barsHidden) {
        [self setBarsHidden:YES animated:YES];
    }
    currentPageIndex += 1;
    NSInteger _index = self.currentPageIndex;
    if (_index >= [self.playlist.storeAssets count] || _index < 0) {
        if (timer) {
            [timer invalidate];
            timer = nil;
            [self setBarsHidden:NO animated:YES];
            return;
        }
    }
    NSString *animateStyle = @"Fade";//playPhotoTransition;//[timer userInfo];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.subtype = kCATransitionFromRight;
    if ([animateStyle isEqualToString:@"Fade"]) {
        animation.type = kCATransitionFade;
    }
    else if([animateStyle isEqualToString:@"Cube"]) {
       animation.type=@"cube";
    }
    else if([animateStyle isEqualToString:@"Reveal"]) {
        animation.type = kCATransitionReveal;
    }
    else if([animateStyle isEqualToString:@"Push"]) {
        animation.type = kCATransitionPush;
    }
    else if([animateStyle isEqualToString:@"Move In"]) {
        animation.type = kCATransitionMoveIn;
    }
    else if([animateStyle isEqualToString:@"Suck Effect"])
    {
        animation.type=@"suckEffect";    
    }
    else if([animateStyle isEqualToString:@"Ogl Flip"])
    {
        animation.type=@"oglFlip";
    }
    else if([animateStyle isEqualToString:@"Ripple Effect"])
    {
        animation.type=@"rippleEffect";
    }
    else if([animateStyle isEqualToString:@"Page Curl"])
    {
        animation.type=@"pageCurl";
    }
    else if([animateStyle isEqualToString:@"Page UnCurl"])
    {
        animation.type=@"pageUnCurl";
    }

    else{
        animation.type = animateStyle;
    }
    //NSLog(@"the count is %d and the current is %d ",self.playlist.storeAssets.count,currentPageIndex);
    [self.scrollView.layer addAnimation:animation forKey:@"animation"];
    [self jumpToPageAtIndex:currentPageIndex];
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
	timer = nil;
	_scrollView=nil;
	
}

@end