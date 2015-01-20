//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Kyle Magnesen on 1/20/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *mapListToggle;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *rowArray;
@property CLLocationManager *locationManager;
@property MKPointAnnotation *rowAnnotation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    MKCoordinateRegion chicago;
//    chicago.center.latitude = 41.8500300;
//    chicago.center.longitude = -87.6500500;
//    chicago.span.latitudeDelta = 0.15;
//    chicago.span.longitudeDelta = 0.15;
//    chicago = [self.mapView regionThatFits:chicago];
//    [self.mapView setRegion:chicago animated:YES];


//    self.locationManager = [[CLLocationManager alloc] init];
//    [self.locationManager requestWhenInUseAuthorization];
//    self.mapView.showsUserLocation = YES;

    NSURL *busAPI = [NSURL URLWithString:@"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    [self loadBusStopAIP:busAPI];
}

-(void)loadBusStopAIP:(NSURL *)apiURL {

    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         // put results in a dictionary
         NSDictionary *row = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&connectionError];
         self.rowArray = [row objectForKey:@"row"];
//         NSLog(@"%@", self.row) logging dictionary's arrays

         for (NSDictionary *row in self.rowArray) {

             float latitude = [[row objectForKey:@"latitude"]floatValue];
             float longitude = [[row objectForKey:@"longitude"]floatValue];

             self.rowAnnotation = [[MKPointAnnotation alloc] init];
             self.rowAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
             self.rowAnnotation.title = [row objectForKey:@"cta_stop_name"];
             self.rowAnnotation.subtitle = [row objectForKey:@"routes"];

             [self.mapView addAnnotation:self.rowAnnotation];
             [self.mapView reloadInputViews];
         }
     }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}

@end
