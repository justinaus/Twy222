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
    
    // 시작하자 마자 넘겨준다고 가정..
    public private(set) var context: NSManagedObjectContext?;
    
    public func setContext( context: NSManagedObjectContext ) {
        self.context = context;
    }
    
    func getCommonEntity() -> CommonEntity? {
        let entityEnum = EntityEnum.Common;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityEnum.rawValue)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context!.fetch(request);
            
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
        let entityEnum = EntityEnum.Grid;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityEnum.rawValue)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context!.fetch(request);
            
            if( result.count == 0 ) {
                return nil;
            }
            
            return result[0] as? GridEntity;
        } catch {
            print("Failed")
            return nil;
        }
    }
    
    func makeCommonEntityAferApiComplete( dateComplete: Date, isMainApp: Bool ) {
        let entityEnum = EntityEnum.Common;
        
        deleteAllInEntity(entityEnum: entityEnum);
        
        let newEntity = CommonEntity(context: context!);
        newEntity.dateCompleteAll = dateComplete;
        newEntity.isMainApp = isMainApp;
        
//        appDelegate.saveContext();
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
    
    public func deleteAllInEntity( entityEnum: EntityEnum ) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityEnum.rawValue)
        
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context!.fetch(request)
            for data in result as! [NSManagedObject] {
                context!.delete(data);
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
}
