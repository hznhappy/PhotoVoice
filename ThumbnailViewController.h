//
//  ThumbnailViewController.h
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailCell.h"
#import "AppDelegate.h"
@interface ThumbnailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,ThumbnailCellSelectionDelegate>
{
    AppDelegate *App;
    
    UIInterfaceOrientation oritation;
    UIInterfaceOrientation previousOrientation;
    
    NSInteger iconsize;
    NSUInteger selectedRow;
    NSUInteger selectedSection;
    NSUInteger lastRow;
    float thumbnailSize;

}
@property (nonatomic , weak)IBOutlet UITableView *tableView;


//Custom method
-(NSInteger)caculateRowNumbers:(NSInteger)count;
-(void)setThumbnailSize;
-(void)setTableViewEdge:(UIInterfaceOrientation)orientation;
-(NSString *)configurateLastRowPhotoCount:(NSInteger)pCount VideoCount:(NSInteger)vCount;
-(void)reloadTableData;
@end
