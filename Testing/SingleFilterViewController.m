//
//  FilterViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "SingleFilterViewController.h"

#import "CreateMaskViewController.h"

@interface SingleFilterViewController ()

@end

@implementation SingleFilterViewController

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
    
    [sliderFilter addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    
    isMaskOff = NO;
    inverseMask = NO;
    
    if ([self.strFilterName isEqualToString:@"Sharpness"]){
        
        sliderFilter.minimumValue = 0.0;
        sliderFilter.maximumValue = 1.0;
        sliderFilter.value = 0.0;
    }
    else if ([self.strFilterName isEqualToString:@"Posterize"]){
        
        sliderFilter.minimumValue = 2.0;
        sliderFilter.maximumValue = 30.0;
        sliderFilter.value = 30.0;
    }
    else if ([self.strFilterName isEqualToString:@"Sepia"]){
        
        sliderFilter.minimumValue = 0.0;
        sliderFilter.maximumValue = 1.0;
        sliderFilter.value = 0.0;
    }
    else if ([self.strFilterName isEqualToString:@"Exposure"]){
        
        sliderFilter.minimumValue = -2.5;
        sliderFilter.maximumValue = 2.5;
        sliderFilter.value = 1.0;
    }
    else if ([self.strFilterName isEqualToString:@"Pixellate"]){
        
        sliderFilter.minimumValue = 1.0;
        sliderFilter.maximumValue = 6.0;
        sliderFilter.value = 1.0;
    }
    
    //[self sliderTouchEnd];
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
        
        UIImage *img = nil;
        
        if ([self.strFilterName isEqualToString:@"Sharpness"]){
            
            img = [self sharpnessFilteredImage:appDel.maskImage withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Posterize"]){
            
            img = [self posterizeFilteredImage:appDel.maskImage withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Sepia"]){
            
            img = [self sepiaFilteredImage:appDel.maskImage withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Exposure"]){
            
            img = [self exposureFilteredImage:appDel.maskImage withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Pixellate"]){
            
            img = [self pixellateFilteredImage:appDel.maskImage withValue:sliderFilter.value];
        }
        
        imgViewMask.image = img;
    }
    else{
        
        UIImage *img = nil;
        
        if ([self.strFilterName isEqualToString:@"Sharpness"]){
            
            img = [self sharpnessFilteredImage:self.imgSelected withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Posterize"]){
            
            img = [self posterizeFilteredImage:self.imgSelected withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Sepia"]){
            
            img = [self sepiaFilteredImage:self.imgSelected withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Exposure"]){
            
            img = [self exposureFilteredImage:self.imgSelected withValue:sliderFilter.value];
        }
        else if ([self.strFilterName isEqualToString:@"Pixellate"]){
            
            img = [self pixellateFilteredImage:self.imgSelected withValue:sliderFilter.value];
        }
        
        imgViewMain.image = img;
    }
}

#pragma mark -
#pragma mark Filer Methods

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

-(UIImage*)posterizeFilteredImage:(UIImage*)image withValue:(float)value{
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorPosterize" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    // CIColorPosterize
    [filter setValue:[NSNumber numberWithFloat:sliderFilter.value] forKey:@"inputLevels"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

-(UIImage*)sepiaFilteredImage:(UIImage*)image withValue:(float)value{
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    // CISepiaTone
    [filter setValue:[NSNumber numberWithFloat:sliderFilter.value] forKey:@"inputIntensity"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

-(UIImage*)exposureFilteredImage:(UIImage*)image withValue:(float)value{
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setValue:[NSNumber numberWithFloat:sliderFilter.value] forKey:@"inputEV"];
    
    NSLog(@"attributes = %@",filter.attributes);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

-(UIImage*)pixellateFilteredImage:(UIImage*)image withValue:(float)value{
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    // CIPixellate
    [filter setValue:[NSNumber numberWithFloat:sliderFilter.value] forKey:@"inputScale"];
    [filter setValue:[CIVector vectorWithX:self.imgSelected.size.width/2 Y:self.imgSelected.size.height/2] forKey:@"inputCenter"];
    
    NSLog(@"attributes = %@",filter.attributes);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
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
