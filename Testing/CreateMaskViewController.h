//
//  CreateMaskViewController.h
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import <Accelerate/Accelerate.h>

#import "BezierPathCustome.h"

#import "ScrollViewCustom.h"

@protocol MaskingDelegate <NSObject>

-(void)didMaskingWithImage:(UIImage*)img;

@end

@interface CreateMaskViewController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIImageView *imgView,*imgViewOverlay,*imgViewDrawing;
    
    IBOutlet UIButton *btnBrush,*btnDone,*btnUndoRedo,*btnAutoDetect,*btnDrawingOnOff;
    
    IBOutlet ScrollViewCustom *scroll_view;
    IBOutlet UIView *viewBoard;
    IBOutlet UISlider *sliderZoom;
    
    UIView *viewEraser,*viewBrush;
    
    NSMutableArray *paths,*arrUndo;
    
    CGPoint lastTouch,currentTouch;
    
    UIImage *imgMasked;
    
    BOOL isRubber;
    
    UIColor *colorSelected;
    
    int R,G,B;
    
    NSMutableArray *points;
    
    BezierPathCustome *bezierPath;
    
    BOOL isAutoDetectOn,isDrawingEnable;
    
    int brushSize;
}

@property (nonatomic,retain) id<MaskingDelegate> delegate;

@property (nonatomic,retain) UIImage *imgSelected,*imgMaskToEdit;

-(IBAction)doneAction:(id)sender;

-(IBAction)resetAction:(id)sender;

-(IBAction)rubberAction:(id)sender;

-(IBAction)undoRedoAction:(id)sender;

-(IBAction)autoDetectOnOffAction:(id)sender;

-(IBAction)drawingOnOffAction:(id)sender;

@end
