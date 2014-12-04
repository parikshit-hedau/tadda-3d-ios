//
//  ViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 10/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "ViewController.h"

#import <math.h>

@interface ViewController ()

@end

@implementation ViewController

#define IMAGE_NAME @"IMG_0798.JPG"

#define BACK_COLOR [[UIColor greenColor] colorWithAlphaComponent:1.0]

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    brushSize = 30;
    
    paths = [[NSMutableArray alloc] init];
    
    arrUndo = [[NSMutableArray alloc] init];
    
    points = [[NSMutableArray alloc] init];
    
    imgSeleted = [UIImage imageNamed:IMAGE_NAME];
    
    //imgSeleted = [self imageByScalingAndCroppingForSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    imgSeleted = [self resizeImage:imgSeleted resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    NSLog(@"img selected size = %@",NSStringFromCGSize(imgSeleted.size));
    
    imgView.image = imgSeleted;
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    imgView.frame = CGRectMake(0, 0, imgSeleted.size.width, imgSeleted.size.height);
    
    imgView.center = self.view.center;
    
    imgViewOverlay.frame = imgView.frame;
    
    imgViewDrawing.frame = imgView.frame;
    
    imgViewOverlay.alpha = 0.5;
    
    imgViewDrawing.alpha = 0.5;
    
    NSLog(@"imgview frame = %@ and imgviewoverlay=%@",NSStringFromCGRect(imgView.frame),NSStringFromCGRect(imgViewOverlay.frame));
    
    viewBrush = [[UIView alloc] initWithFrame:CGRectMake(0, 0, brushSize, brushSize)];
    viewBrush.layer.cornerRadius = brushSize/2;
    viewBrush.layer.borderColor = [UIColor whiteColor].CGColor;
    viewBrush.layer.borderWidth = 0.5;
    viewBrush.layer.masksToBounds = YES;
    
    [self.view addSubview:viewBrush];
    viewBrush.center = self.view.center;
    viewBrush.backgroundColor = BACK_COLOR;
    
    viewBrush.hidden = YES;
    
    sliderBlur.hidden = YES;
    
    lblSliderValue.hidden = YES;
    
    lblSliderValue.backgroundColor = [UIColor clearColor];
    
    lblSliderValue.textColor = [UIColor whiteColor];
    
    [sliderBlur addTarget:self action:@selector(sliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderBlur addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [sliderZoom addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    lblSliderValue.textColor = [UIColor blueColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    isAutoDetectOn = YES;
    
    btnAutoDetect.tintColor = [UIColor greenColor];
    
    
    btnRedo.enabled = NO;
    
    
    isDrawingEnable = YES;
    
    btnDrawingOnOff.tintColor = [UIColor greenColor];
    
    
//    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//    
//    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    
    scroll_view.minimumZoomScale = 1.0;
    scroll_view.maximumZoomScale = 4.0;
    
    scroll_view.userInteractionEnabled = NO;
    
    sliderZoom.hidden = YES;
    
    sliderZoom.minimumValue = 1.0;
    sliderZoom.maximumValue = scroll_view.maximumZoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return viewBoard;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
    NSLog(@"begining fraem =  %@",NSStringFromCGRect(view.frame));
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    NSLog(@"after frame = %@",NSStringFromCGRect(view.frame));
    
    NSLog(@"scale = %f",scale);
    
    sliderZoom.value = scale;
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    NSLog(@"scale = %f",scale);
    
    CGAffineTransform currentTransform = imgView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [imgView setTransform:newTransform];
    [imgViewDrawing setTransform:newTransform];
    [imgViewOverlay setTransform:newTransform];
    
    lastScale = [(UIPinchGestureRecognizer*)sender scale];
    
    NSLog(@"imgView frame = %@",NSStringFromCGRect(imgView.frame));
    
    CGRect rect = CGRectMake(0.0, 0.0, imgView.frame.size.width, imgView.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [imgSeleted drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    rect = CGRectMake(0.0, 0.0, imgView.frame.size.width, imgView.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [imgMasked drawInRect:rect];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    imgViewOverlay.image = img;
    
    NSLog(@"image size = %@",NSStringFromCGSize(imgView.image.size));
}

-(void)move:(id)sender {
 
    CGPoint translatedPoint = [panGesture translationInView:self.view];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [imgView center].x;
        firstY = [imgView center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [imgView setCenter:translatedPoint];
    [imgViewOverlay setCenter:translatedPoint];
    [imgViewDrawing setCenter:translatedPoint];
}

-(IBAction)drawingOnOffAction:(id)sender{
    
    if (isDrawingEnable) {
        
        isDrawingEnable = NO;
        
        [btnDrawingOnOff setTitle:@"Drawing Off" forState:UIControlStateNormal];
        
        btnDrawingOnOff.tintColor = [UIColor redColor];
        
        scroll_view.userInteractionEnabled = YES;
        
        sliderZoom.hidden = NO;
    }
    else{
        
        isDrawingEnable = YES;
        
        [btnDrawingOnOff setTitle:@"Drawing On" forState:UIControlStateNormal];
        
        btnDrawingOnOff.tintColor = [UIColor greenColor];
        
        scroll_view.userInteractionEnabled = NO;
        
        sliderZoom.hidden = YES;
    }
}

-(IBAction)autoDetectOnOffAction:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    
    if (isAutoDetectOn) {
        
        [btn setTitle:@"Auto Detect Off" forState:UIControlStateNormal];
        
        btn.tintColor = [UIColor redColor];
        
        isAutoDetectOn = NO;
    }
    else{
        
        [btn setTitle:@"Auto Detect On" forState:UIControlStateNormal];
        
        btn.tintColor = [UIColor greenColor];
        
        isAutoDetectOn = YES;
    }
}

-(IBAction)selectPhotoFromLibrary:(id)sender{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"info = %@",info);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    imgSeleted = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    imgSeleted = [self resizeImage:imgSeleted resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    imgView.frame = CGRectMake(0, 0, imgSeleted.size.width, imgSeleted.size.height);
    
    imgView.center = self.view.center;
    
    imgViewOverlay.frame = imgView.frame;
    
    imgViewDrawing.frame = imgView.frame;
    
    [self resetAction:nil];
}

-(IBAction)hideImageViewAction:(id)sender{
    
    if (imgView.hidden) {
        
        imgView.hidden = NO;
    }
    else{
        
        imgView.hidden = YES;
    }
}

-(UIImage *) resizeImage:(UIImage *)image resizeSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    
    float scale = actualWidth/size.width;
    
    float scaleHeight = actualHeight/scale;
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, scaleHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

-(UIColor *)colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel,1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [imgView.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0
                                     green:pixel[1]/255.0 blue:pixel[2]/255.0
                                     alpha:pixel[3]/255.0];
    
    colorSelected = color;
    
    R = pixel[0];
    G = pixel[1];
    B = pixel[2];
    
    NSLog(@"R=%d G=%d B=%d",R,G,B);
    
    return color;
}

-(IBAction)undoAction:(id)sender{
    
    if (paths.count) {
        
        [arrUndo addObject:[paths lastObject]];
        
        [paths removeLastObject];
        
        UIImage *img = [self reDrawImage];
        
        imgViewOverlay.image = img;
        
        btnRedo.enabled = YES;
    }
}

-(IBAction)redoAction:(id)sender{
    
    if (arrUndo.count) {
        
        [paths addObject:[arrUndo firstObject]];
        
        [arrUndo removeObjectAtIndex:0];
        
        UIImage *img = [self reDrawImage];
        
        imgViewOverlay.image = img;
        
        btnRedo.enabled = NO;
    }
}

-(void)sliderValueChanged:(UISlider*)slider{
    
    if (sliderBlur == slider) {
        
        NSLog(@"%f",sliderBlur.value);
        
        lblSliderValue.text = [NSString stringWithFormat:@"%.1f",sliderBlur.value];
        
        return;
    }
    if (sliderZoom == slider) {
        
        scroll_view.zoomScale = sliderZoom.value;
        
        return;
    }
}

-(void)sliderTouchEnd{
    
    NSLog(@"sliderValueChanged");
    
    NSLog(@"%f",sliderBlur.value);
    
    lblSliderValue.text = [NSString stringWithFormat:@"%.1f",sliderBlur.value];
    
    [self addBlurEffect];
}

-(IBAction)cropAction:(id)sender{
    
    sliderBlur.value = 0.0;
    sliderBlur.hidden = NO;
    
    lblSliderValue.text = [NSString stringWithFormat:@"%.1f",sliderBlur.value];
    lblSliderValue.hidden = NO;
    
    btnDone.enabled = NO;
    btnBrush.enabled = NO;
    
    isRubber = NO;
    
    btnBrush.tag = 0;
    
    [btnBrush setTitle:@"Rubber" forState:UIControlStateNormal];
}

-(void)addBlurEffect{
    
    self.view.userInteractionEnabled = NO;
    
    imgMasked = [self maskImage:imgSeleted withMask:imgViewOverlay.image];
    
    NSLog(@"copped size = %@",NSStringFromCGSize(imgMasked.size));
    
    //imgView.image = [self blurImageInImageView:imgSeleted];
    
    imgView.image = [self gaussBlur:sliderBlur.value withImage:imgSeleted];
    
    imgViewOverlay.image = imgMasked;
    
    self.view.userInteractionEnabled = YES;
}

-(IBAction)resetAction:(id)sender{
    
    lblSliderValue.hidden = YES;
    sliderBlur.hidden = YES;
    
    imgView.image = imgSeleted;
    
    imgViewOverlay.image = nil;
    
    imgViewOverlay.hidden = NO;
    
    btnDone.enabled = YES;
    btnBrush.enabled = YES;
    
    [paths removeAllObjects];
    
    [arrUndo removeAllObjects];
    
    imgView.hidden = NO;
    
    [points removeAllObjects];
    
    isRubber = NO;
    
    btnBrush.tag = 0;
    
    [btnBrush setTitle:@"Rubber" forState:UIControlStateNormal];
    
    imgMasked = nil;
    
    [paths removeAllObjects];
    
    scroll_view.zoomScale = 0.0;
    
    sliderZoom.value = 0.0;
}

-(IBAction)rubberAction:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    
    if (btn.tag == 0) {
        
        isRubber = YES;
        
        btn.tag = 1;
        
        [btn setTitle:@"Pen" forState:UIControlStateNormal];
    }
    else{
        
        isRubber = NO;
        
        btn.tag = 0;
        
        [btn setTitle:@"Rubber" forState:UIControlStateNormal];
    }
}

-(UIImage*)getImageFromContext{
    
    UIImageView *imgViewTemp = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    CGColorRef strokeColor = [UIColor greenColor].CGColor;
    
    UIGraphicsBeginImageContext(imgViewOverlay.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), strokeColor);
    
    CGContextSetFillColorWithColor(context, strokeColor);
    
    [imgViewTemp.image drawInRect:CGRectMake(0, 0, imgViewTemp.frame.size.width, imgViewTemp.frame.size.height)];
    
    CGContextSaveGState(context);
    
    CGContextClearRect(context, imgViewTemp.bounds);
    
    for (NSDictionary *dict in paths) {
        
        UIBezierPath *aPath = [dict objectForKey:@"path"];
        
        if ([[dict objectForKey:@"isRubber"] isEqualToString:@"1"]) {
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
        }
        else{
            
            CGContextSetBlendMode(context, kCGBlendModeDarken);
        }
        
        CGContextAddPath(context, aPath.CGPath);
        
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

-(UIImage*)reDrawImage{
    
    CGColorRef strokeColor = BACK_COLOR.CGColor;
    
    UIGraphicsBeginImageContext(imgViewDrawing.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), strokeColor);
    
    CGContextSetFillColorWithColor(context, strokeColor);
    
    CGContextSaveGState(context);
    
    CGContextClearRect(context, imgViewDrawing.bounds);
    
    for (BezierPathCustome *aPath in paths) {
        
        if (aPath.isClear) {
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
        }
        else{
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
        }
        
        CGContextAddPath(context, aPath.CGPath);
        
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!isDrawingEnable) {
        
        return;
    }
    
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:self.view];
    
    if (scroll_view.zoomScale == 1.0) {
        
        if (!CGRectContainsPoint(imgView.frame, lastTouch)) {
            
            return;
        }
    }
    
    viewBrush.center = CGPointMake(lastTouch.x - brushSize/3, lastTouch.y - brushSize/5);
    
    viewBrush.hidden = NO;
    
    bezierPath = [[BezierPathCustome alloc] init];
    
    CGPoint drawingPoint = [touch locationInView:imgView];
    
    colorSelected = [self colorOfPoint:drawingPoint];
    
    NSLog(@"color = %@",colorSelected);
}

-(NSArray*)getPointsFromImage:(UIImage*)image byMatchingRed:(int)red gree:(int)green blue:(int)blue{
    
    NSMutableArray *arrPoints = [[NSMutableArray alloc] init];
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0,0,width,height),imageRef);
    CGContextRelease(context);
    
    for(int y = 0; y < height; y++) {
        
        for(int x = 0; x < width; x++) {
            
            int long index = 4*((width*y)+x);
            int R1 = rawData[index];
            int G1 = rawData[index+1];
            int B1 = rawData[index+2];
            
            int difference = sqrt((red - R1)*(red - R1) + (green - G1)*(green - G1) + (blue - B1)*(blue - B1));
            
            if (difference  < 90 && [bezierPath containsPoint:CGPointMake(x, y)]) {
                
                CGPoint point = CGPointMake(x, y);
                
                NSString *strPoint = NSStringFromCGPoint(point);
                
                if (strPoint) {
                    
                    [arrPoints addObject:strPoint];
                }
            }
        }
    }
    
    free(rawData);
    
    return arrPoints;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!isDrawingEnable) {
    
        return;
    }
    
    if (!colorSelected) {
        
        return;
    }
    
    if (isRubber) {
        
        viewBrush.backgroundColor = [UIColor redColor];
        
        bezierPath.isClear = YES;
    }
    else{
        
        viewBrush.backgroundColor = BACK_COLOR;
        
        bezierPath.isClear = NO;
    }
    
    UITouch *touch = [touches anyObject];
    currentTouch = [touch locationInView:self.view];
    
    if (scroll_view.zoomScale == 1.0) {
        
        if (!CGRectContainsPoint(imgView.frame, currentTouch)) {
            
            return;
        }
    }
    
    CGPoint drawingPoint = [touch locationInView:imgView];
    
    viewBrush.center = CGPointMake(currentTouch.x - brushSize/3, currentTouch.y - brushSize/5);;
    
    CGColorRef strokeColor = viewBrush.backgroundColor.CGColor;
    
    if (isRubber) {
        
        strokeColor = [UIColor redColor].CGColor;
    }
    
    UIGraphicsBeginImageContext(imgViewDrawing.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, strokeColor);
    
    [imgViewDrawing.image drawInRect:CGRectMake(0, 0, imgViewDrawing.frame.size.width, imgViewDrawing.frame.size.height)];
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    CGContextSaveGState(context);
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(drawingPoint.x - brushSize/2 - brushSize/3, drawingPoint.y - brushSize/2 - brushSize/5, brushSize, brushSize)];
    
    [bezierPath appendPath:aPath];
    
    CGContextAddPath(context, aPath.CGPath);
    
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    imgViewDrawing.image = img;
    
    UIGraphicsEndImageContext();
    
    lastTouch = [touch locationInView:imgViewDrawing];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    lastTouch = [touch locationInView:imgView];
    
    viewBrush.hidden = YES;
    
    NSLog(@"ended");
    
    //NSLog(@"info %@",imgViewOverlay.image.CIImage.properties);
    
    //imgView.hidden = YES;
    
    if (!isDrawingEnable) {
        
        return;
    }
    
    if (colorSelected) {
        
        if (!bezierPath.isEmpty) {
            
            if (isAutoDetectOn) {
                
                imgViewDrawing.alpha = 1.0;
                
                UIImage *img = [self maskImage:imgSeleted withMask:imgViewDrawing.image];
                
                NSArray *arrPoints = [self getPointsFromImage:img byMatchingRed:R gree:G blue:B];
                
                BezierPathCustome *aPath = [self getBezierPathFromPoints:arrPoints];
                
                [self drawPathOnOverlay:aPath];
                
                if (aPath) {
                    
                    [paths addObject:aPath];
                }
                
                imgViewDrawing.alpha = 0.5;
            }
            else{
                
                NSLog(@"is empty = %@",bezierPath.isEmpty?@"Yes":@"No");
                
                if (bezierPath) {
                    
                    [paths addObject:bezierPath];
                }
                
                [self drawPathOnOverlay:bezierPath];
            }
            
            [arrUndo removeAllObjects];
            
            btnRedo.enabled = NO;
            
            imgMasked = imgViewOverlay.image;
        }
    }
    
    imgViewDrawing.image = nil;
    
    colorSelected = nil;
    
    [points removeAllObjects];
}

