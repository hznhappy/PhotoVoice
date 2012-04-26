//
//  Playlist.h
//  PhotoApp2
//
//  Created by KM Tong on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface Playlist : NSObject {
    NSMutableArray *storeAssets;
    NSMutableDictionary /*url(String)->asset mapping*/ *assets;
    NSInteger showing;
    
    NSOperationQueue* queue;
    
    // --- Cached Image ---
    NSCache *icache;  // thumbnail
    NSCache *fcache;  // fullscreen
    
}

@property (nonatomic, strong) NSMutableArray *storeAssets;
@property (nonatomic, strong) NSMutableDictionary /*url(String)->asset mapping*/ *assets;

@property (nonatomic) NSInteger showing;
@property (nonatomic, strong) NSCache *icache;
@property (nonatomic, strong) NSCache *fcache;
@property (nonatomic, strong) NSOperationQueue *queue;

-(ALAsset *) assetAtIndex: (NSUInteger)index;

// ----- porting to new methods
- (UIImage *) doFetchImage: (NSString*) url;
- (UIImage *) doFetchFuzzyImage: (NSString*) url andFullScreenImage: (void (^)(UIImage *))whenDone;
- (void) doFetchFullScreenImage: (NSString*) url whenDone: (void (^)(UIImage *))whenDone;

-(UIImage *) fuzzyImageAtIndex: (NSUInteger)index forFullScreenImage: (void (^)(UIImage *))whenDone;

@end
