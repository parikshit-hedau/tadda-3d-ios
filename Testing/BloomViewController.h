//
//  BloomViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 03/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CreateMaskViewController.h"

#import "AppDelegate.h"

@protocol BloomDelegate <NSObject>

-(void)didFilter:(UIImage*)image;

@end

@interface BloomViewController : UIViewController <MaskingDelegate,UIActionSheetDelegate>
{
    IBOutlet UIImageView *imgViewMain,*imgViewMask;
    
    IBOutlet UIView *viewBoardBackground,*viewDrawingBoard;
    
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UISlider *sliderRadius,*sliderIntensity;
        
    BOOL isMaskOff,inverseMask;
    
    AppDelegate *appDel;
}

@property (nonatomic,retain) id<BloomDelegate> delegate;

@property (nonatomic,retain) UIImage *imgSelected;

-(IBAction)cancelAction:(id)sender;
-(IBAction)maskAction:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
