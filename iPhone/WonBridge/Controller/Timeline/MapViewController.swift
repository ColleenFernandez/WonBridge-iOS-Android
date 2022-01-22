//
//  MapViewController.swift
//  WonBridge
//
//  Created by July on 2016-09-19.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import GoogleMaps

let kAnnotationMaxWidth: CGFloat = UIScreen.width / 2
let kAnnotationPaddingTopBottom: CGFloat = 5
let kAnnotationPaddingLeftRight: CGFloat = 10
let kAnnotationLabelMinHeight: CGFloat = 26
let kAnnotationLabelMarginBottom: CGFloat = 2

protocol ShowProfileFromMapDelegate {
    
    func showProfile(user: FriendEntity)
}

class MapViewController: BaseViewController {
    
    // global user - me
    var _user: UserEntity?
    
    var _nearbyUsers = [FriendEntity]()
    
    // baidu map view
    var mapView: BMKMapView!
    // baidu location service
    var locService: BMKLocationService!
    
    var googleMapView: GMSMapView!
    
    // map container
    @IBOutlet weak var rootMapView: UIView!
    
    var annotations = [UserAnnotation]()
    
    var nearbyUserMarker = [UserMapMarker]()
    
    // delegate to show user profile
    var showProfileDelegate: ShowProfileFromMapDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initData()
        
        initMapView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initData() {
        
        _user = WBAppDelegate.me
        
        if CommonUtils.isCNLocale() {
            
            for entity in _nearbyUsers {
                
                annotations.append(UserAnnotation(user: entity))
            }
            
        } else {
            
            for entity in _nearbyUsers {
                
                let marker = UserMapMarker(user: entity)
                
                nearbyUserMarker.append(marker)
            }
        }
    }
    
