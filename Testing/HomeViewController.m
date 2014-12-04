//
//  HomeViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//k

#import "HomeViewController.h"

#import "EditPhotoViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Select Photo";
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIImage *imgSelected = [UIImage imageNamed:@"IMG_0808.JPG"];
    
    imgSelected = [self resizeImage:imgSelected resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-44-BOTTOM_MENU_HEIGHT)];
    
    NSLog(@"size = %@",NSStringFromCGSize(imgSelected.size));
    
    //imgSelected = [self filteredImage:imgSelected withFilterName:@"CIFalseColor"];
    
    imgView.image = imgSelected;
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    imgView.frame = CGRectMake(imgView.frame.origin.x, 44, imgSelected.size.width, imgSelected.size.height);
    
    imgView.center = CGPointMake(self.view.center.x, self.view.center.y + (44-BOTTOM_MENU_HEIGHT)/2);

    NSLog(@"frame = %@",NSStringFromCGRect(imgView.frame));
    
    NSLog(@"center = %@",NSStringFromCGPoint(imgView.center));
}

- (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    // CIExposureAdjust
    //[filter setValue:@1 forKey:@"inputEV"];

    // CIColorMonochrome
    //[filter setValue:@1.0 forKey:@"inputIntensity"];
    
    // CIColorPosterize
    //[filter setValue:@5.0 forKey:@"inputLevels"];

    // CIFalseColor
    //[filter setValue:[CIColor colorWithRed:0.4 green:0.1 blue:0.1] forKey:@"inputColor0"];
    
    // CISepiaTone
    //[filter setValue:@1.0 forKey:@"inputIntensity"];
    
    // CIVignetteEffect
    //[filter setValue:@-1 forKey:@"inputIntensity"];
    //[filter setValue:@2000 forKey:@"inputRadius"];
    //[filter setValue:@1 forKey:@"inputFalloff"];
    
    // CIBloom
    //[filter setValue:@1 forKey:@"inputIntensity"];
    //[filter setValue:@3 forKey:@"inputRadius"];
    
    // CIGloom
    //[filter setValue:@1 forKey:@"inputIntensity"];
    //[filter setValue:@100 forKey:@"inputRadius"];
    
    // CIHighlightShadowAdjust
    //[filter setValue:@10 forKey:@"inputRadius"];
    //[filter setValue:@1 forKey:@"inputShadowAmount"];
    //[filter setValue:@0 forKey:@"inputHighlightAmount"];
    
    // CIPixellate
    //[filter setValue:@4 forKey:@"inputScale"];
    //[filter setValue:[CIVector vectorWithX:100 Y:200] forKey:@"inputCenter"];
    
    // CIGaussianBlur
    //[filter setValue:@100 forKey:@"inputRadius"];
    
    // CISharpenLuminance
    //[filter setValue:@2 forKey:@"inputSharpness"];
    
    // CIUnsharpMask
    //[filter setValue:@1 forKey:@"inputIntensity"];
    //[filter setValue:@10 forKey:@"inputRadius"];
    
    NSLog(@"%@",filter.attributes);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

#pragma mark -
#pragma mark Select Photo from Library Method

-(void)selectPhotoFromLibrary{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark Capture Photo from Camera Method

-(void)capturePhotoFromCamere{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark Photo Button Action

-(IBAction)photoAction:(id)sender{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Photo Library", nil];
    
    [sheet showInView:self.view];
}

#pragma mark -
#pragma mark Actionsheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        return;
    }
    
    if (buttonIndex == 0) {
        
        NSLog(@"camera");
        
        [self capturePhotoFromCamere];
    }
    else{
        
        NSLog(@"Photo Library");
        
        [self selectPhotoFromLibrary];
    }
}

#pragma mark -
#pragma mark Edit Photo Action

-(IBAction)editAction:(id)sender{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
    
    EditPhotoViewController *editPhotoViewController = [storyBoard instantiateViewControllerWithIdentifier:@"editPhotoViewController"];
    
    editPhotoViewController.imgSelected = imgView.image;
    
    [self.navigationController pushViewController:editPhotoViewController animated:YES];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"info = %@",info);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *imgSelected = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    imgSelected = [self resizeImage:imgSelected resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-120-44)];
    
    NSLog(@"size = %@",NSStringFromCGSize(imgSelected.size));
    
    imgView.image = imgSelected;
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    imgView.frame = CGRectMake(imgView.frame.origin.x, 64, imgSelected.size.width, imgSelected.size.height);
    
    imgView.center = CGPointMake(self.view.center.x, self.view.center.y + (44-BOTTOM_MENU_HEIGHT)/2);
    
    appDel.maskImage = nil;
}

#pragma mark -
#pragma mark Image Resize Method

-(UIImage *)resizeImage:(UIImage *)image resizeSize:(CGSize)size
{
    CGFloat actualHeight = image.size.height;
    CGFloat actualWidth = image.size.width;
    //  if(actualWidth <= size.width && actualHeight<=size.height)
    //  {
    //      return orginalImage;
    //  }
    float oldRatio = actualWidth/actualHeight;
    float newRatio = size.width/size.height;
    if(oldRatio < newRatio)
    {
        oldRatio = size.height/actualHeight;
        actualWidth = oldRatio * actualWidth;
        actualHeight = size.height;
    }
    else
    {
        oldRatio = size.width/actualWidth;
        actualHeight = oldRatio * actualHeight;
        actualWidth = size.width;
    }
    
    CGRect rect = CGRectMake(0.0,0.0,actualWidth,actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)resizeImage1:(UIImage *)image toSize:(CGSize)size
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    float scale = size.width/size.height;
    
    imageWidth = imageWidth*scale;
    imageHeight = imageHeight/scale;
    
    CGRect rect = CGRectMake(0.0, 0.0, imageWidth, imageHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
