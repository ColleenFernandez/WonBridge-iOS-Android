//
//  TimelineMapCell.swift
//  WonBridge
//
//  Created by Tiia on 31/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import GoogleMaps

let MYBUNDLE_NAME    =   "mapapi.bundle"

protocol TimeLineMapCellDelegate: class {
    func showUserProfile(user: AnyObject)
    func locationUpdated()
}

class TimeLineMapCell: UITableViewCell {
    
    var mapcellDelegate: TimeLineMapCellDelegate?
    
    var mapView: BMKMapView!
    var locService: BMKLocationService!
    
    var googleMapView: GMSMapView!
    var locManager: CLLocationManager!
    
    var _user: UserEntity?
    
    @IBOutlet weak var rootMapView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    
    var nearbyUserAnnotation = [UserAnnotation]()
    
    var nearbyUserMarker = [UserMapMarker]()
    
    @IBOutlet weak var lblRadius: UILabel!
    
    @IBOutlet weak var lblFriendCount: UILabel!
    
    var mapExtendAction: ((Void) -> Void)?
    
    let panGesture = UIPanGestureRecognizer()

    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        _user = WBAppDelegate.me
        
        infoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowRadius = 2
        
        if CommonUtils.isCNLocale() {
            // add baidu map
            mapView = BMKMapView(frame: CGRectMake(0, 0, UIScreen.width, 200))
            mapView.showsUserLocation = true
            mapView.userTrackingMode = BMKUserTrackingModeFollow
            mapView.showMapScaleBar = true
            mapView.overlookEnabled = true
            mapView.zoomLevel = 18
            rootMapView.addSubview(mapView)
            mapView.delegate = self

            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            self.contentView.addGestureRecognizer(panGesture)
            
            mapView.gesturesEnabled = true
            mapView.scrollEnabled = true
            mapView.zoomEnabled = true
            mapView.forceTouchEnabled = true
        } else {
            // add google map
            let latitude = _user!.location != nil ? _user!.location!.latitude : 42.89526868
            let longitude = _user!.location != nil ? _user!.location!.longitude : 129.5605819

            let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 18)
            googleMapView = GMSMapView.mapWithFrame(CGRectMake(0, 0,UIScreen.width, 200), camera: camera)
            googleMapView.myLocationEnabled = true

            googleMapView.settings.compassButton = true
            googleMapView.settings.scrollGestures = true
            googleMapView.settings.zoomGestures = true
            
            googleMapView.delegate = self
            
            rootMapView.addSubview(googleMapView)
        }
        
        startLocationService()
    }
    
    func setAction(action: ((Void) -> Void)?) {
        
        self.mapExtendAction = action
    }
    
    func setNearByUser(nearByUserList: [FriendEntity]) {
        
        var publicFriend = 0
        var privateFriend = 0

        for entity in nearByUserList {
            if entity._isPublic {
                publicFriend += 1
            } else {
                privateFriend += 1
            }
        }

        let allFriend = publicFriend + privateFriend

        lblFriendCount.text = "\(allFriend)" + Constants.UNIT_PEOPLE + " (" + Constants.INFO_PUBLIC + " \(publicFriend)" + Constants.UNIT_PEOPLE + ", " + Constants.INFO_NON_PUBLIC + " \(privateFriend)" + Constants.UNIT_PEOPLE + ")"

        let distance = UserDefault.getInt(Constants.PREFKEY_DISTANCE, defaultValue: 10)
        lblRadius.text = Constants.INFO_RADIUS + "\(distance)km" + Constants.INFO_IN_FRIEND

        if CommonUtils.isCNLocale() {

            nearbyUserAnnotation.removeAll()
            for entity in nearByUserList {
                nearbyUserAnnotation.append(UserAnnotation(user: entity))
            }
            // remove original markers
            mapView.removeAnnotations(mapView.annotations)
            // add new markers
            mapView.addAnnotations(nearbyUserAnnotation)

        } else {

            nearbyUserMarker.removeAll()
            googleMapView.clear()
            
            for entity in nearByUserList {
                
                let marker = UserMapMarker(user: entity)
                marker.map = googleMapView
                nearbyUserMarker.append(marker)
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            
        } else {
            
            if locManager == nil {
                locManager = CLLocationManager()
            }
            
            locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locManager.distanceFilter = 200
            
            locManager.requestWhenInUseAuthorization()
            
            locManager.delegate = self
            locManager.startUpdatingLocation()
        }
    }
    
    func stopLocationService() {
        
        if CommonUtils.isCNLocale() {
            
            locService.delegate = nil
            locService.stopUserLocationService()
            
        } else {
            
            locManager.delegate = nil
            locManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func myLocationButtonTapped(sender: AnyObject) {
    
        startLocationService()
    }
    
    @IBAction func showLargeMap(sender: AnyObject) {
        
        self.mapExtendAction!()
    }

}

// MARK - BMKMapViewDelegate
extension TimeLineMapCell: BMKMapViewDelegate {
    
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
        
        guard view.annotation.isKindOfClass(UserAnnotation) else { return }
        
        let userAnnotation = view.annotation as! UserAnnotation        
        mapcellDelegate?.showUserProfile(userAnnotation)
    }
}


extension TimeLineMapCell: GMSMapViewDelegate {

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
        
        mapcellDelegate?.showUserProfile(userMarker)
    }
}

// MARK: - BMKLocationServiceDelegate
extension TimeLineMapCell: BMKLocationServiceDelegate {

    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {

        if userLocation != nil {

            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken) {

                self.mapView.updateLocationData(userLocation)

                self.mapView.setCenterCoordinate(userLocation.location.coordinate, animated: true)

                self._user!.location = CLLocationCoordinate2D(latitude: userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude)
                self._user!.saveUserLocation()

                self.locService.stopUserLocationService()
                
                self.mapcellDelegate?.locationUpdated()

//                self.syncMyLocationToServer()
            }
        }
    }
}

extension TimeLineMapCell: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let newLocation = locations.last

        guard newLocation != nil else { return }

        var onceToken: dispatch_once_t = 0
        dispatch_once (&onceToken) {

            self._user!.location = CLLocationCoordinate2D(latitude: newLocation!.coordinate.latitude, longitude: newLocation!.coordinate.longitude)
            self._user!.saveUserLocation()

            self.googleMapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude( newLocation!.coordinate.latitude, longitude: newLocation!.coordinate.longitude, zoom: 18))

            self.stopLocationService()
            
            self.mapcellDelegate?.locationUpdated()

//            self.syncMyLocationToServer()
        }
    }
}