-(void)drawPathOnOverlay:(BezierPathCustome*)aPath{
    
    imgViewOverlay.alpha = 1.0;
    
    CGColorRef strokeColor = BACK_COLOR.CGColor;
    
    UIGraphicsBeginImageContext(imgViewOverlay.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [imgViewOverlay.image drawInRect:imgViewOverlay.bounds];
    
    if (aPath.isClear) {
        
        CGContextSetBlendMode(context, kCGBlendModeClear);        
    }
    else{
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
    }
    
    CGContextSetFillColorWithColor(context, strokeColor);
    CGContextSetStrokeColorWithColor(context, strokeColor);

    CGContextSaveGState(context);
  
    CGContextAddPath(context, aPath.CGPath);
        
    CGContextFillPath(context);
    
    //CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    imgViewOverlay.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    imgViewOverlay.alpha = 0.5;
}

-(void)clearPathFromOverlay{
    
    CGColorRef strokeColor = [UIColor clearColor].CGColor;
    
    UIGraphicsBeginImageContext(imgViewOverlay.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [imgViewOverlay.layer renderInContext:context];
    
    CGContextSetFillColorWithColor(context, strokeColor);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextSaveGState(context);
    
    CGContextAddPath(context, bezierPath.CGPath);
        
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    imgViewOverlay.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

-(BezierPathCustome*)getBezierPathFromPoints:(NSArray*)arrPoints{
    
    if (!arrPoints.count) {
        
        return nil;
    }

    BezierPathCustome *path = [[BezierPathCustome alloc] init];
    
    if (isRubber) {
        
        path.isClear = YES;
    }
    else{
        
        path.isClear = NO;
    }
    
    for (int i=0; i < arrPoints.count; i++)
    {
        NSString *strPoint = [arrPoints objectAtIndex:i];
        
        CGPoint point = CGPointFromString(strPoint);
        
        //UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x, point.y, 3, 3)];
        
        UIBezierPath *aPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x-1.5, point.y-1.5, 3, 3) cornerRadius:1.5];
        
        [path appendPath:aPath];
    }
    
//    imgViewOverlay.image = imgMasked;
//    
//    CGColorRef strokeColor = BACK_COLOR.CGColor;
//    
//    UIGraphicsBeginImageContext(imgViewOverlay.frame.size);
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    [imgViewOverlay.layer renderInContext:context];
//    
//    CGContextSetStrokeColorWithColor(context, strokeColor);
//    
//    CGContextSetFillColorWithColor(context, strokeColor);
//    
//    CGContextSetBlendMode(context, kCGBlendModeCopy);
//    
//    CGContextSaveGState(context);
//    
//    
//    
//    CGContextRestoreGState(context);
//    
//    imgViewOverlay.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    NSLog(@"drawing done");
    
    return path;
}

- (UIImage *)blurImageInImageView: (UIImage*)img
{
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[img CGImage]] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat:sliderBlur.value] forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect rect = [outputImage extent];
    
    rect = imgView.bounds;
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:rect];
    UIImage *blurredImage = [UIImage imageWithCGImage:cgimg];
    return blurredImage;
}
 
