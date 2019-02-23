//
//  ViewControllerCore.swift
//  Twy222
//
//  Created by Bonkook Koo on 03/02/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class ViewControllerCore: UIViewController, CLLocationManagerDelegate {
    let locationManager: CLLocationManager = CLLocationManager();
    var currentLocation: CLLocation?;
    
    var gridEntity: GridEntity?;
    
    var dateRegionLastCalled: Date?
    
    // 전체 다 한바퀴 돌아서 완료했는지 여부 체크를 위해.
    // 2가지 갈래가 있고, 결국 카운트가 2가 되면 다 완료 된 것임.
    var nApiGroupCompleteCount = 0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    func startLocationManager() {
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
            goJustTempLocation();
            
            AlertUtil.alert(vc: self, title: "위치 접근 허용 안함", message: "임시 장소 정보를 가져옵니다.\n설정에서 위치 접근을 허용해주세요.", buttonText: "확인", onSelect: nil);
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return;
        }
        
        currentLocation = location;
        
//        let lat = 37.749678;
//        let lon = -122.424215;
//        currentLocation = CLLocation(latitude: lat, longitude: lon);
        
        tryStartToApiCall();
    }
    
    func tryStartToApiCall() {
        let now: Date = Date();
        
        drawTodayText( date: now );
        
        if let dateLast = dateRegionLastCalled {
//            print("이전 콜 start 시간: \(DateUtil.getStringByDate(date: dateLast))")
            
            let componenets = Calendar.current.dateComponents([.minute], from: dateLast, to: now);
            
            if( componenets.minute! < Settings.LIMIT_INTERVAL_MINUTES_TO_CALL_REGION ) {
//                print("기존에 콜 한지 xx분도 안됨, 아무것도 안함")
                return;
            }
        }
        
        dateRegionLastCalled = now;
        
        nApiGroupCompleteCount = 0;
        
        print("호출 시작 \(DateUtil.getStringByDate(date: now))");
        
        CoreDataManager.shared.deleteAllInEntity(entityEnum: EntityEnum.Grid);
        
        let lat = currentLocation!.coordinate.latitude;
        let lon = currentLocation!.coordinate.longitude;
        
        gridEntity = GridEntity(context: getContext());
        gridEntity!.latitude = lat;
        gridEntity!.longitude = lon;
        gridEntity!.dateCalled = now;
        
        saveContext();
        
        getGridModelByLonLat( dateNow: now, lon: lon, lat: lat );
    }
    
    
    func getGridModelByLonLat( dateNow: Date, lon: Double, lat: Double ) {
        func onComplete( model: AddressEntity ) {
            gridEntity?.address = model;
            saveContext();
            
            drawAddress();
            
            getNowData(dateNow: dateNow);
            
            getAirData(dateNow: dateNow);
        }
        
        func onError( errorModel: ErrorModel ) {
            ErrorRecorder.shared.record();
//            AlertUtil.alert(vc: self, title: "error", message: "geo api error", buttonText: "확인", onSelect: nil);
            // 국내 지역이 아닌 경우 kakao api error
            let lat = 37.496066;
            let lon = 127.067405;
            
            nApiGroupCompleteCount = 0;
            
            CoreDataManager.shared.deleteAllInEntity(entityEnum: EntityEnum.Grid);
            
            gridEntity = GridEntity(context: getContext());
            gridEntity!.latitude = lat;
            gridEntity!.longitude = lon;
            gridEntity!.dateCalled = dateNow;
            
            saveContext();
            
            getGridModelByLonLat( dateNow: dateNow, lon: lon, lat: lat );
        }
        
        KakaoApiManager.shared.getAddressData(dateNow: dateNow, lat: lat, lon: lon, callbackComplete: onComplete, callbackError: onError);
    }
    
    func getNowData( dateNow: Date ) {
        func onComplete( model:NowEntity? ) {
            guard let modelNotNil = model else {
                return;
            }
            
            gridEntity!.now = modelNotNil;
            saveContext();
            
            drawNowData();
            
            if( AppManager.shared.isMainApp! ) {
                // 동시 콜 x, 순서대로 하겠다. 디버깅 편하게 하기 위해.
                getForecastHourlyData(dateNow: dateNow );
            } else {
                apiGroupComplete(dateNow: dateNow)
            }
        }
        
        func onError( errorModel: ErrorModel ) {
            ErrorRecorder.shared.record();
            AlertUtil.alert(vc: self, title: "error", message: "now api error", buttonText: "확인", onSelect: nil);
        }
        
        KmaApiManager.shared.getNowData(dateNow: dateNow, lat: gridEntity!.latitude, lon: gridEntity!.longitude, callbackComplete: onComplete, callbackError: onError );
    }
    
    func apiGroupComplete( dateNow: Date ) {
        nApiGroupCompleteCount += 1;
        
        if( nApiGroupCompleteCount > 1 ) {
            // 한 바퀴 완료.
            CoreDataManager.shared.makeCommonEntityAferApiComplete(dateComplete: dateNow, isMainApp: AppManager.shared.isMainApp!);
            saveContext();
        }
    }
    
    
    func getAirData( dateNow: Date ) {
        guard let address = gridEntity?.address else {
            ErrorRecorder.shared.record();
            return;
        }
        
        func onComplete( model: AirEntity ) {
            gridEntity?.air = model;
            saveContext();
            
            apiGroupComplete( dateNow: dateNow );
            
            drawAirData();
        }
        
        func onError( errorModel: ErrorModel ) {
            ErrorRecorder.shared.record();
            AlertUtil.alert(vc: self, title: "error", message: "air api error", buttonText: "확인", onSelect: nil);
        }
        
        AkApiManager.shared.getAirData(dateNow: dateNow, tmX: address.tmX, tmY: address.tmY, callbackComplete: onComplete, callbackError: onError);
    }
    
    func saveDailyModelToDaily( arrOrigin: [DailyModel] ) {
        var newDaily: DailyEntity;
        
        for origin in arrOrigin {
            newDaily = DailyEntity(context: getContext());
            
            newDaily.date = origin.date;
            newDaily.temperatureMax = origin.temperatureMax;
            newDaily.temperatureMin = origin.temperatureMin;
            newDaily.skyStatusImageName = origin.skyStatusImageName;
            newDaily.skyStatusText = origin.skyStatusText;
            
            gridEntity!.addToDaily(newDaily);
        }
    }
    
    func goJustTempLocation() {
        // gps 사용 못할 경우 임의의 장소의 정보를 가져온다 - 테스트로 대치동으로 하겠다.
        let lat = 37.496066;
        let lon = 127.067405;
        currentLocation = CLLocation(latitude: lat, longitude: lon);
        
        tryStartToApiCall();
    }
    
    // ====================================================================
    // override this.
    // ====================================================================
    
    func getForecastHourlyData( dateNow: Date ) {
    }
    
    func drawTodayText( date: Date ) {
        
    }
    func drawAddress() {
        
    }
    func drawAirData() {
        
    }
    func drawNowData() {
        
    }
    func drawHourlyList() {
        
    }
    func drawFromMid() {
        
    }
    
    func getContext() -> NSManagedObjectContext {
        // 사용안함. override this!
        return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
    }
    
    func saveContext() {
        
    }
    
}
