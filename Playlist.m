//
//  Playlist.m
//  PhotoApp2
//
//  Created by KM Tong on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Playlist.h"
#import "Asset.h"
@implementation Playlist
@synthesize showing;
@synthesize storeAssets;
@synthesize assets;
@synthesize icache;
@synthesize fcache;
@synthesize queue;

-(id) init {
    self = [super init];
    
    // thumbnail image cache
    icache = [[NSCache alloc]init];
    icache.countLimit = 10;
    
    // fullscreen image cache
    fcache = [[NSCache alloc]init];
    fcache.countLimit = 3;
    
    queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:1];
    return self;
}

-(ALAsset *) assetAtIndex: (NSUInteger)index {
    Asset *as = (Asset *)[self.storeAssets objectAtIndex:index];
    NSString *url = as.libUrl;
    return [self.assets valueForKey:url];
}

-(UIImage *) fuzzyImageAtIndex: (NSUInteger)index forFullScreenImage: (void (^)(UIImage *))whenDone
{
    Asset *as = (Asset *)[self.storeAssets objectAtIndex:index];
    NSString *url = as.libUrl;
    
    UIImage *fuzzy = [icache objectForKey:url];
    UIImage *fs = [fcache objectForKey:url];
    
    if (fuzzy != nil) {
        if (fs != nil) {
            // callback with the fullscreen image first
           // NSLog(@"Fullscreen Cache Hit");
            whenDone(fs);
        } else {
            [self doFetchFullScreenImage:url whenDone:^(UIImage *fsImage) {
                // cache it
                [fcache setObject:fsImage forKey:url];
                whenDone(fsImage);
            }];
        }
        // and return the fuzzy image
        //NSLog(@"Fuzzy Cache Hit");
        return fuzzy;
        
    } else {
        if (fs != nil) {
            // callback with the fullscreen image first
           // NSLog(@"Fullscreen Cache Hit");
            whenDone(fs);
            fuzzy = [self doFetchFuzzyImage:url andFullScreenImage:nil];
        } else {
            fuzzy = [self doFetchFuzzyImage:url andFullScreenImage:^(UIImage *fsImage) {
                // do fullscreen image caching
                [fcache setObject:fsImage forKey:url];
                whenDone(fsImage);
            }];
        }
        [icache setObject:fuzzy forKey:url];
        return fuzzy;
    }
}

- (UIImage *) doFetchImage: (NSString*) url
{
    ALAsset *asset = [self.assets valueForKey:url];
    
//    NSLog(@"FullScreen Image: CGImageRef Start Loading");
    CGImageRef iref = [[asset defaultRepresentation] fullScreenImage];
//    NSLog(@"FullScreen Image: CGImageRef Done Loading FullScreen Image");
    UIImage *image = [UIImage imageWithCGImage: iref];
//    NSLog(@"FullScreen Image: UIImage Done Loading");
    
    return image;
}

- (UIImage *) doFetchFuzzyImage: (NSString*) url andFullScreenImage: (void (^)(UIImage *))whenDone
{
    ALAsset *asset = [self.assets valueForKey:url];
    
//    NSLog(@"Fuzzy Image: CGImageRef Start Loading");
    CGImageRef iref = [asset aspectRatioThumbnail];
//    NSLog(@"Fuzzy Image: CGImageRef Done Loading");
    UIImage *image = [UIImage imageWithCGImage: iref];
//    NSLog(@"Fuzzy Image: UIImage Done Loading");
    if (whenDone != nil) {
        [self doFetchFullScreenImage:url whenDone:whenDone];
    }
    return image;
}

- (void) doFetchFullScreenImage: (NSString*) url whenDone: (void (^)(UIImage *))whenDone
{
    [queue cancelAllOperations];
    
    NSInvocationOperation *q = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doFetchImage:) object:url];
    
    // weak reference to prevent cycle retain
    __block __typeof__(q) _q = q;
    [q setCompletionBlock:^(void) {
        if (![_q isCancelled]) {
            whenDone([_q result]); 
            _q = nil;
        } else {
            _q = nil;
        }
    }];
    
    [queue addOperation:q];
}

@end
