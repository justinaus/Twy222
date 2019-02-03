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

enum EntityEnum: String {
    case Address = "Address";
    case Air = "Air";
    case Now = "Now";
    case Grid = "Grid";
    case Hourly = "Hourly";
    case Daily = "Daily";
    case Common = "Common";
}

final class CoreDataManager {
    static let shared = CoreDataManager();
    
    func getCommonEntity() -> CommonEntity? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        
        let entityEnum = EntityEnum.Common;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityEnum.rawValue)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request);
            
            if( result.count == 0 ) {
                return nil;
            }
            
            return result[0] as? CommonEntity;
        } catch {
            print("Failed")
            return nil;
        }
    }
    
    func getCurrentGridData() -> GridEntity? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        
        let entityEnum = EntityEnum.Grid;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityEnum.rawValue)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request);
            
            if( result.count == 0 ) {
                return nil;
            }
            
            return result[0] as? GridEntity;
        } catch {
            print("Failed")
            return nil;
        }
    }
    
    func saveDataInCurrentGrid( model: NSManagedObject, strKey: String ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        // 오류 내자 그냥.
        
        getCurrentGridData()?.setValue( model, forKey: strKey);
        
        appDelegate.saveContext();
    }
    
    func saveApiCompleteDate( dateComplete: Date ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        
        let entityEnum = EntityEnum.Common;
        
        appDelegate.deleteAllInEntity(entityEnum: entityEnum);
        
        let newEntity = CommonEntity(context: context);
        newEntity.dateCompleteAll = dateComplete;
        
        appDelegate.saveContext();
    }
    
    func getAddressTitle( address: AddressEntity? ) -> String? {
        guard let address = address else {
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
