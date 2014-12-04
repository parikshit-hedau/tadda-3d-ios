//
//  FalseColorViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 03/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "FalseColorViewController.h"

@interface FalseColorViewController ()

@end

@implementation FalseColorViewController
@synthesize imgSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    lblTitle.text = @"False Color";
    
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
    
    sliderRed0.minimumValue = 0.0;
    sliderRed0.maximumValue = 1.0;
    sliderRed0.value = 0.0;
    
    sliderGreen0.minimumValue = 0.0;
    sliderGreen0.maximumValue = 1.0;
    sliderGreen0.value = 0.0;
    
    sliderBlue0.minimumValue = 0.0;
    sliderBlue0.maximumValue = 1.0;
    sliderBlue0.value = 0.0;
    
    sliderRed1.minimumValue = 0.0;
    sliderRed1.maximumValue = 1.0;
    sliderRed1.value = 0.0;
    
    sliderGreen1.minimumValue = 0.0;
    sliderGreen1.maximumValue = 1.0;
    sliderGreen1.value = 0.0;
    
    sliderBlue1.minimumValue = 0.0;
    sliderBlue1.maximumValue = 1.0;
    sliderBlue1.value = 0.0;
    
    [sliderRed0 addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderGreen0 addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderBlue0 addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderRed1 addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderGreen1 addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderBlue1 addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:kCIInputImageKey, ciImage, nil];
        
    [filter setValue:[CIColor colorWithRed:sliderRed0.value green:sliderGreen0.value blue:sliderBlue0.value] forKey:@"inputColor0"];

    [filter setValue:[CIColor colorWithRed:sliderRed1.value green:sliderGreen1.value blue:sliderBlue1.value] forKey:@"inputColor1"];
    
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
