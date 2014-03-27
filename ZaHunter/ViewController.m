//
//  ViewController.m
//  ZaHunter
//
//  Created by Aaron Dufall on 26/03/2014.
//  Copyright (c) 2014 Aaron Dufall. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.myLabel.text = @"Location found. Reverse Geocoding";
            [self startReverseGeocoding:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}


-(void)startReverseGeocoding:(CLLocation *)location

{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//        self.myLabel.text = [NSString stringWithFormat:@"%@", placemarks.firstObject];
        [self findTheZa:placemarks forLocation:location];
    }];
    //    NSLog(@"%@", location);
}

-(void)findTheZa:(NSArray *)placemarks forLocation:(CLLocation *)location
{
    self.title = @"Get Your Za!";
    
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.2, 0.2));
    
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        NSMutableString *zaNames = [NSMutableString new];
        
        for (int i = 0; i < 4; i++) {
            MKMapItem *mapItem = mapItems[i];
            NSLog(@"%@", mapItem.name);
    
            CLLocationDistance distance = [mapItem.placemark.location distanceFromLocation:location];
            [zaNames appendFormat:@"%d: %@ %0.2f km\n", i+1, mapItem.name, distance / 1000];
        }
        self.myLabel.text = zaNames;
    }];
}

- (IBAction)findSomeZa:(id)sender {
    [self.locationManager startUpdatingLocation];
}

@end
