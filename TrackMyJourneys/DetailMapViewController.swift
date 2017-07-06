//
//  DetailMapViewController.swift
//  TrackMyJourneys
//
//  Created by Michele Fadda on 04/07/17.
//  Copyright © 2017 Michele Giuseppe Fadda. All rights reserved.
//

import UIKit
import MapKit

class DetailMapViewController: UIViewController,MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // current path being shown
    var currentPath : [ CLLocationCoordinate2D ] = []
    var currentPolyline : MKPolyline?
    var startDate : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupMap()
        
        // setup polyline and add it as an overlay to the map
        if (currentPath.count>1){
            self.currentPolyline = MKPolyline.init(coordinates: &currentPath, count: currentPath.count)
            mapView.add(currentPolyline!, level: MKOverlayLevel.aboveRoads)
            centerMapAt(location: currentPath[0]) // set map at beginning of journey
        }
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    // MARK: MapView Delegate
    // delegate needed in order to display Polyline on MKMap
    
    // polyline renderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    // MARK: Map related methods
    // sets Map display options
    func setupMap() {
        
        mapView.showsUserLocation=false
        mapView.userTrackingMode=MKUserTrackingMode.none
        
    }
    
    
    // centers Map at user CLLlocation coordinates
    func centerMapAt(location:CLLocationCoordinate2D){
        print ("Center at location=\(location)")
        
        let regionRadius: CLLocationDistance = 200
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius * 2.0, regionRadius * 2.0)

        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }

}
