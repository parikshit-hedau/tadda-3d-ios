//
//  EditPhotoViewController.m
//  Testing
//
//  Created by Parikshit Hedau on 25/11/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "EditPhotoViewController.h"

@interface EditPhotoViewController ()

@end

@implementation EditPhotoViewController

@synthesize imgSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Edit Photo";
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //@"Exposure",@"Pixellate",@"False Color",@"Shadow"
    
    arrFilters = [[NSArray alloc] initWithObjects:@"Adjust",@"Sharpness",@"Filters",@"Posterize",@"Sepia",@"Chrome", nil];
}

-(IBAction)backAction:(id)sender{
   
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)saveAction:(id)sender{
    
    UIImageWriteToSavedPhotosAlbum(self.imgSelected, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (!error) {
        
        [[[UIAlertView alloc] initWithTitle:@"Sucess!" message:@"Photo saved to library" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
     
        [[[UIAlertView alloc] initWithTitle:@"Failure!" message:@"Photo not saved to library" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return arrFilters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    NSString *strFilterName = [arrFilters objectAtIndex:indexPath.row];
    
    cell.textLabel.text = strFilterName;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *strFilterName = [arrFilters objectAtIndex:indexPath.row];
    
    if ([strFilterName isEqualToString:@"Adjust"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        AdjustFilterViewController *adjustFilterViewController = [storyBoard instantiateViewControllerWithIdentifier:@"adjustFilterViewController"];
        
        adjustFilterViewController.strFilterName = strFilterName;
        adjustFilterViewController.imgSelected = self.imgSelected;
        
        adjustFilterViewController.delegate = self;
        
        [self.navigationController pushViewController:adjustFilterViewController animated:YES];
    } 
    else if ([strFilterName isEqualToString:@"Sharpness"] || [strFilterName isEqualToString:@"Posterize"] || [strFilterName isEqualToString:@"Sepia"] || [strFilterName isEqualToString:@"Exposure"] || [strFilterName isEqualToString:@"Pixellate"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        SingleFilterViewController *singleFilterViewController = [storyBoard instantiateViewControllerWithIdentifier:@"singleFilterViewController"];
        
        singleFilterViewController.strFilterName = strFilterName;
        singleFilterViewController.imgSelected = self.imgSelected;
        
        singleFilterViewController.delegate = self;
        
        [self.navigationController pushViewController:singleFilterViewController animated:YES];
    }
    else if ([strFilterName isEqualToString:@"Filters"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        FiltersViewController *filtersViewController = [storyBoard instantiateViewControllerWithIdentifier:@"filtersViewController"];
        
        filtersViewController.imgSelected = self.imgSelected;
        
        filtersViewController.delegate = self;
        
        [self.navigationController pushViewController:filtersViewController animated:YES];
    }
    else if ([strFilterName isEqualToString:@"Chrome"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        ChromeViewController *chromeViewController = [storyBoard instantiateViewControllerWithIdentifier:@"chromeViewController"];
        
        chromeViewController.imgSelected = self.imgSelected;
        
        chromeViewController.delegate = self;
        
        [self.navigationController pushViewController:chromeViewController animated:YES];
    }
    else if ([strFilterName isEqualToString:@"Bloom"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        BloomViewController *bloomViewController = [storyBoard instantiateViewControllerWithIdentifier:@"bloomViewController"];
        
        bloomViewController.imgSelected = self.imgSelected;
        
        bloomViewController.delegate = self;
        
        [self.navigationController pushViewController:bloomViewController animated:YES];
    }
    else if ([strFilterName isEqualToString:@"False Color"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        FalseColorViewController *falseColorViewController = [storyBoard instantiateViewControllerWithIdentifier:@"falseColorViewController"];
        
        falseColorViewController.imgSelected = self.imgSelected;
        
        falseColorViewController.delegate = self;
        
        [self.navigationController pushViewController:falseColorViewController animated:YES];
    }
    else if ([strFilterName isEqualToString:@"Shadow"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:appDel.strStroryBoard bundle:nil];
        
        ShadowViewController *shadowViewController = [storyBoard instantiateViewControllerWithIdentifier:@"shadowViewController"];
        
        shadowViewController.imgSelected = self.imgSelected;
        
        shadowViewController.delegate = self;
        
        [self.navigationController pushViewController:shadowViewController animated:YES];
    }
}

#pragma mark -
#pragma mark Brightness Delegate Method

-(void)didFilter:(UIImage*)image{
    
    self.imgSelected = image;
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
