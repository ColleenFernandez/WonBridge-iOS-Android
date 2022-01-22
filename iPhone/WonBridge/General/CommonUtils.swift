//
//  CommonUtils.swift
//  WonBridge
//
//  Created by Saville Briard on 16/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
import Foundation

class CommonUtils: NSObject {
    
    static var isSocialLogin: Bool = false
    
    static var wonbridgeTimeLine: TimeLineEntity?
    
    // check validation of email address
    class func isValidEmail(email: String!) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    // resize image to the size of 128x128
    class func resizeImage(srcImage: UIImage!, resize: CGSize) -> UIImage {
        
        return srcImage.resizedImageByMagick("128x128")
    }
    
    class func resizeImage(srcImage: UIImage) -> UIImage {
        
        if (srcImage.size.width >= srcImage.size.height) {
            
            return srcImage.resizedImageByMagick("256")
        } else {
            
            return srcImage.resizedImageByMagick("x256")
        }
    }
    
    // save image to a file (Documents/WonBridge/profile.png)
    class func saveToFile(image: UIImage!, filePath: String!, fileName: String) -> String! {
        
        let outputFileName = fileName
        
        let outputImage = CommonUtils.resizeImage(image)
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentDirectory: NSString! = paths[0]
        
        // current document directory
        fileManager.changeCurrentDirectoryPath(documentDirectory as String)
        
