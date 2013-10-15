//
//  KCHeadlineDetailViewController.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Headline.h"

@interface KCHeadlineDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) Headline *headline;

- (IBAction)tweetButtonClicked:(id)sender;

@end
