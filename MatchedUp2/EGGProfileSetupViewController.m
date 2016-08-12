//
//  EGGProfileSetupViewController.m
//  MatchedUp2
//
//  Created by Edu González on 27/5/15.
//  Copyright (c) 2015 Edu González. All rights reserved.
//

#import "EGGProfileSetupViewController.h"

@interface EGGProfileSetupViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *pictureProfileImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation EGGProfileSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
