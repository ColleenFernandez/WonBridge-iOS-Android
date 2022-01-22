//
//  UserDefault.swift
//  WonBridge
//
//  Created by Tiia on 26/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let WBDefautls = NSUserDefaults.standardUserDefaults()

class UserDefault: NSObject {
    
    class func getObject(key: String) -> AnyObject? {
        return WBDefautls.objectForKey(key)
    }
    
    class func getInt(key: String) -> Int {
        return WBDefautls.integerForKey(key)
    }
    
    class func getBool(key: String) -> Bool {
        return WBDefautls.boolForKey(key)
    }
    
    class func getFloat(key: String) -> Float {
        return WBDefautls.floatForKey(key)
    }
    
    class func getString(key: String) -> String? {
        return WBDefautls.stringForKey(key)
    }
    
    class func getData(key: String) -> NSData? {
        return WBDefautls.dataForKey(key)
    }
    
    class func getArray(key: String) -> NSArray? {
        return WBDefautls.arrayForKey(key)
    }
    
    class func getDictionary(key: String) -> NSDictionary? {
        return WBDefautls.dictionaryForKey(key)
    }
    
    // MARK: - getter 获取 Value 带上默认值
    class func getObject(key: String, defaultValue: AnyObject) -> AnyObject? {
        if getObject(key) == nil {
            return defaultValue ?? ""
        }
        return getObject(key)
    }
    
    class func getInt(key: String, defaultValue: Int) -> Int {
        if getObject(key) == nil {
            return defaultValue
        }
        return getInt(key)
    }
    
    class func getBool(key: String, defaultValue: Bool) -> Bool {
        if getObject(key) == nil {
            return defaultValue
        }
        return getBool(key)
    }
    
    class func getFloat(key: String, defaultValue: Float) -> Float {
        if getObject(key) == nil {
            return defaultValue
        }
        return getFloat(key)
    }
    
    class func getString(key: String, defaultValue: String) -> String? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getString(key)
    }
    
    class func getData(key: String, defaultValue: NSData) -> NSData? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getData(key)
    }
    
    class func getArray(key: String, defaultValue: NSArray) -> NSArray? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getArray(key)
    }
    
    class func getDictionary(key: String, defaultValue: NSDictionary) -> NSDictionary? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getDictionary(key)
    }
    
    
    // MARK: - Setter
    class func setObject(key: String, value: AnyObject?) {
        if value == nil {
            WBDefautls.removeObjectForKey(key)
        } else {
            WBDefautls.setObject(value, forKey: key)
        }
        WBDefautls.synchronize()
    }
    
    class func setInt(key: String, value: Int) {
        WBDefautls.setInteger(value, forKey: key)
        WBDefautls.synchronize()
    }
    
    class func setBool(key: String, value: Bool) {
        WBDefautls.setBool(value, forKey: key)
        WBDefautls.synchronize()
    }
    
    class func setFloat(key: String, value: Float) {
        WBDefautls.setFloat(value, forKey: key)
        WBDefautls.synchronize()
    }
    
    class func setString(key: String, value: NSString?) {
        if (value == nil) {
            WBDefautls.removeObjectForKey(key)
        } else {
            WBDefautls.setObject(value, forKey: key)
        }
        WBDefautls.synchronize()
    }
    
    class func setData(key: String, value: NSData) {
        setObject(key, value: value)
    }
    
    class func setArray(key: String, value: NSArray) {
        setObject(key, value: value)
    }
    
    class func setDictionary(key: String, value: NSDictionary) {
        setObject(key, value: value)
    }
    
    // MARK: - Synchronize
    class func Sync() {
        WBDefautls.synchronize()
    }
}
