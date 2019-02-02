//
//  ViewController.swift
//  Twy222
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

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
    
    @IBOutlet var viewAirQuality: UIView!
    @IBOutlet var labelPm10: UILabel!
    @IBOutlet var labelPm25: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager();
    var currentLocation: CLLocation?;
    
    // 나중에 core data로 변경.
    var dateLastCalledRegion:Date?;
    var dateLastCalledAir:Date?;
    
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
            goJustTempLocation();
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
        
        drawTodayText( date: now );
        
        if( dateLastCalledRegion != nil) {
            let componenets = Calendar.current.dateComponents([.minute], from: dateLastCalledRegion!, to: now);
            
            if( componenets.minute! < Settings.LIMIT_INTERVAL_MINUTES_TO_CALL_REGION ) {
//                print("기존에 콜 한지 xx분도 안됨, 아무것도 안함")
                return;
            }
        }
        
        dateLastCalledRegion = now;
        
        let lat = currentLocation!.coordinate.latitude;
        let lon = currentLocation!.coordinate.longitude;
        
        let saveSuccess = CoreDataManager.shared.saveGridData(dateNow: now, lon: lon, lat: lat);
        
        if( saveSuccess ) {
            getGridModelByLonLat( dateNow: now, lon: lon, lat: lat );
        } else {
            AlertUtil.alert(vc: self, title: "error", message: "core data error", buttonText: "확인", onSelect: nil);
        }
    }
    
    func getGridModelByLonLat( dateNow: Date, lon: Double, lat: Double ) {
        func onComplete( model: AddressEntity ) {
            let saveSuccess = CoreDataManager.shared.saveDataInCurrentGrid(model: model, strKey: "address")
            if( !saveSuccess ) {
                return;
            }
    
            guard let addressTitle = CoreDataManager.shared.getAddressTitle() else {
                return;
            }
            DispatchQueue.main.async {
                self.labelNowLocation.text = addressTitle;
            }
            
            getNowData(dateNow: dateNow);
            
            getAirData(dateNow: dateNow);
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "geo api error", buttonText: "확인", onSelect: nil);
        }
        
        KakaoApiManager.shared.getAddressData(dateNow: dateNow, lat: lat, lon: lon, callbackComplete: onComplete, callbackError: onError);
    }
    
    func getNowData( dateNow: Date ) {
        guard let gridModel = CoreDataManager.shared.getCurrentGridData() else {
            return;
        }
        
        func onComplete( model:NowEntity? ) {
            guard let modelNotNil = model else {
                return;
            }
            
            let saveSuccess = CoreDataManager.shared.saveDataInCurrentGrid(model: modelNotNil, strKey: "now")
            if( !saveSuccess ) {
                return;
            }

            drawNowData();

            // 동시 콜 x, 순서대로 하겠다. 디버깅 편하게 하기 위해.
            getForecastHourlyData(dateNow: dateNow );
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "now api error", buttonText: "확인", onSelect: nil);
        }
        
        KmaApiManager.shared.getNowData(dateNow: dateNow, lat: gridModel.latitude, lon: gridModel.longitude, callbackComplete: onComplete, callbackError: onError );
    }
    
    func getForecastHourlyData( dateNow: Date ) {
//        func onComplete( model: ForecastHourListModel? ) {
        func onComplete( model: NSSet? ) {
            if( model == nil ) {
                return;
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.saveContext();
            
            drawHourlyList();
        }
        
        func onCompleteYesterdayAll() {
            drawHourlyList();

            getForecastMidData(dateNow: dateNow);
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "hourly api error", buttonText: "확인", onSelect: nil);
        }
        
        KmaApiManager.shared.getForecastHourlyData(dateNow: dateNow, callbackComplete: onComplete, callbackYesterdayAll: onCompleteYesterdayAll, callbackError: onError);
    }
    
    func getForecastMidData( dateNow: Date ) {
        func onComplete( model: [DailyModel]? ) {
            guard var modelNotNil = model else {
                return;
            }
            
            guard let grid = CoreDataManager.shared.getCurrentGridData() else {
                return;
            }
            
            // 오늘이 포함 되어 있다. 오늘을 자른다.
            let today = modelNotNil.removeFirst();
            
            grid.now?.temperatureMax = today.temperatureMax;
            grid.now?.temperatureMin = today.temperatureMin;
            
            saveDailyModelToDaily(arrOrigin: modelNotNil);
            
            DispatchQueue.main.async {
                self.labelTodayTemperature.text = "\(NumberUtil.roundToInt(value: today.temperatureMax)) / \(NumberUtil.roundToInt(value: today.temperatureMin))";

                self.collectionViewMid.reloadData();
            }
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "mid api error", buttonText: "확인", onSelect: nil);
        }
        
        KmaApiManager.shared.getForecastMidData(dateNow: dateNow, callbackComplete: onComplete, callbackError: onError);
    }
    
    private func saveDailyModelToDaily( arrOrigin: [DailyModel] ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        let grid = CoreDataManager.shared.getCurrentGridData()!;
        
        var newDaily: DailyEntity;
        
        for origin in arrOrigin {
            newDaily = DailyEntity(context: context);
            
            newDaily.date = origin.date;
            newDaily.temperatureMax = origin.temperatureMax;
            newDaily.temperatureMin = origin.temperatureMin;
            newDaily.skyStatusImageName = origin.skyStatusImageName;
            newDaily.skyStatusText = origin.skyStatusText;
            
            grid.addToDaily(newDaily);
        }
        
        appDelegate.saveContext();
    }
    
    func getAirData( dateNow: Date ) {
        //        if( dateLastCalledAir != nil) {
        //            let componenets = Calendar.current.dateComponents([.minute], from: dateLastCalledAir!, to: dateNow);
        //
        //            if( componenets.minute! < Settings.LIMIT_INTERVAL_MINUTES_TO_CALL_AIR ) {
        ////                print("air 기존에 콜 한지 xx분도 안됨, 아무것도 안함")
        //                return;
        //            }
        //        }
        
        guard let address = CoreDataManager.shared.getCurrentGridData()?.address else {
            return;
        }
        
        func onComplete( model: AirEntity ) {
            let saveSuccess = CoreDataManager.shared.saveDataInCurrentGrid(model: model, strKey: "air");
            if( !saveSuccess ) {
                return;
            }
            
            drawAirData();
        }

        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "air api error", buttonText: "확인", onSelect: nil);
        }
        
        //        dateLastCalledAir = dateNow;

        AkApiManager.shared.getAirData(dateNow: dateNow, tmX: address.tmX, tmY: address.tmY, callbackComplete: onComplete, callbackError: onError);
    }
    
    func drawHourlyList() {
        DispatchQueue.main.async {
            self.collectionViewShort.reloadData();
        }
    }
    
    func drawNowData() {
        guard let nowModel = CoreDataManager.shared.getCurrentGridData()?.now else {
            return;
        }
        
        DispatchQueue.main.async {
            let intTemperature = NumberUtil.roundToInt(value: nowModel.temperature);
            self.labelNowTemperature.text = "\(intTemperature)\(CharacterStruct.TEMPERATURE)";
            
            self.labelNowSkyStatus.text = nowModel.skyStatusText;
            
            self.imageSkyStatus.image = UIImage(named: nowModel.skyStatusImageName!);
            self.imageSkyStatus.isHidden = false;
            
            // core data option 값이 문제가 있는 듯.
            if( Int(nowModel.diffFromYesterday) == TwyUtils.NUMBER_NIL_TEMP ) {
                self.labelNowCompareWithYesterday.text = "";
            } else {
                let intTemperatureGap = NumberUtil.roundToInt(value: nowModel.diffFromYesterday);
                self.labelNowCompareWithYesterday.text = self.getTextCompareWithYesterday(intTemperatureGap: intTemperatureGap);
            }
        }
    }
    
    func drawAirData() {
        guard let airModel = CoreDataManager.shared.getCurrentGridData()?.air else {
            return;
        }
        
        let pm10Grade = FineDustUtils.getFineDustGrade(fineDustType: .pm10, value: Int(airModel.pm10Value));
        let pm25Grade = FineDustUtils.getFineDustGrade(fineDustType: .pm25, value: Int(airModel.pm25Value));
        
        DispatchQueue.main.async {
            self.labelPm10.textColor = pm10Grade.color;
            self.labelPm25.textColor = pm25Grade.color;
            
            self.labelPm10.text = "\(airModel.pm10Value) \(pm10Grade.text)";
            self.labelPm25.text = "\(airModel.pm25Value) \(pm25Grade.text)";
            
            self.viewAirQuality.isHidden = false;
        }
    }
    
    func drawTodayText( date: Date ) {
        let component = Calendar.current.dateComponents([.month, .day, .weekday], from: date);
        let weekday = DateUtil.getWeekdayString( component.weekday!, .koreanWithBracket );
        
        labelToday.text = "\(component.month!)월 \(component.day!)일 \(weekday)";
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

        labelPm10.text = "";
        labelPm25.text = "";
        viewAirQuality.isHidden = true;
    }
    
    func goJustTempLocation() {
        // gps 사용 못할 경우 임의의 장소의 정보를 가져온다 - 테스트로 대치동으로 하겠다.
        let lat = 37.496066;
        let lon = 127.067405;
        currentLocation = CLLocation(latitude: lat, longitude: lon);
        
        tryStartToApiCall();
        
        AlertUtil.alert(vc: self, title: "위치 접근 허용 안함", message: "임시 장소 정보를 가져옵니다.\n설정에서 위치 접근을 허용해주세요.", buttonText: "확인", onSelect: nil);
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let gridModel = CoreDataManager.shared.getCurrentGridData() else {
            return 0;
        }
        
        let isShortView = collectionView == collectionViewShort;
        
        if( isShortView ) {
//            return gridModel.forecastHourList?.list.count ?? 0;
            return gridModel.hourly?.count ?? 0;
        } else {
//            return gridModel.forecastMidList?.list.count ?? 0;
            return gridModel.daily?.count ?? 0;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isShortView = collectionView == collectionViewShort;
        
        let cell = isShortView ? makeCollectionViewCellShort(indexPath: indexPath) : makeCollectionViewCellMid(indexPath: indexPath);
        
        return cell;
    }
    
    func makeCollectionViewCellShort( indexPath: IndexPath ) -> CollectionViewCellShort {
        let reuseIdentifier = "cellShort";
        let cell = collectionViewShort.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCellShort;
        
        guard let hourly = CoreDataManager.shared.getCurrentGridData()?.hourly else {
            return cell;
        }
        
        var arrHourly = Array( hourly );
        arrHourly.sort(by: {
            ($0 as AnyObject).date.compare(($1 as AnyObject).date) == .orderedAscending
        })
        
//        let gridModel = GridManager.shared.getCurrentGridModel()!;
//        let model = gridModel.forecastHourList!.list[indexPath.item];
        
        let model = arrHourly[ indexPath.item ] as! HourlyEntity;
        
        let hour = Calendar.current.component(.hour, from: model.date!)
        cell.setLabelHour(str: "\(hour)시");
        
        cell.setImageSkyByFileName(imageFileName: model.skyStatusImageName!);
        
        let strTemperature = NumberUtil.roundToString(value: model.temperature);
        
        if( Int(model.diffFromYesterday) == TwyUtils.NUMBER_NIL_TEMP ) {
            cell.setLabelTemperature(str: strTemperature);
        } else {
            let intRoundedDiff = NumberUtil.roundToInt(value: model.diffFromYesterday);

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
        
        guard let daily = CoreDataManager.shared.getCurrentGridData()?.daily else {
            return cell;
        }
        
        var arrDaily = Array( daily );
        arrDaily.sort(by: {
            ($0 as AnyObject).date.compare(($1 as AnyObject).date) == .orderedAscending
        })
        
        let model = arrDaily[ indexPath.item ] as! DailyEntity;
        
//        let gridModel = GridManager.shared.getCurrentGridModel()!;
//        let model = gridModel.forecastMidList!.list[indexPath.item];
        
        cell.setImageSkyByFileName(imageFileName: model.skyStatusImageName!);
        
        let max = NumberUtil.roundToInt(value: model.temperatureMax);
        let min = NumberUtil.roundToInt(value: model.temperatureMin);
        
        cell.setLabelTemperatureMaxMin(str: "\(max) / \(min)");
        
        let weekday = Calendar.current.component(.weekday, from: model.date!);
        cell.setLabelWeekday(str: DateUtil.getWeekdayString( weekday, .koreanOneLetter) );
        
        return cell;
    }
    
    @IBAction func unwindToVC( _ unwindSegue: UIStoryboardSegue) {
        
    }
}

