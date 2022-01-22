//
//  ImageFileManager.swift
//  WonBridge
//
//  Created by July on 2016-09-27.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import Kingfisher
import AVFoundation

/*
 围绕 Kingfisher 构建的缓存器，先预存图片名称，等待上传完毕后改成 URL 的名字。
 https://github.com/onevcat/Kingfisher/blob/master/Sources%2FImageCache.swift#l625
 */

private let kChatDownloadFolder     =   "ChatDownloadFolder"
private let kChatUploadFolder       =   "ChatUploadFolder"
private let kImageFileTypeJpg       =   "jpg"
private let kImageFileTypePng       =   "png"

class ImageFilesManager {
    let imageCacheFolder = KingfisherManager.sharedManager.cache
    
    class func cachePathForKey(key: String) -> String? {
        let fileName = key.MD5String
        return (KingfisherManager.sharedManager.cache.diskCachePath as NSString).stringByAppendingPathComponent(fileName)
    }
    
    class func storeImage(image: UIImage, key: String, completionHandler: (() -> ())?) {
        KingfisherManager.sharedManager.cache.removeImageForKey(key)
        KingfisherManager.sharedManager.cache.storeImage(image, forKey: key, toDisk: true, completionHandler: completionHandler)
    }
    
    class func uploadPathWithName(fileName: String) -> NSURL {
        let filePath = self.uploadFilesFolder.URLByAppendingPathComponent("\(fileName).\(kImageFileTypeJpg)")
        return filePath
    }
    
    class func downloadPathWithName(fileName: String) -> NSURL {
        let filePath = self.downloadFilesFolder.URLByAppendingPathComponent("\(fileName).\(kImageFileTypeJpg)")
        return filePath
    }
    
    private class var uploadFilesFolder: NSURL {
        get { return self.createUploadFolder()}
    }
    
    private class var downloadFilesFolder: NSURL {
        get { return self.createDownloadFolder()}
    }
    
    class private func createUploadFolder() -> NSURL {
        
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
    
    class private func createDownloadFolder() -> NSURL {
        
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
       
    /**
     修改文件名称
     
     - parameter originPath:      原路径
     - parameter destinationPath: 目标路径
     
     - returns: 目标路径
     */
    class func renameFile(originPath: NSURL, destinationPath: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().moveItemAtPath(originPath.path!, toPath: destinationPath.path!)
            return true
        } catch let error as NSError {
            debugPrint("error:\(error)")
            return false
        }
    }
    
//    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
//    
//    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
    
    // from local path
//    class func getThumbnailForVideoURL(videoURL: NSURL, atInterval: Int) -> UIImage? {
//        
//        let asset = AVAsset(URL: videoURL)
//        var thumnailTime = asset.duration
//        thumnailTime.value = 0
//        
//        // get image from the video at the given time
//        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
//        
//        do {
//            let imageRef = try assetImageGenerator.copyCGImageAtTime(thumnailTime, actualTime: nil)
//            let thumbnail = UIImage(CGImage: imageRef)
//            return thumbnail
//        } catch {
//            //catch error: return some placeholder image
//        }
//        
//        return nil
//    }
//      from internet
    class func getThumbnailForVideoURL(videoURL: NSURL, atInterval: Int) -> UIImage? {
        
        let asset = AVAsset(URL: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(atInterval), 100)
        do {
            let img = try assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
            let frameImg = UIImage(CGImage: img)
            return frameImg
        } catch {
            //catch error: return some placeholder image
        }
        
        return nil
    }
}

