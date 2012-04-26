//
//  CustomToolbar.m
//  ProjectX
//
//  Created by apple on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomToolbar.h"

@implementation CustomToolbar

-(void)drawRect:(CGRect)rect{
    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"BottomBar.png"]];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end
