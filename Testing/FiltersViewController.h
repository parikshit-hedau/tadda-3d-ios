//
//  FiltersViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 01/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CreateMaskViewController.h"

#import "AppDelegate.h"

@protocol FilterEffectDelegate <NSObject>

-(void)didFilter:(UIImage*)image;

@end

@interface FiltersViewController : UIViewController <MaskingDelegate,UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    IBOutlet UIImageView *imgViewMain,*imgViewMask;
    
    IBOutlet UIView *viewBoardBackground,*viewDrawingBoard;
    
    IBOutlet UISlider *sliderFilter;
    
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UICollectionView *collectionViewFilters;
    
    BOOL isMaskOff,inverseMask;
    
    AppDelegate *appDel;
    
    NSMutableArray *arrFilters;
    
    UIImage *imgThumb;
    
    NSString *strSelectedFilter;
}

@property (nonatomic,retain) id<FilterEffectDelegate> delegate;

@property (nonatomic,retain) UIImage *imgSelected;

-(IBAction)cancelAction:(id)sender;
-(IBAction)maskAction:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
