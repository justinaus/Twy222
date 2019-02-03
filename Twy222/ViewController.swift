//
//  ViewController.swift
//  Twy222
//  코어 데이터는 맨 처음에만 딱 한번 체크하고, 그 이후에는 체크하지 않는다. 저장만 하고.
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
    
    var gridEntity: GridEntity?;
    
    var dateRegionLastCalled: Date?
    
    // 전체 다 한바퀴 돌아서 완료했는지 여부 체크를 위해.
    // 2가지 갈래가 있고, 결국 카운트가 2가 되면 다 완료 된 것임.
    var nApiGroupCompleteCount = 0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit();
        
        // 기존 코어데이터가 정상적으로 있을 경우, 완료 된 시간과 현재 시간을 비교해서
        // 얼마 안됐으면 그냥 콜을 하지 않고 기존 코어데이터로 그리고, 시간이 충분히 지났으면 정상적으로 api call 진행.
        // 코어 데이터는 맨 처음에 딱 한번 체크하고, 그 이후에는 아예 체크하지 않는다. 저장만 하고.
        if let coreDataDateComplete = CoreDataManager.shared.getCommonEntity()?.dateCompleteAll, let coreDataGridEntity = CoreDataManager.shared.getCurrentGridData() {
            let now = Date();
            
            print("coredata 이전 콜 start 시간: \(DateUtil.getStringByDate(date: coreDataDateComplete))")
            
            let componenets = Calendar.current.dateComponents([.minute], from: coreDataDateComplete, to: now);
            
            if( componenets.minute! < Settings.LIMIT_INTERVAL_MINUTES_TO_CALL_REGION_BY_CORE_DATA ) {
                print("coredata 기존에 콜 한지 xx분도 안됨, 콜 하지 말고 그리자.");
                
                dateRegionLastCalled = now;
                
                gridEntity = coreDataGridEntity;
                
                drawTodayText(date: now)
                drawAddress();
                drawAirData();
                drawNowData();
                drawHourlyList();
                drawFromMid();
            }
        }
        
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
        
        if let dateLast = dateRegionLastCalled {
            print("이전 콜 start 시간: \(DateUtil.getStringByDate(date: dateLast))")
            
            let componenets = Calendar.current.dateComponents([.minute], from: dateLast, to: now);
            
            if( componenets.minute! < Settings.LIMIT_INTERVAL_MINUTES_TO_CALL_REGION ) {
                print("기존에 콜 한지 xx분도 안됨, 아무것도 안함")
                return;
            }
        }
        
        dateRegionLastCalled = now;
        
        nApiGroupCompleteCount = 0;
        
        print("호출 시작 \(DateUtil.getStringByDate(date: now))")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        // 한개만 사용.
        appDelegate.deleteAllInEntity(entityEnum: EntityEnum.Grid);
        
        let lat = currentLocation!.coordinate.latitude;
        let lon = currentLocation!.coordinate.longitude;
        
        let context = appDelegate.persistentContainer.viewContext;
        
        gridEntity = GridEntity(context: context);
        gridEntity!.latitude = lat;
        gridEntity!.longitude = lon;
        gridEntity!.dateCalled = now;
        
        appDelegate.saveContext();
        
        getGridModelByLonLat( dateNow: now, lon: lon, lat: lat );
    }
    
    func getGridModelByLonLat( dateNow: Date, lon: Double, lat: Double ) {
        func onComplete( model: AddressEntity ) {
            gridEntity?.address = model;
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.saveContext();
            
            drawAddress();
            
            getNowData(dateNow: dateNow);

            getAirData(dateNow: dateNow);
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "geo api error", buttonText: "확인", onSelect: nil);
        }
        
        KakaoApiManager.shared.getAddressData(dateNow: dateNow, lat: lat, lon: lon, callbackComplete: onComplete, callbackError: onError);
    }
    
    func getNowData( dateNow: Date ) {
        func onComplete( model:NowEntity? ) {
            guard let modelNotNil = model else {
                return;
            }
            
            gridEntity!.now = modelNotNil;
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.saveContext();
            
            drawNowData();
            
            // 동시 콜 x, 순서대로 하겠다. 디버깅 편하게 하기 위해.
            getForecastHourlyData(dateNow: dateNow );
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "now api error", buttonText: "확인", onSelect: nil);
        }
        
        KmaApiManager.shared.getNowData(dateNow: dateNow, lat: gridEntity!.latitude, lon: gridEntity!.longitude, callbackComplete: onComplete, callbackError: onError );
    }
    
    func getForecastHourlyData( dateNow: Date ) {
        func onComplete( model: [HourlyEntity]? ) {
            guard let arrHourly = model else {
                return;
            }
            
            for hourly in arrHourly {
                gridEntity!.addToHourly(hourly);
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
            
            // 오늘이 포함 되어 있다. 오늘을 자른다.
            let today = modelNotNil.removeFirst();
            
            gridEntity!.now?.temperatureMax = today.temperatureMax;
            gridEntity!.now?.temperatureMin = today.temperatureMin;
            
            saveDailyModelToDaily(arrOrigin: modelNotNil);
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.saveContext();
            
            apiGroupComplete(dateNow: dateNow);
            
            drawFromMid();
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "mid api error", buttonText: "확인", onSelect: nil);
        }
        
        KmaApiManager.shared.getForecastMidData(dateNow: dateNow, address: gridEntity!.address!, callbackComplete: onComplete, callbackError: onError);
    }
    
    func getAirData( dateNow: Date ) {
        // 시간 체크 필요.
        
        guard let address = gridEntity?.address else {
            return;
        }
        
        func onComplete( model: AirEntity ) {
            gridEntity?.air = model;
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            appDelegate.saveContext();
            
            apiGroupComplete( dateNow: dateNow );
            
            drawAirData();
        }
        
        func onError( errorModel: ErrorModel ) {
            AlertUtil.alert(vc: self, title: "error", message: "air api error", buttonText: "확인", onSelect: nil);
        }
        
        AkApiManager.shared.getAirData(dateNow: dateNow, tmX: address.tmX, tmY: address.tmY, callbackComplete: onComplete, callbackError: onError);
    }
    
    func apiGroupComplete( dateNow: Date ) {
        nApiGroupCompleteCount += 1;
        
        if( nApiGroupCompleteCount > 1 ) {
            // 한 바퀴 완료.
            CoreDataManager.shared.saveApiCompleteDate(dateComplete: dateNow);
        }
    }
    
    func drawTodayText( date: Date ) {
        let component = Calendar.current.dateComponents([.month, .day, .weekday], from: date);
        let weekday = DateUtil.getWeekdayString( component.weekday!, .koreanWithBracket );
        
        labelToday.text = "\(component.month!)월 \(component.day!)일 \(weekday)";
    }
    
    func drawAddress() {
        guard let addressTitle = CoreDataManager.shared.getAddressTitle(address: gridEntity?.address ) else {
            return;
        }
        
        DispatchQueue.main.async {
            self.labelNowLocation.text = addressTitle;
        }
    }
    
    func drawAirData() {
        guard let airEntity = gridEntity?.air else {
            return;
        }
        
        let pm10Grade = FineDustUtils.getFineDustGrade(fineDustType: .pm10, value: Int(airEntity.pm10Value));
        let pm25Grade = FineDustUtils.getFineDustGrade(fineDustType: .pm25, value: Int(airEntity.pm25Value));
        
        DispatchQueue.main.async {
            self.labelPm10.textColor = pm10Grade.color;
            self.labelPm25.textColor = pm25Grade.color;
            
            self.labelPm10.text = "\(airEntity.pm10Value) \(pm10Grade.text)";
            self.labelPm25.text = "\(airEntity.pm25Value) \(pm25Grade.text)";
            
            self.viewAirQuality.isHidden = false;
        }
    }
    
    func drawNowData() {
        guard let nowEntity = gridEntity?.now else {
            return;
        }
        
        DispatchQueue.main.async {
            let intTemperature = NumberUtil.roundToInt(value: nowEntity.temperature);
            self.labelNowTemperature.text = "\(intTemperature)\(CharacterStruct.TEMPERATURE)";
            
            self.labelNowSkyStatus.text = nowEntity.skyStatusText;
            
            self.imageSkyStatus.image = UIImage(named: nowEntity.skyStatusImageName!);
            self.imageSkyStatus.isHidden = false;
            
            // entity option 값이 문제가 있는 듯.
            if( Int(nowEntity.diffFromYesterday) == TwyUtils.NUMBER_NIL_TEMP ) {
                self.labelNowCompareWithYesterday.text = "";
            } else {
                let intTemperatureGap = NumberUtil.roundToInt(value: nowEntity.diffFromYesterday);
                self.labelNowCompareWithYesterday.text = TwyUtils.getTextCompareWithYesterday(intTemperatureGap: intTemperatureGap);
            }
        }
    }
    
    func drawHourlyList() {
        DispatchQueue.main.async {
            self.collectionViewShort.reloadData();
        }
    }
    
    private func drawFromMid() {
        guard let temperatureMax = gridEntity?.now?.temperatureMax else {
            return;
        }
        guard let temperatureMin = gridEntity?.now?.temperatureMin else {
            return;
        }
        
        DispatchQueue.main.async {
            self.labelTodayTemperature.text = "\(NumberUtil.roundToInt(value: temperatureMax)) / \(NumberUtil.roundToInt(value: temperatureMin))";
            
            self.collectionViewMid.reloadData();
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( gridEntity == nil ) {
            return 0;
        }
        
        let isShortView = collectionView == collectionViewShort;
        
        if( isShortView ) {
            return gridEntity!.hourly?.count ?? 0;
        } else {
            return gridEntity!.daily?.count ?? 0;
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
        
        guard let hourly = gridEntity?.hourly else {
            return cell;
        }
        
        var arrHourly = Array( hourly );
        arrHourly.sort(by: {
            ($0 as AnyObject).date.compare(($1 as AnyObject).date) == .orderedAscending
        })
        
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
        
        guard let daily = gridEntity?.daily else {
            return cell;
        }
        
        var arrDaily = Array( daily );
        arrDaily.sort(by: {
            ($0 as AnyObject).date.compare(($1 as AnyObject).date) == .orderedAscending
        })
        
        let model = arrDaily[ indexPath.item ] as! DailyEntity;
        
        cell.setImageSkyByFileName(imageFileName: model.skyStatusImageName!);
        
        let max = NumberUtil.roundToInt(value: model.temperatureMax);
        let min = NumberUtil.roundToInt(value: model.temperatureMin);
        
        cell.setLabelTemperatureMaxMin(str: "\(max) / \(min)");
        
        let weekday = Calendar.current.component(.weekday, from: model.date!);
        cell.setLabelWeekday(str: DateUtil.getWeekdayString( weekday, .koreanOneLetter) );
        
        return cell;
    }
    
    private func saveDailyModelToDaily( arrOrigin: [DailyModel] ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        
        var newDaily: DailyEntity;
        
        for origin in arrOrigin {
            newDaily = DailyEntity(context: context);
            
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
        
        AlertUtil.alert(vc: self, title: "위치 접근 허용 안함", message: "임시 장소 정보를 가져옵니다.\n설정에서 위치 접근을 허용해주세요.", buttonText: "확인", onSelect: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination;
        
        guard let vcAir = dest as? VCAir else {
            return;
        }
        
        vcAir.setData(airEntity: gridEntity?.air);
        
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func unwindToVC( _ unwindSegue: UIStoryboardSegue) {
        
    }
}

