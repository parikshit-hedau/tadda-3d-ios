//
//  ViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 10/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import <Accelerate/Accelerate.h>

#import "BezierPathCustome.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>
{
    IBOutlet UIImageView *imgView,*imgViewOverlay,*imgViewDrawing;
    
    IBOutlet UIView *viewOverloay;
    
    IBOutlet UIButton *btnBrush,*btnDone,*btnRedo;
    
    IBOutlet UISlider *sliderBlur;
    
    IBOutlet UILabel *lblSliderValue;
    
    IBOutlet UIButton *btnAutoDetect;
    
    IBOutlet UIButton *btnDrawingOnOff;
    
    IBOutlet UIScrollView *scroll_view;
    IBOutlet UIView *viewBoard;
    IBOutlet UISlider *sliderZoom;
    
    UIView *viewEraser,*viewBrush;
    
    NSMutableArray *paths,*arrUndo;
    
    CGPoint lastTouch,currentTouch;
    
    UIImage *imgSeleted,*imgMasked;
    
    BOOL isRubber;
    
    UIColor *colorSelected;
    
    int R,G,B;
    
    NSMutableArray *points;
    
    BezierPathCustome *bezierPath;
    
    BOOL isAutoDetectOn,isDrawingEnable;
    
    int brushSize;
    
    float lastScale,firstX,firstY;
    
    
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *panGesture;
}

-(IBAction)cropAction:(id)sender;
-(IBAction)resetAction:(id)sender;

-(IBAction)rubberAction:(id)sender;

-(IBAction)undoAction:(id)sender;
-(IBAction)redoAction:(id)sender;

-(IBAction)hideImageViewAction:(id)sender;

-(IBAction)selectPhotoFromLibrary:(id)sender;

-(IBAction)autoDetectOnOffAction:(id)sender;

-(IBAction)drawingOnOffAction:(id)sender;

@end

