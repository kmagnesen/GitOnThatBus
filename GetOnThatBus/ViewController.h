//
//  ViewController.h
//  GetOnThatBus
//
//  Created by Kyle Magnesen on 1/20/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController

@property NSMutableArray *rowArray;
@property CLLocationManager *locationManager;
@property MKPointAnnotation *rowAnnotation;

@end

