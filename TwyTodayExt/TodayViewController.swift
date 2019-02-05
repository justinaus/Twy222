//
//  TodayViewController.swift
//  TwyTodayExt
//
//  Created by Bonkook Koo on 01/02/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: ViewControllerCore, NCWidgetProviding {
    
    @IBOutlet var viewMain: UIView!
    
    @IBOutlet var labelNowLocation: UILabel!
    @IBOutlet var labelNowTemperature: UILabel!
    @IBOutlet var labelNowCompareWithYesterday: UILabel!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageSkyStatus: UIImageView!
    
    @IBOutlet var viewAirQuality: UIView!
    @IBOutlet var labelPm10: UILabel!
    @IBOutlet var labelPm25: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = getContext();
        
        AppManager.shared.start(isMainApp: true);
        CoreDataManager.shared.setContext(context: context);
        
        showActivityIndicator(toShow: false)
        
        super.viewDidLoad();
        
        viewInit();
        
        // 시간 체크.
        
        startLocationManager();
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        viewMain.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "twy://") {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        print( 456 );
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func showActivityIndicator( toShow:Bool ) {
        activityIndicator.isHidden = !toShow;
        
        if( toShow ) {
            activityIndicator.startAnimating();
        } else {
            activityIndicator.stopAnimating();
        }
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
            
//            self.labelNowSkyStatus.text = nowEntity.skyStatusText;
            
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
    
    func viewInit() {
        labelNowLocation.text = "";
        labelNowTemperature.text = "";
        labelNowCompareWithYesterday.text = "";
        imageSkyStatus.isHidden = true;
        
        viewAirQuality.isHidden = true;
    }
    
    override func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext;
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Twy222")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    override func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
