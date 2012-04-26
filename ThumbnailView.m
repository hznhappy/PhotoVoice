//
//  ThumbnailView.m
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "DataManager.h"
#import "ThumbnailView.h"
#import "ThumbnailCell.h"
#import "Asset.h"
@implementation ThumbnailView
@synthesize thumbnailIndex;
@synthesize delegate;

-(ThumbnailView *)initWithFrame:(CGRect)frame Asset:(Asset*)asset index:(NSUInteger)index{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.thumbnailIndex = index;
        copyMenuShow = NO;
        self.frame = frame;
        [self LoadThumbnailWithAsset:asset];
    }
    return self;
}
-(void)LoadThumbnailWithAsset:(Asset *)asset{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    NSString *dbUrl = asset.libUrl;
    ALAsset *as = [appdelegate.dataManager getAsset:dbUrl];
    CGImageRef ref = [as thumbnail];
    UIImage *img = [UIImage imageWithCGImage:ref];//[UIImage imageNamed:@"IMG_9651.JPG"];//
    [self performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
    thumbnail = img;
}
#pragma mark -
#pragma mark Touch handling
- (void)showCopyMenu {
    copyMenuShow = YES;
    [self becomeFirstResponder];
    if (theMenu) {
        theMenu = nil;
    }
    theMenu = [UIMenuController sharedMenuController];
    CGRect selectionRect = [self bounds];
    selectionRect.origin.y += 30;
    [theMenu setTargetRect:selectionRect inView:self];
    [theMenu setMenuVisible:YES animated:YES]; 
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{   
    if (action == @selector(cut:))
        return NO;
    else if (action == @selector(copy:)){
        return YES;
    }
    else if (action == @selector(paste:))
        return NO;
    else if (action == @selector(select:) || action == @selector(selectAll:)) 
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

-(void)copy:(id)sender{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:thumbnail];//self.image];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (data) {
        [pasteBoard setData:data forPasteboardType:@"thumbnail"];
    }
    [self clearSelection];
}
- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

-(void)cancelCopyMenu{
    if (theMenu.isMenuVisible) {
        theMenu.menuVisible = NO;
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (ThumbnailCell *cell in ((UITableView *)self.superview.superview).visibleCells) {
        [cell clearSelection];
    }
    
    
        [self performSelector:@selector(showCopyMenu) withObject:nil afterDelay:0.8f];
        [self setSelectedView];
        [self addSubview:highlightView];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
    if (!copyMenuShow) {
        [self cancelCopyMenu];
        if ([delegate respondsToSelector:@selector(thumbnailImageViewSelected:)]) {
            [delegate thumbnailImageViewSelected:self];
        }
    }else{
        copyMenuShow = NO;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCopyMenu) object:nil];
    [self cancelCopyMenu];
    [highlightView removeFromSuperview];
}

#pragma mark -
#pragma mark Helper mehtods;
- (void)clearSelection {
    if (highlightView.superview != nil) {
        [highlightView removeFromSuperview];
    }
    
}


-(void)setSelectedView{
    if (!highlightView) {
        UIImage *image = [UIImage imageNamed:@"ThumbnailHighlight.png"];
        highlightView = [[UIImageView alloc]initWithImage:image];
        highlightView.frame = self.bounds;
        highlightView.alpha = 0.5;
    }
    
}


@end
