//
//  ViewController.swift
//  Twy222
//  코어 데이터는 맨 처음에만 딱 한번 체크하고, 그 이후에는 체크하지 않는다. 저장만 하고.
//
//  Created by Bonkook Koo on 04/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import UIKit
import CoreData

class ViewController: ViewControllerCore, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
    
    @IBOutlet var buttonModal: UIButton!
    @IBOutlet var viewMenu: UIView!
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        
        AppManager.shared.start(isMainApp: true);
        CoreDataManager.shared.setContext(context: context);
        
        super.viewDidLoad();
        
        viewInit();
        
        // 기존 코어데이터가 정상적으로 있을 경우, 완료 된 시간과 현재 시간을 비교해서
        // 얼마 안됐으면 그냥 콜을 하지 않고 기존 코어데이터로 그리고, 시간이 충분히 지났으면 정상적으로 api call 진행.
        // 코어 데이터는 맨 처음에 딱 한번 체크하고, 그 이후에는 아예 체크하지 않는다. 저장만 하고.
        guard let coreDataDateComplete = CoreDataManager.shared.getCommonEntity()?.dateCompleteAll, let coreDataGridEntity = CoreDataManager.shared.getCurrentGridData() else {
            startLocationManager();
            return;
        }
        // 근데 기존에 있는 데이터가 today extenstion용 데이터이면 그냥 처음부터 api call 진행하겠다. 귀찮..
        if( CoreDataManager.shared.getCommonEntity()?.isMainApp == false ) {
            startLocationManager();
            return;
        }

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
        
        startLocationManager();
    }
    
    override func getForecastHourlyData( dateNow: Date ) {
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
    
    override func drawTodayText( date: Date ) {
        let component = Calendar.current.dateComponents([.month, .day, .weekday], from: date);
        let weekday = DateUtil.getWeekdayString( component.weekday!, .koreanWithBracket );
        
        labelToday.text = "\(component.month!)월 \(component.day!)일 \(weekday)";
    }
    
    override func drawAddress() {
        guard let addressTitle = CoreDataManager.shared.getAddressTitle(address: gridEntity?.address ) else {
            return;
        }
        
        DispatchQueue.main.async {
            self.labelNowLocation.text = addressTitle;
        }
    }
    
    override func drawAirData() {
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
    
    override func drawNowData() {
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
    
    override func drawHourlyList() {
        DispatchQueue.main.async {
            self.collectionViewShort.reloadData();
        }
    }
    
    override func drawFromMid() {
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
    
    @IBAction func onClickHamburger(_ sender: UIButton) {
        buttonModal.isHidden = false;
        viewMenu.isHidden = false;
        
        viewMenu.transform = CGAffineTransform(translationX: -viewMenu.frame.size.width, y: 0);
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.viewMenu.transform = CGAffineTransform.identity
        }, completion: { finished in
            
        });
    }
    
    @IBAction func onClickModal(_ sender: UIButton) {
        buttonModal.isHidden = true;
        viewMenu.isHidden = true;
    }
    
    @IBAction func onClickMail(_ sender: UIButton) {
        let email = "justriz81@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onClickAppleStore(_ sender: UIButton) {
        let url = "https://itunes.apple.com/kr/app/%EC%96%B4%EC%A0%9C%EB%82%A0%EC%94%A8/id1141633564?mt=8";
        openURL(strUrl: url);
    }
    
    @IBAction func onClickGithub(_ sender: UIButton) {
        let url = "https://github.com/justinaus";
        openURL(strUrl: url);
    }
    
    private func openURL( strUrl: String ) {
        guard let url = URL(string: strUrl) else {
            return;
        }
        
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            };
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
        
        buttonModal.isHidden = true;
        viewMenu.isHidden = true;
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
        
        guard let model = arrHourly[ indexPath.item ] as? HourlyEntity else {
            return cell;
        }
//        let model = arrHourly[ indexPath.item ] as! HourlyEntity;
        
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
        
        guard let model = arrDaily[ indexPath.item ] as? DailyEntity else {
            return cell;
        }
        // fabric crashed
//        let model = arrDaily[ indexPath.item ] as! DailyEntity;
        
        cell.setImageSkyByFileName(imageFileName: model.skyStatusImageName!);
        
        let max = NumberUtil.roundToInt(value: model.temperatureMax);
        let min = NumberUtil.roundToInt(value: model.temperatureMin);
        
        cell.setLabelTemperatureMaxMin(str: "\(max) / \(min)");
        
        let weekday = Calendar.current.component(.weekday, from: model.date!);
        cell.setLabelWeekday(str: DateUtil.getWeekdayString( weekday, .koreanOneLetter) );
        
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination;
        
        guard let vcAir = dest as? VCAir else {
            return;
        }
        
        vcAir.setData(airEntity: gridEntity?.air);
        
        super.prepare(for: segue, sender: sender)
    }
    
    override func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        return appDelegate.persistentContainer.viewContext;
    }
    
    override func saveContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.saveContext();
    }
    
    @IBAction func unwindToVC( _ unwindSegue: UIStoryboardSegue) {
        
    }
}

