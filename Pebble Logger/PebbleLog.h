//
//  PebbleLog.h
//  Pebble Logger
//
//  Created by Erik Risinger on 2/15/14.
//  Copyright (c) 2014 Erik Risinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PebbleLog : NSManagedObject

@property (nonatomic, retain) NSNumber * timeStamp;
@property (nonatomic, retain) NSNumber * xLog;
@property (nonatomic, retain) NSNumber * yLog;
@property (nonatomic, retain) NSNumber * zLog;

@end
