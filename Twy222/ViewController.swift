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
    
    var dateLastCalled:Date?;
    let LIMIT_INTERVAL_MINUTES_TO_CALL:Int = 5;
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            return;
        }
        
        currentLocation = location;
//        print("locationManager", location.coordinate.longitude, location.coordinate.latitude );
        
        tryStartToApiCall();
    }
    
    func tryStartToApiCall() {
        let now: Date = Date();
        
        if( dateLastCalled != nil) {
            let componenets = Calendar.current.dateComponents([.minute], from: dateLastCalled!, to: now);
            
            if( componenets.minute ?? 0 < LIMIT_INTERVAL_MINUTES_TO_CALL ) {
//                print("기존에 콜 한지 xx분도 안됨, 아무것도 안함")
                return;
            }
        }
        
        dateLastCalled = now;
        
        getGridModelByLonLat( lon: currentLocation!.coordinate.longitude, lat: currentLocation!.coordinate.latitude, dateNow: now );
    }
    
    func getGridModelByLonLat( lon: Double, lat: Double, dateNow: Date ) {
        KakaoApiService.shared.getGridModel(lon: lon, lat: lat) { ( model: GridModel? ) in
            if( model == nil ) {
                return;
            }
            
            GridManager.shared.setCurrentGridModel( gridModel: model! );

            let result = FronteerKr.convertGRID_GPS( toGrid: true, lat_X: lat, lng_Y: lon );
            
            let kmaX = result.x;
            let kmaY = result.y;
            // 기상청 기준 좌표 :  62, 122

            self.getNowModel(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY);
        }
    }
    
    func getNowModel( dateNow: Date, kmaX: Int, kmaY: Int ) {
        KmaApiService.shared.getNowModel( dateNow: dateNow, kmaX: kmaX, kmaY: kmaY ) { ( model: WeatherHourlyModel? ) in
            if( model == nil ) {
                return;
            }
            
            print( "got now model" );
        }
    }
}

