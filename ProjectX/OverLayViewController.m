//
//  OverLayViewController.m
//  ProjectX
//
//  Created by apple on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OverLayViewController.h"
#import "CustomToolbar.h"
#import "ThumbnailViewController.h"
#import "DataManager.h"
@implementation OverLayViewController
@synthesize ovPicker;
@synthesize toolbar;
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
-(void)viewWillAppear:(BOOL)animated{
    //self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /** Change the UIToolBar like the iphone camera bar style 
     *  but the toolbar item style did not change ,
     *  need to fix the bar item style
     *
     */
//    UIImage *bottomBar = [[UIImage alloc]initWithContentsOfFile:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"BottomBar.png"]];
//    UIImageView *bottomImv = [[UIImageView alloc]initWithImage:bottomBar];
//    [self.view addSubview:bottomImv];
//    [self.toolbar insertSubview:bottomImv atIndex:0];
  /*  UIImage *pic = [[UIImage alloc]initWithContentsOfFile:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"albums.png"]];
    UIImage *cameraImg = [[UIImage alloc]initWithContentsOfFile:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"photo_24.png"]];
    UIImage *settingsImg = [[UIImage alloc]initWithContentsOfFile:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"gear_24.png"]];
    UIBarButtonItem *spceFlex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *photos = [[UIBarButtonItem alloc]initWithImage:pic style:UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem *camera = [[UIBarButtonItem alloc]initWithImage:cameraImg style:UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem *settings = [[UIBarButtonItem alloc]initWithImage:settingsImg style:UIBarButtonItemStyleBordered target:self action:nil];
    
    NSArray *toolBarItems = [[NSArray alloc]initWithObjects:photos,spceFlex,camera,spceFlex,settings, nil];

    self.toolbar = [[CustomToolbar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-44, 320, 44)];
    self.toolbar.items = toolBarItems;
    
    [self.view addSubview:self.toolbar];*/
    
    myapp = [UIApplication sharedApplication].delegate;
    
    avSession = [AVAudioSession sharedInstance];
    settings = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                nil];
    NSError *err = nil;
    [avSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSessionSetCategory: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    err = nil;
    [avSession setActive:YES error:&err];
    
    if(err){
        NSLog(@"audioSessionSetActive: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }

    [self recordAudio];
    
}

-(IBAction)takePicture:(id)sender{
    //[self presentModalViewController:self.ovPicker animated:YES];
    [self.ovPicker takePicture];
    
    [self performSelector:@selector(stopRecord) withObject:nil afterDelay:20];
    
    
}

-(void)stopRecord{
    if (recorder.recording) {
        [recorder stop];
        [self recordAudio];
    }
}

-(IBAction)viewPhotos:(id)sender{
    ThumbnailViewController *thc = [[ThumbnailViewController alloc]initWithNibName:@"ThumbnailViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:thc animated:YES];
}

-(IBAction)settings:(id)sender{
    
}

-(NSString*)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return docDir;
}

-(void)recordAudio{
    recorder = nil;
    audioUrl = nil;
    NSError *error = nil;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [date description];
    NSString *path = [NSString stringWithFormat:@"%@.caf",caldate];
    NSString *filePath = [[self documentPath]stringByAppendingPathComponent:path];
    audioUrl = [NSURL fileURLWithPath:filePath];
  	recorder = [[AVAudioRecorder alloc] initWithURL:audioUrl settings:settings error:&error];
    
  	if (recorder) {
  		[recorder prepareToRecord];
  		recorder.meteringEnabled = YES;
  		[recorder record];
  	} else
  		NSLog(@"%@",[error description]);
    
}
#pragma mark - UIImagePicker delegate method
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"ImagePickerConroller didFinished delegate fired");
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    NSURL *refUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    [myapp.dataManager insertEntityAssetWithAssetUrl:[refUrl description] audioUrl:[audioUrl description]];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image  
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                           message:@"Unable to save image to Photo Album." 
                                          delegate:self cancelButtonTitle:@"Ok" 
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success" 
                                           message:@"Image saved to Photo Album." 
                                          delegate:self cancelButtonTitle:@"Ok" 
                                 otherButtonTitles:nil];
    [alert show];
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

@end
