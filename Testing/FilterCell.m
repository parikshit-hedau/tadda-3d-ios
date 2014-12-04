//
//  FilterCell.m
//  Testing
//
//  Created by Parikshit Hedau on 01/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

@synthesize labelFilterName;

-(void)startFilterWithImage:(UIImage*)image withFilterName:(NSString*)strFilter withName:(NSString*)strName{
    
    imgViewThumb.layer.masksToBounds = YES;
    
    imgViewThumb.image = image;
    
    if ([strFilter isEqualToString:@"None"]) {
        
        labelFilterName.text = @"None";
        
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:strFilter]) {
        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:strFilter];
        
        NSData *dataImage = [dict objectForKey:@"image"];
        
        if (!dataImage.length) {
            
            return;
        }
        
        UIImage *img = [UIImage imageWithData:dataImage];
        
        imgViewThumb.image = img;
        
        labelFilterName.text = strName;
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *img = [self filteredImage:image withFilterName:strFilter];
        
        NSData *data = UIImageJPEGRepresentation(img, 1.0);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            imgViewThumb.image = img;
            
            labelFilterName.text = strName;
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:data,@"image", nil] forKey:strFilter];
        });
    });
}

- (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end
