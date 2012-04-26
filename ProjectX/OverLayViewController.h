//
//  OverLayViewController.h
//  ProjectX
//
//  Created by apple on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
@class CustomToolbar;
@interface OverLayViewController : UIViewController<UIImagePickerControllerDelegate>
{
    AppDelegate *myapp;
    NSURL *audioUrl;
    
    AVAudioSession *avSession;
    AVAudioRecorder *recorder;
    NSDictionary *settings;
}

@property (nonatomic,strong)UIImagePickerController *ovPicker;
@property (nonatomic,weak)IBOutlet UIToolbar *toolbar;

-(IBAction)takePicture:(id)sender;
-(IBAction)viewPhotos:(id)sender;
-(IBAction)settings:(id)sender;

-(NSString*)documentPath;
-(void)recordAudio;
@end
