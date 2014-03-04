//
//  MasterViewController.h
//  Pebble Logger
//
//  Created by Erik Risinger on 2/6/14.
//  Copyright (c) 2014 Erik Risinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>
#import "DetailViewController.h"
#import "PebbleLog.h"
#import <PebbleKit/PebbleKit.h>





@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, DetailViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *logs;
@property (nonatomic, strong) PBWatch *targetWatch;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)didPressCancel;
-(void)didPressSave:(id)sender;

-(IBAction)sendResults:(id)sender;
-(IBAction)deleteAll:(id)sender;

@end
