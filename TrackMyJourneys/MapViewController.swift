//
//  MapViewController.swift
//  TrackMyJourneys
//
//  Created by Michele Fadda on 03/07/17.
//  Copyright © 2017 Michele Giuseppe Fadda. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {

    let kTrackingOnText = NSLocalizedString("TRACKING ON", comment: "")
    let kTrackingOffText = NSLocalizedString("TRACKING OFF", comment: "")
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // current path being shown
    var currentPath : [ CLLocationCoordinate2D ] = []
    var currentPolyline : MKPolyline?
    
    var lastLatitude: CLLocationDegrees?
    var lastLongitude: CLLocationDegrees?

    
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         mapView.delegate = self
        if appDelegate.isLocationUnavailable { // alert the user that location services are not available
            let alert = UIAlertController(title: "Alert", message: NSLocalizedString("Location services are not available", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Error!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupMap()
        
        // set Tracking Switch according to AppDelegate State
        trackingSwitch!.isOn=appDelegate.isTrackingEnabled
        if trackingSwitch.isOn {
            trackLabel.text=kTrackingOnText
        } else {
            trackLabel.text=kTrackingOffText
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func trackingSwitchChange(_ sender: UISwitch) {
        
        appDelegate.isTrackingEnabled = sender.isOn
        if sender.isOn {
            trackLabel.text = NSLocalizedString(kTrackingOnText, comment: "")
            currentPath=[]
            appDelegate.startLogging()
            
        } else {
            trackLabel.text = NSLocalizedString(kTrackingOffText, comment: "")
            appDelegate.stopLogging()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        // subscribe for UI refresh notifications
        NotificationCenter.default.addObserver(self, selector:  #selector(MapViewController.handleCoordinatesChange(notification:)), name: NSNotification.Name(kLocationUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(MapViewController.handlePathRecovery(notification:)), name: NSNotification.Name(kLocationsRecovered), object: nil)
    }

    // unsubscribe from notifications
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: MapView Delegate
    // delegate needed in order to display Polyline on MKMap
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // MARK: Map related methods
    // sets Map display options
    func setupMap() {
        
        mapView.showsUserLocation=true
        mapView.userTrackingMode=MKUserTrackingMode.follow
        
    }
    
    
    
    // centers Map at user CLLlocation coordinates
    func centerMapAt(location:CLLocation){
        print ("Center at location=\(location)")
        
        let regionRadius: CLLocationDistance = 200
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        if trackingSwitch.isOn {
            addPointToPath (location: location)
        }
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    // adds a location point to the current path.
    // if first point, creates a path
    func addPointToPath(location: CLLocation) {
        let coordinate2d=CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
        currentPath.append(coordinate2d)
        if(self.currentPolyline != nil) {
            self.mapView.remove(self.currentPolyline!)
        }
        
        var polylineCoords:[CLLocationCoordinate2D]=currentPath
        if (polylineCoords.count>1){
            if (currentPolyline != nil) {
                mapView.remove(currentPolyline!)
                currentPolyline=nil
            }
            self.currentPolyline = MKPolyline.init(coordinates: &polylineCoords, count: polylineCoords.count)
            
            
            mapView.add(currentPolyline!, level: MKOverlayLevel.aboveRoads)
        }
        
    }
    
    // handles change coordinates Notification
    func handleCoordinatesChange (notification: Notification)  {
        print (notification)
        let location = notification.object as! CLLocation
        centerMapAt(location: location)
        
    }
    
    // handles path recovery (when app is awakened from background)
    func handlePathRecovery (notification: Notification)  {
        guard let  locations = notification.object as? [CLLocationCoordinate2D] // unsafe cast!
            else { return }
            if (locations.count>1){
            self.currentPolyline = MKPolyline.init(coordinates: locations, count: locations.count)
            mapView.add(currentPolyline!, level: MKOverlayLevel.aboveRoads)
            }
        
    }
}

