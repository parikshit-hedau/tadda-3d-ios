//
//  EditPhotoViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "AdjustFilterViewController.h"
#import "SingleFilterViewController.h"
#import "FiltersViewController.h"
#import "ChromeViewController.h"
#import "BloomViewController.h"
#import "FalseColorViewController.h"
#import "ShadowViewController.h"

@interface EditPhotoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AdjustDelegate,SingleDelegate,FilterEffectDelegate,ChromeDelegate,BloomDelegate,FalseColorDelegate,ShadowDelegate>
{
    NSArray *arrFilters;
    
    AppDelegate *appDel;
}

@property (nonatomic,retain) UIImage *imgSelected;

-(IBAction)backAction:(id)sender;
-(IBAction)saveAction:(id)sender;

@end
