//
//  DataManager.m
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "Asset.h"
@implementation DataManager
@synthesize del;
@synthesize assets,libAssets;
-(id)init{
    self = [super init];
    if (self) {
        delegate = [UIApplication sharedApplication].delegate;
        self.assets = [[NSMutableArray alloc]init];
        self.libAssets = [[NSMutableDictionary alloc]init];
        library = [[ALAssetsLibrary alloc]init];        
    }
    return self;
}

//-(void)test{
//    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
//    {
//        
//        if (group == nil) 
//        { 
//                        
//            return;
//        }
//        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
//         {         
//             
//             if(result == nil) 
//             { 
//                 return;
//             }
//             [self insertEntityAssetWithAssetUrl:[[result defaultRepresentation].url description] audioUrl:nil];
//         }];
//    };
//    
//    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
//        
//        NSLog(@"error happen when enumberatoring group,error: %@ ",[error description]);                 
//    };	
//    @autoreleasepool {
//        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
//                               usingBlock:assetGroupEnumerator 
//                             failureBlock:assetGroupEnumberatorFailure];
//    }
//
//}

-(void)fetchAssetsFromLibrary{
    assets = [self simpleQuery:@"Asset" predicate:nil sortField:@"date" sortOrder:YES];
   __block NSInteger i = 1;
    if (assets.count != 0) {
        for (Asset *as in assets) {
            NSURL *url = [NSURL URLWithString:as.libUrl];
            [library assetForURL:url resultBlock:^(ALAsset *assset){
                if (!assset) {
                    [self deleteEntityAsset:as];
                    [assets removeObject:as];
                    [self deleteAudio:as.audioUrl];
                }else{
                    [libAssets setObject:assset forKey:[[[assset defaultRepresentation] url]description]];
                }
                i += 1;
                if (i > assets.count) {
                    if ([del respondsToSelector:@selector(dataLoadFinished)]) {
                        [del dataLoadFinished];
                    }
                }
            }failureBlock:^(NSError *error){
                NSLog(@"get photo failed with error:%@",[error description]);
            }];
        }
    }else{
        if ([del respondsToSelector:@selector(dataLoadFinished)]) {
            [del dataLoadFinished];
        }
    }
}
-(NSMutableArray*) simpleQuery:(NSString *)table predicate:(NSPredicate *)pre sortField:(NSString *)field sortOrder:(BOOL)asc {
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:delegate.managedObjectContext];   
    NSFetchRequest *request = [[NSFetchRequest alloc] init];  
    [request setEntity:entity];
    if (pre!=nil) {
        
        [request setPredicate:pre];
    }
    if (field!=nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:asc];  
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];  
        [request setSortDescriptors:sortDescriptors];  
        
    }
    NSError *error;  
    NSMutableArray *mutableFetchResults = [[delegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    if (!mutableFetchResults) {  
        NSLog(@"fetch data from coreDate error");
    }   
    
    // Save our fetched data to an array  
    return mutableFetchResults;
}


-(void)insertEntityAssetWithAssetUrl:(NSString *)libUrl audioUrl:(NSString *)audioUrl{
    Asset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:delegate.managedObjectContext];
    asset.libUrl = libUrl;
    asset.audioUrl = audioUrl;
    asset.date = [NSDate date];
    [delegate saveContext];
    [self.assets addObject:asset];
    [library assetForURL:[NSURL URLWithString:libUrl] resultBlock:^(ALAsset *assset){
//        if (!assset) {
//            [self deleteEntityAsset:as];
//            [assets removeObject:as];
//            [self deleteAudio:as.audioUrl];
//        }else{
            [libAssets setObject:assset forKey:[[[assset defaultRepresentation] url]description]];
        
    }failureBlock:^(NSError *error){
        NSLog(@"get photo failed with error:%@",[error description]);
    }];

}

-(void)deleteEntityAsset:(Asset *)asset{
    [delegate.managedObjectContext deleteObject:asset];
    [delegate saveContext];
}
-(void)deleteAudio:(NSString *)audUrl{
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:audUrl];
    if (![[NSFileManager defaultManager]removeItemAtURL:url error:&error]) {
        NSLog(@"delete audio file failed with error:%@",error);
    }
}

-(ALAsset *) getAsset:(NSString *)assetUrl{
    return (ALAsset*)[libAssets objectForKey:assetUrl];
}
@end
