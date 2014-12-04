//
//  CreateMaskViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "CreateMaskViewController.h"

@interface CreateMaskViewController ()

@end

@implementation CreateMaskViewController

@synthesize delegate;
@synthesize imgSelected,imgMaskToEdit;

#define BACK_COLOR [[UIColor greenColor] colorWithAlphaComponent:1.0]

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    viewBoard.tag = 200;
    
    brushSize = 30;
    
    paths = [[NSMutableArray alloc] init];
    
    arrUndo = [[NSMutableArray alloc] init];
    
    points = [[NSMutableArray alloc] init];
    
    // brush to draw
    viewBrush = [[UIView alloc] initWithFrame:CGRectMake(0, 0, brushSize, brushSize)];
    viewBrush.layer.cornerRadius = brushSize/2;
    viewBrush.layer.borderColor = [UIColor whiteColor].CGColor;
    viewBrush.layer.borderWidth = 0.5;
    viewBrush.layer.masksToBounds = YES;
    [self.view addSubview:viewBrush];
    viewBrush.center = self.view.center;
    viewBrush.backgroundColor = BACK_COLOR;
    viewBrush.hidden = YES;
    
    // auto detection
    isAutoDetectOn = YES;
    btnAutoDetect.tintColor = [UIColor greenColor];
    
    // drawing on off
    isDrawingEnable = YES;
    btnDrawingOnOff.tintColor = [UIColor greenColor];

    // setting frames
    scroll_view.frame = CGRectMake(scroll_view.frame.origin.x, scroll_view.frame.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 120 - 44);
    
    viewBoard.frame = CGRectMake((scroll_view.bounds.size.width-self.imgSelected.size.width)/2 , (scroll_view.bounds.size.height-self.imgSelected.size.height)/2, self.imgSelected.size.width, self.imgSelected.size.height);
    
    imgView.image = self.imgSelected;
    
    imgView.frame = viewBoard.bounds;
    
    imgViewOverlay.frame = imgView.bounds;
    
    imgViewDrawing.frame = imgView.bounds;
    
    imgViewOverlay.alpha = 0.5;
    
    imgViewDrawing.alpha = 0.5;
    
    NSLog(@"imgview frame = %@ and imgviewoverlay=%@",NSStringFromCGRect(imgView.frame),NSStringFromCGRect(imgViewOverlay.frame));
    
    // setting zoom scale
    scroll_view.minimumZoomScale = 1.0;
    scroll_view.maximumZoomScale = 4.0;
    
    scroll_view.userInteractionEnabled = NO;
    scroll_view.delegate = self;
    
    sliderZoom.hidden = YES;
    
    sliderZoom.minimumValue = 1.0;
    sliderZoom.maximumValue = scroll_view.maximumZoomScale;
    
    [sliderZoom addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.imgMaskToEdit) {
        
        imgViewOverlay.image = [self getImageFromMask];
    }
}

-(UIImage*)getImageFromMask{
    
    UIGraphicsBeginImageContext(self.imgSelected.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, BACK_COLOR.CGColor);
    
    CGContextFillRect(context, CGRectMake(0, 0, self.imgSelected.size.width, self.imgSelected.size.height));
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(context);
    
    UIImage *mask = [self maskImage:img withMask:self.imgMaskToEdit];
    
    return mask;
}

#pragma mark -
#pragma mark - ScrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return viewBoard;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    NSLog(@"after frame = %@",NSStringFromCGRect(view.frame));
    
    NSLog(@"scale = %f",scale);
    
    sliderZoom.value = scale;
}

#pragma mark -
#pragma mark - Drawing On Off Action

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

#pragma mark -
#pragma mark - Auto Detection On Off Action

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

#pragma mark -
#pragma mark - Undo - Redo Action

