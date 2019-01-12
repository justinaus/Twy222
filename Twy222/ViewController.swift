//
//  ViewController.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let gridModel = GridManager.shared.getCurrentGridModel() else {
            return 0;
        };
        
        let isShortView = collectionView == collectionViewShort;
        
        if( isShortView ) {
            return gridModel.forecastHourList?.list.count ?? 0;
        }
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isShortView = collectionView == collectionViewShort;
        
//        let cell = isShortView ? makeCollectionViewCellShort(indexPath: indexPath) : makeCollectionViewCellMid(indexPath: indexPath);
        
        let cell = makeCollectionViewCellShort(indexPath: indexPath);
        
        return cell;
    }
    
    func makeCollectionViewCellShort( indexPath: IndexPath ) -> CollectionViewCellShort {
        let reuseIdentifier = "cellShort";
        let cell = collectionViewShort.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCellShort
        
        let gridModel = GridManager.shared.getCurrentGridModel()!;
        let model = gridModel.forecastHourList!.list[indexPath.item];
        
        let hour = Calendar.current.component(.hour, from: model.date)
        cell.setLabelHour(str: "\(hour)시");
        
        cell.setImageSkyByFileName(imageFileName: model.skyStatusImageName);
        
        let strTemperature = NumberUtil.roundToString(value: model.temperature);
        
        cell.setLabelTemperature(str: strTemperature );
        
        
//        guard let skApiYesterdayModel = gridModel.skApiYesterdayModel else {
//            return cell;
//        }
//
//        guard let yesterdayHourlyModel = SKUtil.getYesterdayModel(currentHourlyModel: model, yesterdayModel: skApiYesterdayModel, dateFormat: DateFormatEnum.YYYY_MM_DD_HH_mm_SS) else {
//            cell.setLabelTemperature(str: strTemperature);
//
//            return cell;
//        }
//
//        let doubleTemperatureGap = Double( model.temperature )! - Double( yesterdayHourlyModel.temperature )!;
//        let intTemperatureGap = NumberUtil.roundToInt( doubleTemperatureGap );
//        let strGap = SKUtil.makeIntStringWithSign(temperature: intTemperatureGap);
//
//        cell.setLabelTemperature(str: strTemperature + " (" + strGap + ")" );
        
        return cell;
    }
    
    
    
    
    @IBOutlet var labelNowLocation: UILabel!
    @IBOutlet var labelNowTemperature: UILabel!
    @IBOutlet var labelNowCompareWithYesterday: UILabel!
    @IBOutlet var labelNowSkyStatus: UILabel!
    @IBOutlet var imageSkyStatus: UIImageView!
    
    @IBOutlet var labelToday: UILabel!
    
    @IBOutlet var collectionViewShort: UICollectionView!
    
    let locationManager: CLLocationManager = CLLocationManager();
    var currentLocation: CLLocation?;
    
    var dateLastCalled:Date?;
    let LIMIT_INTERVAL_MINUTES_TO_CALL:Int = 5;
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit();
        
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
        
        showTodayText( date: now );
        
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

            self.getNowData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY);
        }
    }
    
    func getNowData( dateNow: Date, kmaX: Int, kmaY: Int ) {
        func onComplete( model:NowModel? ) {
            if( model == nil ) {
                print("현재 기온, 하늘 상태 가져오기 실패. 아무것도 안함.");
                return;
            }
            
            let gridModel = GridManager.shared.getCurrentGridModel()!;
            gridModel.setNowModel(value: model!);
            
            drawNowData();
            
            // 동시 콜 x, 순서대로 하겠다. 디버깅 편하게 하기 위해.
            
            getForecastHourlyData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY)
        }
        
        KmaApiManager.shared.getNowData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onComplete);
    }
    
    func getForecastHourlyData( dateNow: Date, kmaX: Int, kmaY: Int ) {
        func onComplete( model: ForecastHourListModel? ) {
            if( model == nil ) {
                print("시간 별 예보 가져오기 실패. 이후 동작 안함.");
                return;
            }
            
            let gridModel = GridManager.shared.getCurrentGridModel()!;
            gridModel.setForecastHourListModel(value: model!);
            
            DispatchQueue.main.async {
                self.collectionViewShort.reloadData();
            }
        }
        
        KmaApiManager.shared.getForecastHourlyData(dateNow: dateNow, kmaX: kmaX, kmaY: kmaY, callback: onComplete);
    }
    
    func drawNowData() {
        let gridModel = GridManager.shared.getCurrentGridModel()!;
        let nowModel = gridModel.nowModel!;
        
        DispatchQueue.main.async {
            self.labelNowLocation.text = gridModel.dongName;
            
            let intTemperature = NumberUtil.roundToInt(value: nowModel.temperature);
            self.labelNowTemperature.text = "\(intTemperature)\(CharacterStruct.TEMPERATURE)";
            
            self.labelNowSkyStatus.text = nowModel.skyStatusText;
            
            self.imageSkyStatus.image = UIImage(named: nowModel.skyStatusImageName)!
            self.imageSkyStatus.isHidden = false;
            
            if( nowModel.diffFromYesterday == nil ) {
                self.labelNowCompareWithYesterday.text = "";
            } else {
                let intTemperatureGap = NumberUtil.roundToInt(value: nowModel.diffFromYesterday!);
                self.labelNowCompareWithYesterday.text = self.getTextCompareWithYesterday(intTemperatureGap: intTemperatureGap);
            }
            
//            if let nTempMax = NumberUtil.roundToInt( model.temperatureMax ),
//                let nTempMin = NumberUtil.roundToInt( model.temperatureMin ) {
//                self.labelNowTempMaxMin.text = String( nTempMax ) + " / " + String( nTempMin );
//            }
        }
    }
    
    private func getTextCompareWithYesterday( intTemperatureGap: Int ) -> String {
        let uintTemperatureGap = abs(intTemperatureGap);
        
        var strComment = "어제와 같음";
        
        if( intTemperatureGap > 0 ) {
            strComment = "어제보다 \(uintTemperatureGap)\(CharacterStruct.TEMPERATURE) 높음"
        } else if( intTemperatureGap < 0 ) {
            strComment = "어제보다 \(uintTemperatureGap)\(CharacterStruct.TEMPERATURE) 낮음"
        }
        
        return strComment;
    }
    
    func viewInit() {
        labelNowLocation.text = "";
        labelNowSkyStatus.text = "";
        labelNowTemperature.text = "";
        labelNowCompareWithYesterday.text = "";
//        labelNowTempMaxMin.text = "";
        imageSkyStatus.isHidden = true;
//
//        btnLogo.isHidden = true;
//
        labelToday.text = "";
//
//        labelPm10.text = "";
//        labelPm25.text = "";
//        viewAirQuality.isHidden = true;
    }
    
    func showTodayText( date: Date ) {
        let component = Calendar.current.dateComponents([.month, .day, .weekday], from: date);
        let weekday = DateUtil.getWeekdayString( component.weekday!, .koreanWithBracket );
        
        labelToday.text = "\(component.month!)월 \(component.day!)일 \(weekday)";
    }
    
    
}

