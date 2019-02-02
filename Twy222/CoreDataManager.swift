//
//  CoreDataManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 02/02/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager();
    
    func saveGridData( dateNow: Date, lon: Double, lat: Double ) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false;
        }
        
        let entityEnum = EntityEnum.Grid;
        
        // 일단 한개 지역만 유지.
        appDelegate.deleteAllInEntity(entityEnum: entityEnum)
        
        let context = appDelegate.persistentContainer.viewContext;

        let newObject = Grid(context: context);
        
        newObject.setValue( lat, forKey: "latitude")
        newObject.setValue( lon, forKey: "longitude")
        newObject.setValue( dateNow, forKey: "dateCalled")
        
        appDelegate.saveContext();
        
        return true;
    }
    
    func getCurrentGridData() -> Grid? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil;
        }
        
        let entityEnum = EntityEnum.Grid;
        
        let context = appDelegate.persistentContainer.viewContext;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityEnum.rawValue)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request);
            
            return result[0] as? Grid;
        } catch {
            print("Failed")
            return nil;
        }
    }
    
    func saveDataInCurrentGrid( model: NSManagedObject, strKey: String ) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false;
        }
        guard let gridData = getCurrentGridData() else {
            return false;
        }
        
        gridData.setValue( model, forKey: strKey);
        
        appDelegate.saveContext();
        return true;
    }
    
    func getAddressTitle() -> String? {
        guard let gridData = getCurrentGridData() else {
            return nil;
        }
        
        guard let address = gridData.address else {
            return nil;
        }
        
        var strAddress: String?;

        if let addressDong = address.addressDong {
            strAddress = addressDong;
        } else if let addressGu = address.addressGu {
            strAddress = addressGu;
        } else if let addressSiDo = address.addressSiDo {
            strAddress = addressSiDo;
        } else if let addressFull = address.addressFull {
            strAddress = addressFull;
        }

        return strAddress;
    }
}
