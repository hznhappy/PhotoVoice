//
//  ThumbnailView.h
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class Asset;
@class ThumbnailView;
@protocol ThumbnailSelectionDelegate <NSObject>
-(void)thumbnailImageViewSelected:(ThumbnailView *)thumbnailImageView;
@end 

@interface ThumbnailView : UIImageView{
    UIImageView *highlightView;
    UIMenuController *theMenu;
    NSUInteger thumbnailIndex;
    UIImage *thumbnail;
    BOOL copyMenuShow;
    id<ThumbnailSelectionDelegate>__weak delegate;
}
@property(nonatomic,assign)NSUInteger thumbnailIndex;
@property(nonatomic,weak)id<ThumbnailSelectionDelegate>delegate;

-(ThumbnailView *)initWithFrame:(CGRect)frame Asset:(Asset*)asset index:(NSUInteger)index;
-(void)LoadThumbnailWithAsset:(Asset *)asset;
-(void)setSelectedView;
-(void)clearSelection;
@end