- (UIImage *)imageWithGaussianBlur9:(UIImage*)img {
    
    float weight[5] = {0.1270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
    // Blur horizontally
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height) blendMode:kCGBlendModeNormal alpha:weight[0]];
    for (int x = 1; x < 5; ++x) {
        [img drawInRect:CGRectMake(x, 0, img.size.width, img.size.height) blendMode:kCGBlendModeNormal alpha:weight[x]];
        [img drawInRect:CGRectMake(-x, 0, img.size.width, img.size.height) blendMode:kCGBlendModeNormal alpha:weight[x]];
    }
    UIImage *horizBlurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Blur vertically
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    [horizBlurredImage drawInRect:CGRectMake(0, 0, img.size.width, img.size.height) blendMode:kCGBlendModeNormal alpha:weight[0]];
    for (int y = 1; y < 5; ++y) {
        [horizBlurredImage drawInRect:CGRectMake(0, y, img.size.width, img.size.height) blendMode:kCGBlendModeDarken alpha:weight[y]];
        [horizBlurredImage drawInRect:CGRectMake(0, -y, img.size.width, img.size.height) blendMode:kCGBlendModeDarken alpha:weight[y]];
    }
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return blurredImage;
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat:sliderBlur.value] forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = imgSeleted;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef maskImageRef = [maskImage CGImage];
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat ratio = 0;
    
    ratio = maskImage.size.width/ image.size.width;
    
    if(ratio * image.size.height < maskImage.size.height) {
        ratio = maskImage.size.height/ image.size.height;
    }
    
    CGRect rect1  = {{0, 0}, {maskImage.size.width, maskImage.size.height}};
    CGRect rect2  = {{-((image.size.width*ratio)-maskImage.size.width)/2 , -((image.size.height*ratio)-maskImage.size.height)/2}, {image.size.width*ratio, image.size.height*ratio}};
    
    CGContextSetBlendMode(mainViewContentContext, kCGBlendModeSourceOut);
    
    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    CGContextDrawImage(mainViewContentContext, rect2, image.CGImage);
    
    
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
}

