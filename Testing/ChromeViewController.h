//
//  ChromeViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 03/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CreateMaskViewController.h"

#import "AppDelegate.h"

@protocol ChromeDelegate <NSObject>

-(void)didFilter:(UIImage*)image;

@end

@interface ChromeViewController : UIViewController <MaskingDelegate,UIActionSheetDelegate>
{
    IBOutlet UIImageView *imgViewMain,*imgViewMask;
    
    IBOutlet UIView *viewBoardBackground,*viewDrawingBoard;
    
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UISlider *sliderRed,*sliderGreen,*sliderBlue,*sliderIntensity;
    
    IBOutlet UIScrollView *scroll_view;
    
    BOOL isMaskOff,inverseMask;
    
    AppDelegate *appDel;
}

@property (nonatomic,retain) id<ChromeDelegate> delegate;

@property (nonatomic,retain) UIImage *imgSelected;

-(IBAction)cancelAction:(id)sender;
-(IBAction)maskAction:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
