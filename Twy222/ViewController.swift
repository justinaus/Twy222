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
    
    @IBOutlet var labelNowLocation: UILabel!
    @IBOutlet var labelNowTemperature: UILabel!
    @IBOutlet var labelNowCompareWithYesterday: UILabel!
    @IBOutlet var labelNowSkyStatus: UILabel!
    @IBOutlet var imageSkyStatus: UIImageView!
    
    @IBOutlet var labelToday: UILabel!
    @IBOutlet var labelTodayTemperature: UILabel!
    
    @IBOutlet var collectionViewShort: UICollectionView!
    @IBOutlet var collectionViewMid: UICollectionView!
    
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
        
        getGridModelByLonLat( dateNow: now, lon: currentLocation!.coordinate.longitude, lat: currentLocation!.coordinate.latitude );
    }
    
    func getGridModelByLonLat( dateNow: Date, lon: Double, lat: Double ) {
        func onComplete( model: IAddressModel? ) {
            guard let modelNotNil = model else {
                return;
            }
            
            let gridModel = GridModel(lat: lat, lon: lon);
            GridManager.shared.setCurrentGridModel( gridModel: gridModel );
            
            gridModel.setAddressModel(value: modelNotNil);
            
            self.getNowData(dateNow: dateNow);
        }
        
        KakaoApiManager.shared.getAddressData(dateNow: dateNow, lat: lat, lon: lon, callback: onComplete);
    }
    
    func getNowData( dateNow: Date ) {
        let gridModel = GridManager.shared.getCurrentGridModel()!;
        
        func onComplete( model:NowModel? ) {
            guard let modelNotNil = model else {
                print("현재 기온, 하늘 상태 가져오기 실패. 아무것도 안함.");
                return;
            }
            
            gridModel.setNowModel(value: modelNotNil);
            
            drawNowData();
            
            // 동시 콜 x, 순서대로 하겠다. 디버깅 편하게 하기 위해.
            getForecastHourlyData(dateNow: dateNow );
        }
        
        KmaApiManager.shared.getNowData(dateNow: dateNow, lat: gridModel.latitude, lon: gridModel.longitude, callback: onComplete );
    }
    
    func getForecastHourlyData( dateNow: Date ) {
        func onComplete( model: ForecastHourListModel? ) {
            guard let modelNotNil = model else {
                print("시간 별 예보 가져오기 실패. 이후 동작 안함.");
                return;
            }
            
            let gridModel = GridManager.shared.getCurrentGridModel()!;
            gridModel.setForecastHourListModel(value: modelNotNil);
            
            drawHourlyList();
        }
        
        func onCompleteYesterdayAll() {
            drawHourlyList();
            
            getForecastMidData(dateNow: dateNow);
        }
        
        KmaApiManager.shared.getForecastHourlyData(dateNow: dateNow, callback: onComplete, callbackYesterdayAll: onCompleteYesterdayAll);
    }
    
    func getForecastMidData( dateNow: Date ) {
        func onComplete( model: ForecastMidListModel? ) {
            guard let modelNotNil = model else {
                print("중기 예보 가져오기 실패. 이후 동작 안함.");
                return;
            }
            
            // 오늘이 포함 되어 있다. 오늘을 자른다.
            let today = modelNotNil.list.removeFirst();
            
            let gridModel = GridManager.shared.getCurrentGridModel()!;
            gridModel.setForecastMidListModel(value: modelNotNil);

            DispatchQueue.main.async {
                self.labelTodayTemperature.text = "\(NumberUtil.roundToInt(value: today.temperatureMax)) / \(NumberUtil.roundToInt(value: today.temperatureMin))";
                
                self.collectionViewMid.reloadData();
            }
        }
        
        KmaApiManager.shared.getForecastMidData(dateNow: dateNow, callback: onComplete);
    }
    
    func drawNowData() {
        let gridModel = GridManager.shared.getCurrentGridModel()!;
        let nowModel = gridModel.nowModel!;
        
        DispatchQueue.main.async {
            // 주소 정보가 없는 경우는 일어나지 않는 게 맞다. 혹여 실수하게 될 경우에 고치기 쉽게 하기 위해 빈 값을 표시하겠다.
            self.labelNowLocation.text = gridModel.addressModel?.getAddressTitle() ?? "";
            
            let intTemperature = NumberUtil.roundToInt(value: nowModel.temperature);
            self.labelNowTemperature.text = "\(intTemperature)\(CharacterStruct.TEMPERATURE)";
            
            self.labelNowSkyStatus.text = nowModel.skyStatusText;
            
            self.imageSkyStatus.image = UIImage(named: nowModel.skyStatusImageName);
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
    
    func drawHourlyList() {
        DispatchQueue.main.async {
            self.collectionViewShort.reloadData();
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
        labelTodayTemperature.text = "";
        imageSkyStatus.isHidden = true;

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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let gridModel = GridManager.shared.getCurrentGridModel() else {
            return 0;
        };
        
        let isShortView = collectionView == collectionViewShort;
        
        if( isShortView ) {
            return gridModel.forecastHourList?.list.count ?? 0;
        } else {
            return gridModel.forecastMidList?.list.count ?? 0;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isShortView = collectionView == collectionViewShort;
        
        let cell = isShortView ? makeCollectionViewCellShort(indexPath: indexPath) : makeCollectionViewCellMid(indexPath: indexPath);
        
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
        
        if( model.diffFromYesterday == nil ) {
            cell.setLabelTemperature(str: strTemperature);
        } else {
            let intRoundedDiff = NumberUtil.roundToInt(value: model.diffFromYesterday!);
            
            var strDiff: String;
            
            if( intRoundedDiff == 0 ) {
                strDiff = "=";
            } else if( intRoundedDiff > 0 ) {
                strDiff = "+\(intRoundedDiff)";
            } else {
                strDiff = String( intRoundedDiff );
            }
            
            let text = strTemperature + " (" + strDiff + ")"
            
            cell.setLabelTemperature(str: text);
        }
        
        return cell;
    }
    
    func makeCollectionViewCellMid( indexPath: IndexPath ) -> CollectionViewCellMid {
        let reuseIdentifier = "cellMid";
        let cell = collectionViewMid.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCellMid;
        
        let gridModel = GridManager.shared.getCurrentGridModel()!;
        let model = gridModel.forecastMidList!.list[indexPath.item];
        
        cell.setImageSkyByFileName(imageFileName: model.skyStatusImageName);
        
        let max = NumberUtil.roundToInt(value: model.temperatureMax);
        let min = NumberUtil.roundToInt(value: model.temperatureMin);
        
        cell.setLabelTemperatureMaxMin(str: "\(max) / \(min)");
        
        let weekday = Calendar.current.component(.weekday, from: model.date);
        cell.setLabelWeekday(str: DateUtil.getWeekdayString( weekday, .koreanOneLetter) );
        
        return cell;
    }
}

