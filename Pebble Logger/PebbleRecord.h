//
//  PebbleRecord.h
//  Pebble Logger
//
//  Created by Erik Risinger on 2/16/14.
//  Copyright (c) 2014 Erik Risinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PebbleLog;

@interface PebbleRecord : NSManagedObject

@property (nonatomic, retain) PebbleLog *logs;

@end
