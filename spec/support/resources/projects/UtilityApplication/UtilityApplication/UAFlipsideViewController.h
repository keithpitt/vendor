//
//  UAFlipsideViewController.h
//  UtilityApplication
//
//  Created by Keith Pitt on 1/11/11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UAFlipsideViewController;

@protocol UAFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(UAFlipsideViewController *)controller;
@end

@interface UAFlipsideViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <UAFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
