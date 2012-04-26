//
//  CamaraViewController.m
//  ProjectX
//
//  Created by apple on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CamaraViewController.h"
#import "OverLayViewController.h"
#import "AppDelegate.h"
@implementation CamaraViewController
@synthesize recorder;
@synthesize imv;
@synthesize urlDefault;
@synthesize actView;
@synthesize loading;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myApp = [UIApplication sharedApplication].delegate;
   
}

-(NSString*)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return docDir;
}
-(IBAction)useImagePicker:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.showsCameraControls = NO;
        picker.navigationBarHidden = YES;
        picker.toolbarHidden = YES;
        picker.wantsFullScreenLayout = YES;
        picker.allowsEditing = NO;
        
        OverLayViewController *ov = [[OverLayViewController alloc]init];
        ov.ovPicker = picker;
        picker.delegate = (id)ov;
       // picker.delegate = (id)ov;
        
        picker.cameraOverlayView = ov.view;
        for (UIView *sub in picker.view.subviews) {
            NSLog(@"the sub view is %@",sub);
        }
        //UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:ov];
        [self presentModalViewController:picker animated:YES];
    }
}

-(IBAction)useAVFoundation:(id)sender{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput) {
        [captureSession addInput:audioInput];
    }
    else {
        // Handle the failure.
    }
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//    
//    
//    [library assetForURL:urlDefault resultBlock:^(ALAsset *assset){
//        ALAssetRepresentation *rep = [assset defaultRepresentation];
//        UIImage *image = [UIImage imageWithCGImage:[rep fullScreenImage]];
//        imv.image = image;
//        NSLog(@"set the image in the block method");
//    }failureBlock:^(NSError *error){
//        NSLog(@"get photo failed with error:%@",[error description]);
//    }];
//
}

-(void)recordAudio{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [date description];
    NSString *filePath = [[self documentPath]stringByAppendingFormat:@"%@.caf",caldate];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.recorder = nil;
  	self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
  	if (self.recorder) {
  		[self.recorder prepareToRecord];
  		self.recorder.meteringEnabled = YES;
  		[self.recorder record];
  	} else
  		NSLog(@"%@",[error description]);

}
#pragma mark - UIImagePicker delegate method
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.recorder stop];
    //UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"the url is %@ and referenceUrl is %@",[info valueForKey:UIImagePickerControllerMediaURL],[info valueForKey:UIImagePickerControllerReferenceURL]);
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    urlDefault = [info valueForKey:UIImagePickerControllerReferenceURL];
   /* ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    
    [library assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *assset){
        ALAssetRepresentation *rep = [assset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[rep fullScreenImage]];
        imv.image = image;
        NSLog(@"set the image in the block method");
    }failureBlock:^(NSError *error){
        NSLog(@"get photo failed with error:%@",[error description]);
    }];*/
    NSLog(@"the finished pick url is %@",urlDefault);
    [picker dismissModalViewControllerAnimated:YES];
    NSLog(@"hahahah");
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
/*-(IBAction)takePicture:(id)sender{
    NSString * str_url = [[NSString alloc] initWithString:@"http://www.lichsky.com/postme.asp"];
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] init];
    NSMutableURLRequest *mrequest = [[NSMutableURLRequest alloc] init];
    
    [mrequest setURL:[NSURL URLWithString:str_url]];
    
    NSMutableData* postBody = [NSMutableData data];
    
    [mrequest setHTTPMethod:@"POST"];
    
    NSString* udid = @"a=3&b=7";
   // NSData* udidData = [udid dataUsingEncoding:NSUTF8StringEncoding];
   // NSString* sendURL = [[NSString alloc] initWithData:udidData encoding:NSUTF8StringEncoding];
   // NSLog(@"udidData===%@",udidData);
   // NSLog(@"sendURL===%@",sendURL);
    //问题一：
    //udidData===<613d3326 623d37>  
    //sendURL===a=3&b=7
    [postBody appendData:[udid dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postBody length]];
    [mrequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [mrequest setHTTPBody:postBody];
    
  //  NSLog(@"postbody===%@",postBody);
    
    
    NSData* reData = [NSURLConnection sendSynchronousRequest:mrequest returningResponse:&response error:nil];
    if ( reData )
    {
        NSString* resultt = [[NSString alloc] initWithData:reData encoding:NSUTF8StringEncoding];
        NSLog(@"reData====%@",reData);
        NSLog(@"resultt====%@",resultt);
        //问题二：
        //reData====<30303631 30303546 30303633 30303646 30303634 30303635 30303435 30303732 30303732>
        //resultt====0061005F0063006F00640065004500720072
    }
    
}*/

-(void)dataLoadFinished{
    [self.actView stopAnimating];
    loading.hidden = YES;
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
