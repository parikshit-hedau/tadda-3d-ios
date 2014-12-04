//
//  FilterViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CreateMaskViewController.h"

#import "AppDelegate.h"

@protocol SingleDelegate <NSObject>

-(void)didFilter:(UIImage*)image;

@end

@interface SingleFilterViewController : UIViewController <MaskingDelegate,UIActionSheetDelegate>
{
    IBOutlet UIImageView *imgViewMain,*imgViewMask;
    
    IBOutlet UIView *viewBoardBackground,*viewDrawingBoard;
    
    IBOutlet UISlider *sliderFilter;
    
    IBOutlet UILabel *lblTitle;
        
    BOOL isMaskOff,inverseMask;
    
    AppDelegate *appDel;
}

@property (nonatomic,retain) id<SingleDelegate> delegate;

@property (nonatomic,retain) NSString *strFilterName;

@property (nonatomic,retain) UIImage *imgSelected;

-(IBAction)cancelAction:(id)sender;
-(IBAction)maskAction:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
