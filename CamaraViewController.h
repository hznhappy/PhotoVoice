//
//  CamaraViewController.h
//  ProjectX
//
//  Created by apple on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DataManager.h"
@interface CamaraViewController : UIViewController<UIImagePickerControllerDelegate,fetchAssetFinishedDelegate>
{
    AppDelegate *myApp;
}

@property (nonatomic , strong)AVAudioRecorder *recorder;
@property (nonatomic , weak)IBOutlet UIImageView *imv;
@property (nonatomic , strong)NSURL *urlDefault;
@property (nonatomic , weak)IBOutlet UIActivityIndicatorView *actView;
@property (nonatomic , weak)IBOutlet UILabel *loading;
//-(IBAction)takePicture:(id)sender;
-(IBAction)useImagePicker:(id)sender;
-(IBAction)useAVFoundation:(id)sender;
-(NSString*)documentPath;
-(void)recordAudio;
@end
