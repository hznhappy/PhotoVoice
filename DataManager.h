//
//  DataManager.h
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class AppDelegate;
@class Asset;
@protocol fetchAssetFinishedDelegate <NSObject>

-(void)dataLoadFinished;

@end
@interface DataManager : NSObject
{
    AppDelegate *delegate;
    NSMutableArray *assets;
    NSMutableDictionary *libAssets;
    ALAssetsLibrary *library;
    id<fetchAssetFinishedDelegate> __weak del;
}

@property(nonatomic,weak)id<fetchAssetFinishedDelegate> del;
@property(nonatomic,strong)NSMutableArray *assets;
@property(nonatomic,strong)NSMutableDictionary *libAssets;

-(void)fetchAssetsFromLibrary;
-(NSMutableArray *)simpleQuery:(NSString *)table predicate:(NSPredicate*)pre sortField:(NSString *) field sortOrder:(BOOL) asc;
-(void)insertEntityAssetWithAssetUrl:(NSString *)libUrl audioUrl:(NSString *)audioUrl;
-(void)deleteEntityAsset:(Asset *)asset;
-(void)deleteAudio:(NSString *)audUrl;
-(ALAsset *) getAsset:(NSString *)assetUrl;
//-(void)test;
@end
