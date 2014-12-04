//
//  HomeViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import "AppDelegate.h"

@interface HomeViewController : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    IBOutlet UIImageView *imgView;
    
    AppDelegate *appDel;
}

-(IBAction)photoAction:(id)sender;
-(IBAction)editAction:(id)sender;



@end
