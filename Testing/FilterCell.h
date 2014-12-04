//
//  FilterCell.h
//  Testing
//
//  Created by Parikshit Hedau on 01/12/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCell : UICollectionViewCell
{
    IBOutlet UIImageView *imgViewThumb;
    IBOutlet UILabel *labelFilterName;    
}

@property (nonatomic,retain) IBOutlet UILabel *labelFilterName;

-(void)startFilterWithImage:(UIImage*)image withFilterName:(NSString*)strFilter withName:(NSString*)strName;

@end