-(IBAction)undoRedoAction:(id)sender{
    
    if (arrUndo.count) {
        
        [paths addObject:[arrUndo firstObject]];
        
        [arrUndo removeObjectAtIndex:0];
        
        UIImage *img = [self reDrawImage];
        
        imgViewOverlay.image = img;
        
        [btnUndoRedo setTitle:@"Undo" forState:UIControlStateNormal];
    }
    else{
        
        if (paths.count) {
            
            [arrUndo addObject:[paths lastObject]];
            
            [paths removeLastObject];
            
            UIImage *img = [self reDrawImage];
            
            imgViewOverlay.image = img;
            
            [btnUndoRedo setTitle:@"Redo" forState:UIControlStateNormal];
        }
    }
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

#pragma mark -
#pragma mark Slider Valude Changed Action

-(void)sliderValueChanged:(UISlider*)slider{
    
    if (sliderZoom == slider) {
        
        scroll_view.zoomScale = sliderZoom.value;
        
        return;
    }
}

#pragma mark -
#pragma mark Done Action

-(IBAction)doneAction:(id)sender{
    
    UIImage *img = [self maskImage:self.imgSelected withMask:imgViewOverlay.image];
    
    [self.delegate didMaskingWithImage:img];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Reset Action

-(IBAction)resetAction:(id)sender{
    
    imgView.image = self.imgSelected;
    
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
    
    [self.delegate didMaskingWithImage:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Get Pen or Rubber Action

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

#pragma mark -
#pragma mark Touches Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!isDrawingEnable) {
        
        return;
    }
    
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:self.view];
    
    if (!CGRectContainsPoint(scroll_view.frame, lastTouch)) {
        
        return;
    }
    else{
        
        CGPoint drawingPoint = [touch locationInView:scroll_view];
        
        if (!CGRectContainsPoint(viewBoard.frame, drawingPoint)) {
            
            return;
        }
    }
    
//    if (scroll_view.zoomScale == 1.0) {
//        
//        if (!CGRectContainsPoint(imgView.frame, lastTouch)) {
//            
//            return;
//        }
//    }
    
    viewBrush.center = CGPointMake(lastTouch.x, lastTouch.y);
    
    viewBrush.hidden = NO;
    
    bezierPath = [[BezierPathCustome alloc] init];
    
    CGPoint drawingPoint = [touch locationInView:viewBoard];
    
    NSLog(@"drawingPoint=%@",NSStringFromCGPoint(drawingPoint));
    
    colorSelected = [self colorOfPoint:drawingPoint];
    
    if (isRubber) {
        
        if (isAutoDetectOn) {
            
            viewBrush.backgroundColor = [UIColor redColor];
        }
        else{
            
            viewBrush.backgroundColor = [UIColor clearColor];
        }
        
        bezierPath.isClear = YES;
    }
    else{
        
        viewBrush.backgroundColor = BACK_COLOR;
        
        bezierPath.isClear = NO;
    }
    
    [arrUndo removeAllObjects];
    
    [btnUndoRedo setTitle:@"Undo" forState:UIControlStateNormal];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!isDrawingEnable) {
        
        return;
    }
    
    if (!colorSelected) {
        
        return;
    }
    
    if (isRubber) {
        
        if (isAutoDetectOn) {
            
            viewBrush.backgroundColor = [UIColor redColor];
        }
        else{
            
            viewBrush.backgroundColor = [UIColor clearColor];
        }
        
        bezierPath.isClear = YES;
    }
    else{
        
        viewBrush.backgroundColor = BACK_COLOR;
        
        bezierPath.isClear = NO;
    }
    
    UITouch *touch = [touches anyObject];
    currentTouch = [touch locationInView:self.view];
    
    if (!CGRectContainsPoint(scroll_view.frame, currentTouch)) {
        
        return;
    }
    
    CGPoint drawingPoint = [touch locationInView:scroll_view];
    
    if (!CGRectContainsPoint(viewBoard.frame, drawingPoint)) {
        
        return;
    }
    
    drawingPoint = [touch locationInView:viewBoard];
    
    viewBrush.center = CGPointMake(currentTouch.x , currentTouch.y);;
    
    CGColorRef strokeColor = viewBrush.backgroundColor.CGColor;
    
    if (isRubber) {
        
        strokeColor = [UIColor redColor].CGColor;
    }
    
    UIGraphicsBeginImageContext(imgViewDrawing.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, strokeColor);
    
    if (isAutoDetectOn) {
        
        [imgViewDrawing.image drawInRect:CGRectMake(0, 0, imgViewDrawing.frame.size.width, imgViewDrawing.frame.size.height)];
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
    }
    else{
        
        [imgViewOverlay.image drawInRect:CGRectMake(0, 0, imgViewOverlay.frame.size.width, imgViewOverlay.frame.size.height)];
        
        if (isRubber) {
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
        }
        else{
            
            CGContextSetBlendMode(context, kCGBlendModeCopy);
        }
    }
    
    CGContextSaveGState(context);
    
    int width = brushSize/scroll_view.zoomScale;
    
    CGRect rect = CGRectMake(drawingPoint.x - width/2 , drawingPoint.y - width/2, width, width);
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    if (![bezierPath containsPoint:drawingPoint]) {
        
        [bezierPath appendPath:aPath];
    }
    
    CGContextAddPath(context, aPath.CGPath);
    
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    if (isAutoDetectOn) {
        
        imgViewDrawing.image = img;
    }
    else{
        
        imgViewOverlay.image = img;
    }
    
    UIGraphicsEndImageContext();
    
    lastTouch = [touch locationInView:imgViewDrawing];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    lastTouch = [touch locationInView:imgView];
    
    viewBrush.hidden = YES;
    
    NSLog(@"ended");
    
    if (!isDrawingEnable) {
        
        return;
    }
    
    NSLog(@"selected rect = %@",NSStringFromCGRect(bezierPath.bounds));
    
    if (colorSelected) {
        
        if (!bezierPath.isEmpty) {
            
            if (isAutoDetectOn) {
                
                imgViewDrawing.alpha = 1.0;
                
                UIImage *img = [self maskImage:self.imgSelected withMask:imgViewDrawing.image];
                
                imgViewDrawing.alpha = 0.5;
                
                imgViewDrawing.tag = 1;
                
                [self highlightDrawing];
                
                self.view.userInteractionEnabled = NO;
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    NSArray *arrPoints = [self getPointsFromImage:img byMatchingColor:colorSelected];
                    
                    BezierPathCustome *aPath = [self getBezierPathFromPoints:arrPoints];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [self drawPathOnOverlay:aPath];
                        
                        if (aPath) {
                            
                            [paths addObject:aPath];
                        }
                        
                        imgViewDrawing.tag = 100;
                        
                        imgViewDrawing.alpha = 0.5;
                        
                        imgViewDrawing.image = nil;
                        
                        self.view.userInteractionEnabled = YES;
                        
                        colorSelected = nil;
                    });
                });
            }
            else{
                
                NSLog(@"is empty = %@",bezierPath.isEmpty?@"Yes":@"No");
                
                if (bezierPath) {
                    
                    [paths addObject:bezierPath];
                }
                
                //[self drawPathOnOverlay:bezierPath];
                
                imgViewDrawing.image = nil;
            }
        }
        
        imgMasked = imgViewOverlay.image;
    }
}

