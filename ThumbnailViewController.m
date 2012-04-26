//
//  ThumbnailViewController.m
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailViewController.h"
#import "DataManager.h"
#import "Asset.h"
#import "PhotoViewController.h"
@implementation ThumbnailViewController
@synthesize tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)viewDidDisappear:(BOOL)animated{
    if (selectedRow != NSNotFound && selectedSection != NSNotFound) {
        ThumbnailCell *cell = (ThumbnailCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
        [cell clearSelection];
        selectedRow = NSNotFound;
        selectedSection = NSNotFound;
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    //self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    App = [UIApplication sharedApplication].delegate;
    oritation = [UIApplication sharedApplication].statusBarOrientation;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    [self setThumbnailSize];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableData) name:@"reloadTableData" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)reloadTableData{
    oritation = [UIApplication sharedApplication].statusBarOrientation;
    if (oritation != previousOrientation) {
        [self setThumbnailSize];
        [self setTableViewEdge:oritation];
        [self.tableView reloadData];
        previousOrientation = oritation;
    }
}
#pragma mark - 
#pragma mark Custom methods
-(NSInteger)caculateRowNumbers:(NSInteger)count{
    return ceil(count/thumbnailSize);
}

-(void)setThumbnailSize{
    if (UIInterfaceOrientationIsLandscape(oritation)) {
         
            thumbnailSize = 6.0;
            iconsize = (self.view.frame.size.width - (thumbnailSize +1)*4) / thumbnailSize +4;
    }else{
        
        thumbnailSize = 4.0;
        iconsize = (self.view.frame.size.width - (thumbnailSize +1)*4) / thumbnailSize +4;
    }
    
}
-(void)setTableViewEdge:(UIInterfaceOrientation)orientation{
    UIEdgeInsets insets = self.tableView.contentInset;
    if (UIInterfaceOrientationIsLandscape(oritation)) {
        [self.tableView setContentInset:UIEdgeInsetsMake(53, insets.left, insets.bottom, insets.right)];
    }else{
        [self.tableView setContentInset:UIEdgeInsetsMake(65, insets.left, insets.bottom, insets.right)];
    }
}

-(NSString *)configurateLastRowPhotoCount:(NSInteger)pCount VideoCount:(NSInteger)vCount{
    NSString *__weak result = @"";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    if (pCount == 0 && vCount == 0) {
        return result;
    }else if(pCount != 0 && vCount == 0){
        NSString *__weak photoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:pCount]];
        if (pCount == 1) {
            result = [NSString stringWithFormat:@"%@ Photo",photoNumber];
        }else{
            result = [NSString stringWithFormat:@"%@ Photos",photoNumber];
        }
    }else if(pCount == 0 && vCount != 0){
        NSString *__weak videoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:vCount]];
        if (vCount == 1) {
            result = [NSString stringWithFormat:@"%@ Video",videoNumber];
        }else{
            result = [NSString stringWithFormat:@"%@ Videos",videoNumber];
        }
    }else if(pCount != 0 && vCount != 0){
        NSString *photoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:pCount]];
        NSString *videoNumber = [formatter stringFromNumber:[NSNumber numberWithInteger:vCount]];
        if (pCount == 1 && vCount == 1) {
            result = [NSString stringWithFormat:@"%@ Photo, %@ Video",photoNumber,videoNumber];
        }else if(pCount == 1 && vCount != 1){
            result = [NSString stringWithFormat:@"%@ Photo, %@ Videos",photoNumber,videoNumber];
        }else if(pCount != 1 && vCount == 1){
            result = [NSString stringWithFormat:@"%@ Photos, %@ Video",photoNumber,videoNumber];
        }
        else{
            result = [NSString stringWithFormat:@"%@ Photos, %@ Videos",photoNumber,videoNumber];
        }
        
    }
    return result;
}

#pragma mark - UITableView delegate and datasource method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    lastRow = [self caculateRowNumbers:App.dataManager.assets.count]+1;
    return lastRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return iconsize;
}

-(UITableViewCell *)tableView:(UITableView *)tableViews cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    ThumbnailCell *cell = [tableViews dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {	
        cell = [[ThumbnailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.selectionDelegate = self;
    cell.rowNumber = indexPath.row;
    cell.sectionNumber = indexPath.section;
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.row == lastRow-1) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.size.height/12, cell.frame.size.width, cell.frame.size.height*11/12)];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.backgroundColor=[UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Arial" size:20];
        label.text = [self configurateLastRowPhotoCount:App.dataManager.assets.count VideoCount:0];
        [cell addSubview:label];
    }else{
        NSMutableArray *assetsInRow = [[NSMutableArray alloc]init];
        
        for (NSInteger i = 0; i<thumbnailSize; i++) {
            NSInteger row = (indexPath.row * thumbnailSize)+i;
            Asset *dbAsset = nil;
            if (row < App.dataManager.assets.count) {
                dbAsset = [App.dataManager.assets objectAtIndex:row];
            }
            if (dbAsset != nil) {
                [assetsInRow addObject:dbAsset];
            }
        }
        if (assetsInRow.count != 0) {
            [cell displayThumbnails:assetsInRow beginIndex:indexPath.row count:thumbnailSize size:iconsize];
        }
    }
    return cell;
}

-(void)selectedThumbnailCell:(ThumbnailCell *)cell selectedAtIndex:(NSUInteger)index{
    selectedRow = cell.rowNumber;
    PhotoViewController *pc = [[PhotoViewController alloc]init];
    pc.currentPageIndex = index;
    NSLog(@"the select index is %d",index);
    [self.navigationController pushViewController:pc animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (ThumbnailCell *cell in self.tableView.visibleCells) {
        [cell clearSelection];
    }
}
@end
