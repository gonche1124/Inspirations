//
//  Extras.swift
//  Inspirations
//
//  Created by Andres Gonzalez Casabianca on 8/27/18.
//  Copyright © 2018 Gonche. All rights reserved.
//

import Foundation
import CoreData
import Cocoa
import WebKit


//MARK: -
//Class used in NSMenuItems that need to store custom bool value.
class AGC_NSMenuItem: NSMenuItem {
    
    @IBInspectable var agcBool:Bool=false        //Used to define Favorites/Unfavorites in menu call
    @IBInspectable var customURLString:String="" //used for import controller popup item.
    @IBInspectable var representedType:String="" //Used for the rightclick menus of the left controller.
    
    ///Quick way to initialize with a specific boolean Value.
    convenience init(withBool:Bool) {
        self.init()
        self.agcBool=withBool
    }
    
}

//MARK: - Row template to be able to localize the interface and swho menaing text.
class CoreDataPredicateTemplate: NSPredicateEditorRowTemplate {
    
    static func templates(forCoreDataEntity entity:String, in moc:NSManagedObjectContext, includingRelationships relation:Bool?=false ) {
        
        
    }
    
    
    // String
    convenience init( stringCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: (Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)) )
    }
    
    // Int
    convenience init( IntCompareForKeyPaths keyPaths: [String], operators: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .integer16AttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    // Date
    convenience init( DateCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .dateAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    // Bool
    convenience init( BoolCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .booleanAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
}