-(UIImage *)smoothImage:(UIImage *)input{
    
    CIContext *context_ = [CIContext contextWithOptions:nil];
    
    UIImage *defaultImage_=input;
    
    CIImage *inputImage = [CIImage imageWithCGImage:[defaultImage_ CGImage]];
    
    //Apply CIBloom that makes soft edges and adds glow to image
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithDouble:6.0] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context_ createCGImage:result fromRect:[result extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return resultImage;
    
}

- (UIImage*)applyEffectBloom:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    CGFloat R = 0.5 * MIN(image.size.width, image.size.height) * 0.05;
    [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:0.5] forKey:@"inputIntensity"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    CGFloat dW = (result.size.width - image.size.width)/2;
    CGFloat dH = (result.size.height - image.size.height)/2;
    
    CGRect rct = CGRectMake(dW, dH, image.size.width, image.size.height);
    
    return [self crop:rct  withImage:result];;
}

- (UIImage*)applyEffectGloom:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIGloom" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    CGFloat R = 0.4 * MIN(image.size.width, image.size.height) * 0.05;
    [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:0.4] forKey:@"inputIntensity"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    CGFloat dW = (result.size.width - image.size.width)/2;
    CGFloat dH = (result.size.height - image.size.height)/2;
    
    CGRect rct = CGRectMake(dW, dH, image.size.width, image.size.height);
    
    return [self crop:rct  withImage:result];
}