        do {
            try fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        documentDirectory = documentDirectory.stringByAppendingPathComponent(filePath)
        let savedFilePath = documentDirectory.stringByAppendingPathComponent(outputFileName)
        
        // if the file exists already, delete and write, else if create filePath
        if (fileManager.fileExistsAtPath(savedFilePath)) {
            do {
                try fileManager.removeItemAtPath(savedFilePath)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        } else {
            fileManager.createFileAtPath(savedFilePath, contents: nil, attributes: nil)
        }
        
        if let data = UIImagePNGRepresentation(outputImage) {
            data.writeToFile(savedFilePath, atomically: true)
        }
        
        return savedFilePath
    }
    
    class func saveImageToFile(srcImage: UIImage, filePath: String, fileName: String, resize: Bool) -> String {
        
        // set output file name and resize source image with output image size
        var outputImage = srcImage
        
        if resize {
            outputImage = CommonUtils.resizeImage(srcImage)
        }
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory: NSString! = paths[0]
        
        let uploadPath: NSString! = documentDirectory.stringByAppendingPathComponent(filePath)
        let saveFilePath = uploadPath.stringByAppendingPathComponent(fileName)
        
        // check if a file is exsiting
        if (!fileManager.fileExistsAtPath(saveFilePath)) {
            
            if (fileManager.createFileAtPath(saveFilePath, contents: nil, attributes: nil)) {
            }
        
            if let data = UIImagePNGRepresentation(outputImage) {                
                data.writeToFile(saveFilePath, atomically: true)
            }
        }
        
        return saveFilePath
    }
    
    class func deleteFile(filePath: String) -> Bool {
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory: NSString! = paths[0]
        
        let savedFilePath = documentDirectory.stringByAppendingPathComponent(filePath)
        
        // check if a file is exsiting
        if (fileManager.fileExistsAtPath(savedFilePath)) {
            
            do {
                try fileManager.removeItemAtPath(savedFilePath)
                
                return true
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
        
        return false
    }
    
//    class func saveVideoToFile(videoURL: NSURL!, filePath: String, fileName: String) -> String {
//        
//        let videoData = NSData(contentsOfURL: videoURL)
//        let myVideo = NSData(data: videoData!)
//        
//        let fileManager = NSFileManager.defaultManager()
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let documentDirectory: NSString! = paths[0]
//        
//        
//        let uploadPath: NSString! = documentDirectory.stringByAppendingPathComponent(filePath)
//        let saveFilePath = uploadPath.stringByAppendingPathComponent(fileName)
//        
//        // check if a file exists
//        if (!fileManager.fileExistsAtPath(saveFilePath)) {
//            
//            if (myVideo.writeToFile(saveFilePath, atomically: true)) {
//                
//                print("write video to a file")
//            }
//        }
//        
//        return saveFilePath
//    }
    
    class func saveVideoToFile(videoData: NSData, filePath: String, fileName: String) -> String {
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory: NSString! = paths[0]

        let uploadPath: NSString! = documentDirectory.stringByAppendingPathComponent(filePath)
        let saveFilePath = uploadPath.stringByAppendingPathComponent(fileName)
        
        // check if a file exists
        if (!fileManager.fileExistsAtPath(saveFilePath)) {
            
            if (videoData.writeToFile(saveFilePath, atomically: true)) {
                
                print("write video to a file")
            }
        }
        
        return saveFilePath
    }
    
    class func createUploadFolder() -> NSURL {
                
        let documentDirectory: NSString! = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        // Documents/WonBridge/upload_fies
        let uploadFolder = documentDirectory.stringByAppendingPathComponent(Constants.UPLOAD_FILE_PATH)
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(uploadFolder) {
            do {
                try fileManager.createDirectoryAtPath(uploadFolder, withIntermediateDirectories: true, attributes: nil)
                return NSURL(string: uploadFolder)!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        return NSURL(string: uploadFolder)!
    }
    
    class func createDownloadFolder() -> NSURL {
        
        let documentDirectory: NSString! = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        // Documents/WonBridge/upload_fies
        let downloadFolder = documentDirectory.stringByAppendingPathComponent(Constants.DOWNLOAD_FILE_PATH)
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(downloadFolder) {
            do {
                try fileManager.createDirectoryAtPath(downloadFolder, withIntermediateDirectories: true, attributes: nil)
                return NSURL(string: downloadFolder)!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        return NSURL(string: downloadFolder)!
   }

    class func isExistDownloadFile(fileName: String!) -> Bool {
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory: NSString! = paths[0]
        
        var downloadPath: NSString! = documentDirectory .stringByAppendingPathComponent(Constants.DOWNLOAD_FILE_PATH)
        downloadPath = downloadPath.stringByAppendingPathComponent(fileName)
        
        if (fileManager.fileExistsAtPath(downloadPath as String)) {
            
            return true
        }
        
        return false
    }
    
    class func ixExsitUploadFile(fileName: String!) -> Bool {
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory: NSString! = paths[0]
        
        var downloadPath: NSString! = documentDirectory .stringByAppendingPathComponent(Constants.UPLOAD_FILE_PATH)
        downloadPath = downloadPath.stringByAppendingPathComponent(fileName)
        
        if (fileManager.fileExistsAtPath(downloadPath as String)) {
            
            return true
        }
        
        return false
    }
    
    // set user loggedin-state
    // true if an user is loggedin
    // false if else
    class func setUserAutoLogin(isLoggedIn: Bool) {
        
        UserDefault.setBool(Constants.pref_user_loggedin, value: isLoggedIn)
    }
    
    class func getUserAutoLogin() -> Bool {
        
        return UserDefault.getBool(Constants.pref_user_loggedin, defaultValue: false)
    }

    class func vibrate() {
    
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))    
    }
    
    static let systemSoundID = 1007    
    class func playSound() {
        
        AudioServicesPlayAlertSound(UInt32(systemSoundID))
    }
    
    class func getRandomRoomNumber() -> Int {
        
        return Int(arc4random_uniform(99999)) + 100000
    }
    
    class func checkPermission(mediaType: String, completion: (granted: Bool) -> Void) {
        
        switch AVCaptureDevice.authorizationStatusForMediaType(mediaType) {
            
        case .Denied:
            
            completion(granted: false)
            
            break
            
        case .Authorized:
            
            completion(granted: true)
            
            break
            
        case .Restricted:
            
            completion(granted: false)
            
            break
            
        case .NotDetermined:
            
            // Prompting user for the permission to use the camera
            AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted) in
                
                if granted {
                    
                    completion(granted: true)
                    
                } else {
                    
                    completion(granted: false)
                }
            })
            break
        }
    }
    
    class func getCurrentLocale() -> String {
        
//        print(NSLocale.currentLocale().localeIdentifier)        
        return NSLocale.currentLocale().localeIdentifier
    }
    
    class func isCNLocale() -> Bool {
    
        if CommonUtils.getCurrentLocale().componentsSeparatedByString("_")[1] == Constants.LOCALE_CN {
            return true
        } else {            
            return false
        }
    }
    
    class func getDisplayCountryName(countryCode: String) -> String {
        let currentLocale = NSLocale.currentLocale()
        let countryName = currentLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)
        
        guard countryName != nil else { return "" }
        return countryName!
    }
    
    class func getDisplayCountryName() -> String? {
        let currentLocale = NSLocale.currentLocale()
        let countryCode = currentLocale.objectForKey(NSLocaleCountryCode)
        let countryName = currentLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode!)
        
        return countryName
    }
    
    class func getCountryCode() -> AnyObject? {
        let currentLocale = NSLocale.currentLocale()
        let countryCode = currentLocale.objectForKey(NSLocaleCountryCode)
        
//        if countryCode != nil {
//            print(countryCode!)
//        }
        
        return countryCode
    }
    
    class func uuidString() -> String {
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }    
}
















