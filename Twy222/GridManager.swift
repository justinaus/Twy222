//
//  GridManager.swift
//  Twy222
//
//  Created by Bonkook Koo on 05/01/2019.
//  Copyright © 2019 justinaus. All rights reserved.
//

import Foundation

// 지역 관리 클래스.
// 나중에 여러 지역 추가, 관리 기능 예정.
// 일단은 한 개 지역만 구현하겠다.
final class GridManager {
    static let shared = GridManager();
    
    private var list: [ GridModel ] = [];
    private var currentIndex = 0;
    
    
    public func setCurrentGridModel( gridModel:GridModel ) {
        currentIndex = 0;
        
        list.insert(gridModel, at: 0);
    }
    
    
    public func getCurrentGridModel() -> GridModel? {
        if( list.count < 1 ) {
            return nil;
        }
        
        return list[ currentIndex ];
    }
    
//    public func setCurrentIndex( toIndex:Int ) {
//        currentIndex = toIndex;
//    }
//    
//    public func addGrid( model: GridModel ) {
//        if( getHasAlreadyByCode( model: model ) ) {
//            return;
//        }
//
//        list.append( model );
//    }
//
//    private func getHasAlreadyByCode( model: GridModel ) -> Bool {
//        for i in 0..<list.count {
//            let old = list[ i ];
//
//            if( old.id == model.id ) {
//                return true;
//            }
//        }
//
//        return false;
//    }
    
}