#pragma mark -
#pragma mark Hight Light Drawing

-(void)highlightDrawing{
    
    if (imgViewDrawing.tag == 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            imgViewDrawing.alpha = 0.5;
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                if (imgViewDrawing.tag != 100) {
                    
                    imgViewDrawing.tag = 1;
                    
                    [self highlightDrawing];
                }
            }
        }];
    }
    if (imgViewDrawing.tag == 1) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            imgViewDrawing.alpha = 0.1;
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                if (imgViewDrawing.tag != 100) {
                    
                    imgViewDrawing.tag = 0;
                    
                    [self highlightDrawing];
                }
            }
        }];
    }
}

#pragma mark -
#pragma mark Draw Path on Overlay

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
    
    CGContextRestoreGState(context);
    
    imgViewOverlay.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    imgViewOverlay.alpha = 0.5;
}

#pragma mark -
#pragma mark Get BezierPath From Point

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
    
    return path;
}

#pragma mark -
#pragma mark Get Mask Image

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

#pragma mark -
#pragma mark - Get Color Of Point From Image Method

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
    
    //NSLog(@"R=%d G=%d B=%d",R,G,B);
    
    return color;
}

#pragma mark -
#pragma mark Get points by color Matching

-(NSArray*)getPointsFromImage:(UIImage*)image byMatchingColor:(UIColor*)color{
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    float rColor = components[0];
    float gColor = components[1];
    float bColor = components[2];
    float aColor = components[3];
    
    int red = rColor * 255;
    int green = gColor * 255;
    int blue = bColor * 255;
    int alpha = aColor * 255;
    
    NSMutableArray *arrPoints = [[NSMutableArray alloc] init];
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,bitsPerComponent, bytesPerRow, colorSpace,(CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0,0,width,height),imageRef);
    CGContextRelease(context);
    
    CGRect rect = bezierPath.bounds;
    
    NSLog(@"rect = %@",NSStringFromCGRect(rect));
    
    
    int yRect = rect.origin.y;
    int xRect = rect.origin.x;
    int widthRect = rect.size.width;
    int heightRect = rect.size.height;
    
//    for(int y = 0; y < height; y++) {
//        
//        for(int x = 0; x < width; x++) {
    
    for(int y = rect.origin.y; y < heightRect + yRect ; y++) {
        
        for( int x = rect.origin.x; x < widthRect + xRect; x++) {
    
            CGPoint point = CGPointMake(x, y);
            
            if (![bezierPath containsPoint:point]) {
                
                continue;
            }
            
            int long index = 4*((width*y)+x);
            
            int R1 = rawData[index];
            int G1 = rawData[index+1];
            int B1 = rawData[index+2];
            int A1 = rawData[index+3];
            
            //int difference = sqrt((red - R1)*(red - R1) + (green - G1)*(green - G1) + (blue - B1)*(blue - B1));
            
            //if (difference  < 90) {
            
            if ( abs((red-R1)*(red-R1)) < 50 && abs((green-G1)*(green-G1)) < 50 && abs((blue-B1)*(blue-B1)) < 50) {
                
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

-(BOOL)isColor:(UIColor*)color equalToColor:(UIColor*)colorToCompare{
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    float rColor = components[0];
    float gColor = components[1];
    float bColor = components[2];
    float aColor = components[3];
    
    int red = rColor * 255;
    int green = gColor * 255;
    int blue = bColor * 255;
    int alpha = aColor * 255;
    
    const CGFloat *components1 = CGColorGetComponents(colorToCompare.CGColor);
    
    rColor = components1[0];
    gColor = components1[1];
    bColor = components1[2];
    aColor = components1[3];
    
    int R1 = rColor * 255;
    int G1 = gColor * 255;
    int B1 = bColor * 255;
    int A1 = aColor * 255;
    
    int difference = sqrt((red - R1)*(red - R1) + (green - G1)*(green - G1) + (blue - B1)*(blue - B1)+(alpha - A1)*(alpha - A1));
    
    if (difference  < 90) {
        
        return YES;
    }
    
    return NO;
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
