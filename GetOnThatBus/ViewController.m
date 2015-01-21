//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Kyle Magnesen on 1/20/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *mapListToggle;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MKCoordinateRegion chicago;
    chicago.center.latitude = 41.850030;
    chicago.center.longitude = -87.640050;
    chicago.span.latitudeDelta = 0.115;
    chicago.span.longitudeDelta = 0.115;
    chicago = [self.mapView regionThatFits:chicago];
    [self.mapView setRegion:chicago animated:YES];

//    self.locationManager = [[CLLocationManager alloc] init];
//    [self.locationManager requestWhenInUseAuthorization];
//    self.mapView.showsUserLocation = YES;

    NSURL *busAPI = [NSURL URLWithString:@"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    [self loadBusStopAPI:busAPI];
}

-(void)loadBusStopAPI:(NSURL *)apiURL {

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

             self.rowAnnotation = [[MKPointAnnotation alloc] init];
             NSDictionary *location = [row objectForKey:@"location"];
             float latitude = [[location objectForKey:@"latitude"]floatValue];
             float longitude = [[location objectForKey:@"longitude"]floatValue];
             self.rowAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
             self.rowAnnotation.title = [row objectForKey:@"cta_stop_name"];
             self.rowAnnotation.subtitle = [row objectForKey:@"routes"];

             [self.mapView addAnnotation:self.rowAnnotation];
             [self.mapView reloadInputViews];
         }
     }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    NSLog(@"%f, %f, %f, %f",
//          mapView.region.center.latitude,
//          mapView.region.center.longitude,
//          mapView.region.span.latitudeDelta,
//          mapView.region.span.longitudeDelta);

    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"DetailsIphone" sender:view];
    NSURL *busAPI = [NSURL URLWithString:@"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    [self loadBusStopAPI:busAPI];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailsIphone"]) {
        DetailViewController *detailView = segue.destinationViewController;
        detailView.title = self.rowAnnotation.title;
    }
}

@end
