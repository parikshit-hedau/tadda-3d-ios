//
//  FiltersViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 01/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "FiltersViewController.h"

#import "FilterCell.h"

@interface FiltersViewController ()

@end

@implementation FiltersViewController

@synthesize delegate;
@synthesize imgSelected;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    lblTitle.text = @"Filters";
    
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
    
    arrFilters = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIColorInvert",@"filter",@"Invert",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIMaximumComponent",@"filter",@"Maximum",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIMinimumComponent",@"filter",@"Minimum",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectChrome",@"filter",@"Chrome",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectFade",@"filter",@"Fade",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectInstant",@"filter",@"Instant",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectMono",@"filter",@"Mono",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectNoir",@"filter",@"Noir",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectProcess",@"filter",@"Process",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectTonal",@"filter",@"Tonal",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CIPhotoEffectTransfer",@"filter",@"Transfer",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CILinearToSRGBToneCurve",@"filter",@"Tone",@"name", nil];
    [arrFilters addObject:dict];
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CISRGBToneCurveToLinear",@"filter",@"Tone Linear",@"name", nil];
    [arrFilters addObject:dict];
    
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"None",@"filter",@" None",@"name", nil];
    [arrFilters insertObject:dict atIndex:0];

    [self removeSavedFilteredImages];
    
//    NSMutableArray *arrFiltersAll = [[NSMutableArray alloc] init];
//    
//    NSArray *arr = [CIFilter filterNamesInCategory:kCICategoryColorEffect];
//    
//    [arrFiltersAll addObjectsFromArray:arr];
//    
//    arr = [CIFilter filterNamesInCategory:kCICategoryColorAdjustment];
//    
//    [arrFiltersAll addObjectsFromArray:arr];
//    
//    NSLog(@"arr = %@",arr);
//    
//    for (int i=0; i<arrFiltersAll.count; i++) {
//        
//        CIFilter *filter = [CIFilter filterWithName:[arrFiltersAll objectAtIndex:i]];
//        
//        NSLog(@"attributes = %@",filter.attributes);
//        
//        if (filter.attributes.count == 4) {
//            
//            [arrFilters addObject:[arrFiltersAll objectAtIndex:i]];
//        }
//    }
//    
//    NSLog(@"filter = %@",arrFilters);
//    
//    [arrFilters insertObject:@"None" atIndex:0];
//    
//    [arrFilters removeObject:@"CIMaskToAlpha"];
    
    strSelectedFilter = @"None";
    
    imgThumb = [self cropImage:self.imgSelected withSize:CGSizeMake(self.imgSelected.size.width/10, self.imgSelected.size.height/10)];
    
    [collectionViewFilters registerNib:[UINib nibWithNibName:@"FilterCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
}

-(UIImage*)cropImage:(UIImage*)image withSize:(CGSize)size{
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width*4, size.height*4);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

-(IBAction)cancelAction:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)removeSavedFilteredImages{
    
    for (int i=0; i<arrFilters.count; i++) {
        
        NSDictionary *dict = [arrFilters objectAtIndex:i];
        
        NSString *strFilter = [dict objectForKey:@"filter"];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:strFilter];
    }
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

#pragma mark -
#pragma mark Filer Methods

- (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
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
    
    inverseMask = NO;
    
    UIImage *image = [self filteredImage:self.imgSelected withFilterName:strSelectedFilter];
    
    imgViewMain.image = image;
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
                
                UIImage *img = [self filteredImage:self.imgSelected withFilterName:strSelectedFilter];
                
                imgViewMain.image = img;
            }
        }
    }
    else if (buttonIndex == 1){
        
        if (inverseMask) {
            
            inverseMask = NO;
            
            imgViewMask.image = appDel.maskImage;
            
            UIImage *img = [self filteredImage:self.imgSelected withFilterName:strSelectedFilter];
            
            imgViewMain.image = img;
        }
        else{
            
            inverseMask = YES;
            
            imgViewMain.image = self.imgSelected;
            
            UIImage *img = [self filteredImage:appDel.maskImage withFilterName:strSelectedFilter];
            
            imgViewMask.image = img;
        }
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
#pragma mark CollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
 
    return arrFilters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *dict = [arrFilters objectAtIndex:indexPath.row];
    
    [cell startFilterWithImage:imgThumb withFilterName:[dict objectForKey:@"filter"] withName:[dict objectForKey:@"name"]];
    
    NSString *strFilter = [dict objectForKey:@"filter"];
    
    if ([strFilter isEqualToString:strSelectedFilter]) {
        
        cell.labelFilterName.textColor = [UIColor blueColor];
    }
    else{
        
        cell.labelFilterName.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    CGSize headerSize = CGSizeMake(10, 80);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGSize headerSize = CGSizeMake(10, 80);
    return headerSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        if (inverseMask) {
            
            imgViewMask.image = appDel.maskImage;
        }
        else{
            
            imgViewMain.image = self.imgSelected;
        }
        
        strSelectedFilter = @"None";
    }
    else{
        
        NSDictionary *dict = [arrFilters objectAtIndex:indexPath.row];
        
        strSelectedFilter = [dict objectForKey:@"filter"];
        
        if (inverseMask) {
            
            UIImage *img = [self filteredImage:appDel.maskImage withFilterName:strSelectedFilter];
            
            imgViewMask.image = img;
        }
        else{
            
            UIImage *img = [self filteredImage:self.imgSelected withFilterName:strSelectedFilter];
            
            imgViewMain.image = img;
        }
    }
    
    [collectionView reloadData];
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