    func initMapView() {
        
        if CommonUtils.isCNLocale() {
            
            // add map
            mapView = BMKMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
            mapView.showsUserLocation = true
            mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading
            mapView.showMapScaleBar = true
            mapView.overlookEnabled = true
            mapView.zoomEnabled = true
            mapView.zoomLevel = 18
            
            self.rootMapView.addSubview(mapView)
            
        } else {
            
            // add google map
            let latitude = _user!.location != nil ? _user!.location!.latitude : 42.89526868
            let longitude = _user!.location != nil ? _user!.location!.longitude : 129.5605819
            
            let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 18)
            googleMapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height), camera: camera)
            googleMapView.myLocationEnabled = true
            
            googleMapView.settings.compassButton = true
            googleMapView.settings.scrollGestures = true
            googleMapView.settings.zoomGestures = true
            
            googleMapView.delegate = self
            
            rootMapView.addSubview(googleMapView)
        }
        
        startLocationService()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if CommonUtils.isCNLocale() {
           
            mapView.delegate = self
            locService.delegate = self
            
            for annotation in annotations {
                
                mapView.addAnnotation(annotation)
            }
            
        } else {
        
            googleMapView.delegate = self
            
            for marker in nearbyUserMarker {
                
                marker.map = googleMapView
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if CommonUtils.isCNLocale() {
        
            mapView.delegate = nil
            locService.delegate = nil
            
        } else {
            
            googleMapView.delegate = nil
        }
    }
    
    func startLocationService() {
        
        if CommonUtils.isCNLocale() {
            
            if locService == nil {
                
                locService = BMKLocationService()
            }
            
            locService.distanceFilter = 200
            locService.desiredAccuracy = kCLLocationAccuracyHundredMeters
            
            locService.delegate = self
            
            // start location service
            locService.startUserLocationService()
        }
    }
    
    func stopLocationService() {
        
        if CommonUtils.isCNLocale() {
            
            locService.delegate = nil
            locService.stopUserLocationService()
        }
    }
    
    @IBAction func reduceMapTapped(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // show my locataion
    @IBAction func showMyLocation(sender: AnyObject) {
        
        if _user!.location != nil {
            
            if CommonUtils.isCNLocale() {
                mapView.setCenterCoordinate(_user!.location!, animated: true)
            } else {
                googleMapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude( _user!.location!.latitude, longitude: _user!.location!.longitude, zoom: 18))
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK - BMKMapViewDelegate
extension MapViewController: BMKMapViewDelegate {
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {

        if !annotation.isKindOfClass(UserAnnotation) {
            
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("UserPin")
        
        let userAnnotation = annotation as! UserAnnotation
        
        if annotationView == nil {
            annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: "UserPin")
            annotationView.canShowCallout = true
        }
        
        if userAnnotation.user!._isPublic {
            if userAnnotation.user!._gender == .MALE {
                annotationView?.image = WBAsset.Map_Pin_Male.image
            } else {
                annotationView?.image = WBAsset.Map_Pin_Female.image
            }
        } else {
            annotationView.image = WBAsset.Map_Pin_No_Sex.image
        }
        
        guard userAnnotation.user!._isPublic else {
            annotationView.paopaoView = nil
            return annotationView
        }
        
        let infoLabel = UILabel(frame: CGRectZero)
        infoLabel.text = annotation.title!()
        infoLabel.font = UIFont.systemFontOfSize(14)
        infoLabel.textAlignment = .Center
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.setFrameWithString(annotation.title!(), width: kAnnotationMaxWidth)

        let strechImage = userAnnotation.user!._gender == .MALE ? WBAsset.Map_Info_Man.image : WBAsset.Map_Info_Woman.image
        let backImage = strechImage.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 10, 0, 10), resizingMode: .Stretch)
        let backImageView = UIImageView(frame: CGRectMake(0, 0, infoLabel.width +  kAnnotationPaddingLeftRight * 2, infoLabel.height + kAnnotationPaddingTopBottom * 2))
        backImageView.image = backImage
        
        let papaoView = UIView(frame: CGRectMake(0, 0, backImageView.width * 2, backImageView.height))
        papaoView.backgroundColor = UIColor.clearColor()
        papaoView.addSubview(backImageView)
        papaoView.addSubview(infoLabel)
        backImageView.center = CGPointMake(papaoView.width * 3 / 4, papaoView.centerY)
        infoLabel.center = CGPointMake(backImageView.centerX, backImageView.centerY - kAnnotationLabelMarginBottom)
        annotationView.paopaoView = BMKActionPaopaoView(customView: papaoView)
        
        return annotationView
    }
    
    func mapView(mapView: BMKMapView!, didSelectAnnotationView view: BMKAnnotationView!) {
        
    }
    
    func mapView(mapView: BMKMapView!, didDeselectAnnotationView view: BMKAnnotationView!) {
        
    }
    
    func mapView(mapView: BMKMapView!, annotationViewForBubble view: BMKAnnotationView!) {
        
        let userAnnotation = view.annotation as! UserAnnotation
        
        showProfileDelegate?.showProfile(userAnnotation.user!)
    }
    
    func mapView(mapView: BMKMapView!, viewForOverlay overlay: BMKOverlay!) -> BMKOverlayView! {
        
        return nil
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let userMarker = marker as! UserMapMarker
        
        guard userMarker.user!._isPublic else {
            return nil
        }        
        
        let infoLabel = UILabel(frame: CGRectZero)
        infoLabel.text = userMarker.title
        infoLabel.font = UIFont.systemFontOfSize(14)
        infoLabel.textAlignment = .Center
        infoLabel.textColor = UIColor.whiteColor()        
        infoLabel.setFrameWithString(userMarker.title!, width: kAnnotationMaxWidth)
        
        print("info label height: \(infoLabel.height)")
        
        let strechImage = userMarker.user!._gender == .MALE ? WBAsset.Map_Info_Man.image : WBAsset.Map_Info_Woman.image
        let backImage = strechImage.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 10, 0, 10), resizingMode: .Stretch)
        let backImageView = UIImageView(frame: CGRectMake(0, 0, infoLabel.width +  kAnnotationPaddingLeftRight * 2, infoLabel.height + kAnnotationPaddingTopBottom * 2))
        backImageView.image = backImage
        
        let infoView = UIView(frame: CGRectMake(0, 0, backImageView.width * 2, backImageView.height))
        infoView.backgroundColor = UIColor.clearColor()
        infoView.addSubview(backImageView)
        infoView.addSubview(infoLabel)
        backImageView.center = CGPointMake(infoView.width * 3 / 4, infoView.centerY)
        infoLabel.center = CGPointMake(backImageView.centerX, backImageView.centerY - kAnnotationLabelMarginBottom)
        
        return infoView
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        
        let userMarker = marker as! UserMapMarker
        
        showProfileDelegate?.showProfile(userMarker.user!)
    }
}

// BMKLocationServiceDelegate
extension MapViewController: BMKLocationServiceDelegate {
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        
        if userLocation != nil {
            
            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken) {
                
                self.mapView.updateLocationData(userLocation)
                
                self.mapView.setCenterCoordinate(userLocation.location.coordinate, animated: true)
                
                self._user!.location = CLLocationCoordinate2D(latitude: userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude)
                self._user!.saveUserLocation()                
                self.locService.stopUserLocationService()
            }
        }
    }
}







