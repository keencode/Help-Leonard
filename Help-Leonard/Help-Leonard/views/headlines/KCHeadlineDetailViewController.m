//
//  KCHeadlineDetailViewController.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "KCHeadlineDetailViewController.h"

@interface KCHeadlineDetailViewController ()

@end

@implementation KCHeadlineDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	NSString *content = [NSString stringWithFormat:@"<h1>%@</h1><p>%@</p>", self.headline.headline, self.headline.ddescription];
    [self.webView loadHTMLString:content baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
