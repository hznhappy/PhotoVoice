//
//  PhotoViewController.h
//  PhotoApp
//
//  Created by Andy on 10/12/11.
//  Copyright 2011 chinarewards. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#define PADDING 20

@class PhotoImageView;
@class Playlist;;

@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UITabBarDelegate,AVAudioPlayerDelegate> {
@private
	Playlist *playlist;
    AppDelegate *myApp;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	UIScrollView *_scrollView;	
    
	NSUInteger currentPageIndex;
    NSUInteger pageIndexBeforeRotation;
                                                   
	BOOL _rotating;
	BOOL _barsHidden;
	BOOL performingLayout;
    BOOL playingPhoto;
                                                        
    NSTimer *controlVisibilityTimer;
    NSTimer *timer;	
    NSString *playPhotoTransition;
    AVAudioPlayer *audioPlayer;
    
    
}
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, strong) NSString *playPhotoTransition;

//init
- (id)init;
- (void)performLayout;

//paging
-(void)updatePages;
- (void)configurePage:(PhotoImageView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (PhotoImageView *)dequeueRecycledPage;
- (PhotoImageView *)pageDisplayedAtIndex:(NSUInteger)index;

//frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
//control
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)hideControlsAfterDelay;
- (void)cancelControlHiding;

//play audio
-(void)playAudioWithIndex:(NSInteger)index;
//PlayVideo and play photos
-(void)cancelPlayPhotoTimer;
-(void)fireTimer;

@end

