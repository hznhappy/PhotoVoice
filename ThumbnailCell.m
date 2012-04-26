//
//  ThumbnailCell.m
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailCell.h"
#import "Asset.h"
@implementation ThumbnailCell
@synthesize selectionDelegate;
@synthesize rowNumber,sectionNumber;

-(void)displayThumbnails:(NSArray *)array beginIndex:(NSInteger)index count:(NSUInteger)count size:(NSInteger)size{
    thumnailsize = size - 4;
    index = self.rowNumber * count;
    CGRect frame = CGRectMake(4, 2, thumnailsize, thumnailsize);
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSUInteger i = 0;i <count; i++) {
        if (i < [array count]) {
            Asset *dbAsset = [array objectAtIndex:i];
            
            ThumbnailView *thumImageView = [[ThumbnailView alloc]initWithFrame:frame Asset:dbAsset index:index];
            thumImageView.delegate = self;
            [self addSubview:thumImageView];
            frame.origin.x = frame.origin.x + frame.size.width + 4;
            index += 1;
        }        
    }

}
-(void)clearSelection{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ThumbnailView class]]) {
            [(ThumbnailView *)view clearSelection];
        }
    }
}
#pragma mark -
#pragma mark delegate methods;
-(void)thumbnailImageViewSelected:(ThumbnailView *)thumbnailImageView{
    [selectionDelegate selectedThumbnailCell:self selectedAtIndex:thumbnailImageView.thumbnailIndex];
}


@end
