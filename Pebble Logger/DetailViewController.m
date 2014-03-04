//
//  DetailViewController.m
//  Pebble Logger
//
//  Created by Erik Risinger on 2/6/14.
//  Copyright (c) 2014 Erik Risinger. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

@synthesize log;

-(IBAction)cancel:(id)sender
{
    [self.delegate didPressCancel];
}

-(IBAction)save:(id)sender
{
    [self.delegate didPressSave:self];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
//
//    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
