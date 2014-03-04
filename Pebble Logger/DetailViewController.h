//
//  DetailViewController.h
//  Pebble Logger
//
//  Created by Erik Risinger on 2/6/14.
//  Copyright (c) 2014 Erik Risinger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailViewControllerDelegate <NSObject>

-(void)didPressCancel;
-(void)didPressSave:(id)sender;

@end

@interface DetailViewController : UIViewController

@property (nonatomic, assign) id<DetailViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *log;

@property (strong, nonatomic) id detailItem;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;

@end
