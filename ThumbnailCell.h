//
//  ThumbnailCell.h
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailView.h"
@class ThumbnailCell;

@protocol ThumbnailCellSelectionDelegate <NSObject>

-(void)selectedThumbnailCell:(ThumbnailCell *)cell selectedAtIndex:(NSUInteger)index;

@end


@interface ThumbnailCell : UITableViewCell<ThumbnailSelectionDelegate>{
    NSUInteger rowNumber;
    NSInteger sectinNumber;
    NSInteger thumnailsize;
    id<ThumbnailCellSelectionDelegate>__weak selectionDelegate;
}

@property (nonatomic, assign) NSUInteger rowNumber;
@property (nonatomic, assign) NSInteger sectionNumber;
@property (nonatomic, weak) id<ThumbnailCellSelectionDelegate> selectionDelegate;

-(void)displayThumbnails:(NSArray *)array beginIndex:(NSInteger)index count:(NSUInteger)count size:(NSInteger)size;
-(void)clearSelection;
@end
