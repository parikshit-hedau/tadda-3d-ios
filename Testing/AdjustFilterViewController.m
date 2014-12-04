//
//  FilterViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "AdjustFilterViewController.h"

#import "CreateMaskViewController.h"

@interface AdjustFilterViewController ()

@end

@implementation AdjustFilterViewController

@synthesize strFilterName,imgSelected;

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    lblTitle.text = self.strFilterName;
        
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    viewBoardBackground.frame = CGRectMake(viewBoardBackground.frame.origin.x, viewBoardBackground.frame.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-BOTTOM_MENU_HEIGHT-44);
    
    viewDrawingBoard.frame = CGRectMake(0, 0, self.imgSelected.size.width, self.imgSelected.size.height);
    
    viewDrawingBoard.center = CGPointMake(self.view.center.x, self.view.center.y + (44-BOTTOM_MENU_HEIGHT)/2);
    
    imgViewMain.frame = viewDrawingBoard.bounds;
    
    imgViewMain.image = self.imgSelected;
    
    imgViewMask.frame = imgViewMain.bounds;
    
    imgViewMask.image = appDel.maskImage;
    
    
    isMaskOff = NO;
    inverseMask = NO;
    
    
    sliderBrightness.minimumValue = 0.0;
    sliderBrightness.maximumValue = 0.4;
    sliderBrightness.value = 0.0;
    
    sliderContrast.minimumValue = 1.0;
    sliderContrast.maximumValue = 2.0;
    sliderContrast.value = 1.0;
    
    sliderSaturation.minimumValue = 0.0;
    sliderSaturation.maximumValue = 2.0;
    sliderSaturation.value = 1.0;
    
    [sliderBrightness addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderContrast addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderSaturation addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
}

-(IBAction)cancelAction:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)maskAction:(id)sender{
    
    if (appDel.maskImage) {
        
        if (isMaskOff) {
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mask On",nil];
            [sheet showInView:self.view];
        }
        else{
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:isMaskOff?@"Mask On":@"Mask Off",@"Inverse",@"Edit",nil];
            [sheet showInView:self.view];
        }
        
        return;
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
    
    CreateMaskViewController *createMaskViewController = [storyBoard instantiateViewControllerWithIdentifier:@"createMaskViewController"];
    
    createMaskViewController.delegate = self;
    
    createMaskViewController.imgSelected = self.imgSelected;
    
    createMaskViewController.navigationController.navigationBarHidden = YES;
    
    [self.navigationController pushViewController:createMaskViewController animated:YES];
}

-(IBAction)doneAction:(id)sender{
    
    UIGraphicsBeginImageContext(viewDrawingBoard.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    [viewDrawingBoard.layer renderInContext:context];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(context);
    
    [self.delegate didFilter:img];
    
    appDel.maskImage = imgViewMask.image;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sliderTouchEnd{
    
    if (inverseMask) {

        UIImage *img = [self  filteredImage:appDel.maskImage];
        imgViewMask.image = img;
    }
    else{

        UIImage *img = [self filteredImage:self.imgSelected];
        imgViewMain.image = img;
    }
}

#pragma mark -
#pragma mark Filer Methods

- (UIImage*)filteredImage:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setValue:@(sliderSaturation.value) forKey:kCIInputSaturationKey];
    
    [filter setValue:@(2*sliderBrightness.value) forKey:kCIInputBrightnessKey];
    
    [filter setValue:@(sliderContrast.value*sliderContrast.value) forKey:kCIInputContrastKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

-(UIImage*)sharpnessFilteredImage:(UIImage*)image withValue:(float)value{
    
    CIFilter *filter = [CIFilter filterWithName:@"CISharpenLuminance"];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    [filter setValue:ciImage forKey:kCIInputImageKey];
    
    [filter setValue:@(value) forKey:kCIInputSharpnessKey];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

- (UIImage*)brightnessFilteredImage:(UIImage*)image withValue:(float)value
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    
    CGFloat brightness = 2*value;
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputEV"];
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

- (UIImage*)contrastFilteredImage:(UIImage*)image withValue:(float)value
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrast   = value*value;
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputPower"];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

- (UIImage*)saturationFilteredImage:(UIImage*)image withValue:(float)value
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setValue:@(value) forKey:kCIInputSaturationKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
    
    return result;
}

#pragma mark -
#pragma mark - Masking Delegate Method

-(void)didMaskingWithImage:(UIImage*)img{
    
    isMaskOff = NO;
    
    appDel.maskImage = img;
    
    imgViewMask.image = appDel.maskImage;
    
    if (!appDel.maskImage) {
        
        inverseMask = NO;
        
        [self sliderTouchEnd];
    }
    else{
        
        if (inverseMask) {
            
            [self sliderTouchEnd];
        }
    }
}

#pragma mark -
#pragma mark Actionsheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        return;
    }
    
    if (buttonIndex == 0) {
        
        if (isMaskOff) {
            
            isMaskOff = NO;
            
            imgViewMask.image = appDel.maskImage;
        }
        else{
            
            isMaskOff = YES;
            
            imgViewMask.image = nil;
            
            if (inverseMask) {
                
                inverseMask = NO;
                
                [self sliderTouchEnd];
            }
        }
    }
    else if (buttonIndex == 1){
        
        if (inverseMask) {
            
            inverseMask = NO;
            
            imgViewMask.image = appDel.maskImage;
        }
        else{
            
            inverseMask = YES;
            
            imgViewMain.image = self.imgSelected;
        }
        
        [self sliderTouchEnd];
    }
    else{
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        CreateMaskViewController *createMaskViewController = [storyBoard instantiateViewControllerWithIdentifier:@"createMaskViewController"];
        
        createMaskViewController.delegate = self;
        
        createMaskViewController.imgSelected = self.imgSelected;
        
        createMaskViewController.imgMaskToEdit = appDel.maskImage;
        
        [self.navigationController pushViewController:createMaskViewController animated:YES];
    }
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
