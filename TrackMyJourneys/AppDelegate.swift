//
//  AppDelegate.swift
//  TrackMyJourneys
//
//  Created by Michele Fadda on 03/07/17.
//  Copyright © 2017 Michele Giuseppe Fadda. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        coreLocationManager.delegate=self
        coreLocationManager.requestAlwaysAuthorization()
        coreLocationManager.allowsBackgroundLocationUpdates=true
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        guard CLLocationManager.locationServicesEnabled()==true
            else {
                // Update your app’s UI to show that the location is unavailable.
                isLocationUnavailable=true
                return true
        }
        isLocationUnavailable=false
        coreLocationManager.startUpdatingLocation()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // stop using the battery if we are not logging the path
        if isTrackingEnabled==false{
            coreLocationManager.stopUpdatingLocation()
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        guard CLLocationManager.locationServicesEnabled()==false
            else {
                // Update your app’s UI to show that the location is unavailable.
                isLocationUnavailable=true
                return
        }
        isLocationUnavailable=false
        coreLocationManager.startUpdatingLocation()

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if isTrackingEnabled {
            NotificationCenter.default.post(name: Notification.Name(kLocationsRecovered), object: currentLocations)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TrackMyJourneys")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    
    
    // MARK Tracking Data
    
    var isTrackingEnabled = false
    var isLocationUnavailable = false
    
    var currentLocations: [CLLocation] = []

    var startTime:Date? = nil
    var stopTime:Date? = nil

    
    func startLogging(){
        isTrackingEnabled=true
        
        // start a new Journey
        startTime=Date()
        stopTime=nil
        currentLocations.removeAll()  // clear current path
        

    }
    
    func stopLogging(){
        isTrackingEnabled=false
        
        // end current Journey
        stopTime=Date()
        
        if currentLocations.count>1 {
            let context=persistentContainer.newBackgroundContext()
            let journeyObject = Journey(context: context)
            journeyObject.startDate=startTime! as NSDate
            journeyObject.endDate=stopTime! as NSDate
            for location in currentLocations {
                let pointObject = Point(context: context)
                pointObject.latitude = location.coordinate.latitude
                pointObject.longitude = location.coordinate.longitude
                pointObject.timestamp = location.timestamp as NSDate
                pointObject.speed=location.speed
                pointObject.altitude=location.altitude
                journeyObject.addToPoint(pointObject)
            }
            do {
                try context.save()
            } catch {
                print (error)
            }
            
        }
    }
    
    // MARK Core Location Manager and Position
    lazy var coreLocationManager = CLLocationManager()
    var currentCoordinates : (lat: CLLocationDegrees, lon: CLLocationDegrees) = (0,0)
    
    // MARK: Core Location Delegate
    
    //
    // App received location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print (locations)
        
        // filter CoreLocation notifications:
        // we are only interested in new coordinates
        for location in locations {
            let coordinates = (
                lat:location.coordinate.latitude,
                lon:location.coordinate.longitude )
            if currentCoordinates != coordinates { // are these new coordinates?
                currentCoordinates = coordinates
                
                // inform MapViewVontroller UI about new coordinates
                NotificationCenter.default.post(name: Notification.Name(kLocationUpdated), object: location)
                currentLocations.append(location)
            }
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print ("changed")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print ("calibration needed")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print ("updated heading")
        
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print ("paused updates")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print ("resumed updates")
    }

}

