//
//  Asset.h
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Asset : NSManagedObject

@property (nonatomic, retain) NSString * libUrl;
@property (nonatomic, retain) NSString * audioUrl;
@property (nonatomic, retain) NSDate * date;

@end
