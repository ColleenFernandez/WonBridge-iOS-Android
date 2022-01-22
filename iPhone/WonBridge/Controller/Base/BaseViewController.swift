//
//  BaseViewController.swift
//  WonBridge
//
//  Created by Saville Briard on 16/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import JLToast
import GoogleMaps

class BaseViewController: UIViewController {
    
    var googleGeocoder: GMSGeocoder!
    
    var geocodeSearch: BMKGeoCodeSearch!
    
    var geocodeCompletion: ((address: String) -> Void)?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.Portrait
    }
    
    // ungeocode
    // get address
    func getAddress(location: CLLocationCoordinate2D, completion: (address: String) -> Void) {
        
        geocodeCompletion = completion
        
        if CommonUtils.isCNLocale() {
            
            let unGeocodeSearchOption = BMKReverseGeoCodeOption()
            unGeocodeSearchOption.reverseGeoPoint = location
            
            let flag = geocodeSearch.reverseGeoCode(unGeocodeSearchOption)
            
            if flag {
                
                debugPrint("反 geo 检索发送成功")
                
            } else {
                debugPrint("反 geo 检索发送失败")
            }
            
        } else {
            
            googleGeocoder.reverseGeocodeCoordinate(location) { (response, error) in
                
                guard let address = response?.firstResult() else {return }
                
                var _address = ""
                if address.country != nil {
                    _address += address.country!
                }
                
                if address.administrativeArea != nil {
                    _address += address.administrativeArea!
                }
                
                if address.locality != nil {
                    _address += address.locality!
                }
                
                self.geocodeCompletion?(address: _address)
            }
        }
    }
    
    // show alert
    func showAlert(title: String!, message: String!, positive: String?, negative: String?, positiveAction: ((positiveAciton: UIAlertAction) -> Void)?, negativeAction: ((negativeAction: UIAlertAction) -> Void)?, completion:(() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .Default, handler: positiveAction))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .Default, handler: negativeAction))
        }
        
        self.presentViewController(alert, animated: true, completion: completion)
    }
    
    func showAlert(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .Default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .Default, handler: nil))
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // show loading view
    func showLoadingViewWithTitle(title: String) {
        
        if title == "" {
            
            WBProgressHUD.wb_show()
            
        } else {
        
            WBProgressHUD.wb_showWithStatus(title)
        }
    }
    
    // hide loading view
    func hideLoadingView() {
        
        WBProgressHUD.wb_dismiss()
    }

    // show toast message with duration
    func showToast(msg: String) {
        
        JLToast.makeText(msg, duration: TOAST_SHORT).show()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}

extension BaseViewController: BMKGeoCodeSearchDelegate {
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        
        guard error.rawValue == 0 else  { return }
        
        var address = ""
        if result.addressDetail.province != nil {
            address += result.addressDetail.province!
        }
        
        if result.addressDetail.city != nil {
            address += result.addressDetail.city!
        }
        
        geocodeCompletion?(address: address)
    }
}