- (UIImage*)crop:(CGRect)rect withImage:(UIImage*)image
{
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    
    UIImage *img = nil;
    
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [image drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage*)gaussBlur:(CGFloat)blurLevel withImage:(UIImage*)image
{
    blurLevel = MIN(1.0, MAX(0.0, blurLevel));
    
    int boxSize = (int)(blurLevel * 0.1 * MIN(image.size.width, image.size.height));
    boxSize = boxSize - (boxSize % 2) + 1;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    UIImage *tmpImage = [UIImage imageWithData:imageData];
    
    CGImageRef img = tmpImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    NSInteger windowR = boxSize/2;
    CGFloat sig2 = windowR / 3.0;
    if(windowR>0){ sig2 = -1/(2*sig2*sig2); }
    
    int16_t *kernel = (int16_t*)malloc(boxSize*sizeof(int16_t));
    int32_t  sum = 0;
    for(NSInteger i=0; i<boxSize; ++i){
        kernel[i] = 255*exp(sig2*(i-windowR)*(i-windowR));
        sum += kernel[i];
    }
    
    // convolution
    error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, kernel, boxSize, 1, sum, NULL, kvImageEdgeExtend);
    error = vImageConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, kernel, 1, boxSize, sum, NULL, kvImageEdgeExtend);
    outBuffer = inBuffer;
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
