//
//  ViewController.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager();
    var currentLocation: CLLocation?;

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load");
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.distanceFilter = 5;
        
        locationManager.requestWhenInUseAuthorization();
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.delegate = self;
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            print("denied")
//            goJustDefaultTempLocation();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
//            goJustDefaultTempLocation();
            
            return;
        }
        
        currentLocation = location;
        
        print("locationManager", location.coordinate.longitude, location.coordinate.latitude );
        
        //        getGridModelByLonLat( lon: location.coordinate.longitude, lat: location.coordinate.latitude );
    }
}

