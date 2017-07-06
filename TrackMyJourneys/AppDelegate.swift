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

import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
 
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupSwiftyBeaverLogging()
        SwiftyBeaver.debug("Starting up App.")
        backgroundContext = persistentContainer.newBackgroundContext()
        
        coreLocationManager.delegate=self
        coreLocationManager.requestAlwaysAuthorization()
        coreLocationManager.allowsBackgroundLocationUpdates=true
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        guard CLLocationManager.locationServicesEnabled()==true
            else {
                // Update app’s UI to show that the location is unavailable.
                isLocationUnavailable=true
                SwiftyBeaver.debug("isLocationUnavailable=true")
                return true
        }
        isLocationUnavailable=false
        coreLocationManager.startUpdatingLocation()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        SwiftyBeaver.debug("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // stop using the battery if we are not logging the path
        if isTrackingEnabled==false || coreLocationManager.allowsBackgroundLocationUpdates==false {
            coreLocationManager.stopUpdatingLocation()
            SwiftyBeaver.debug("Background isTrackingEnabled==false ")
        } else if CLLocationManager.deferredLocationUpdatesAvailable() {
            // and use it as little as we can
            coreLocationManager.allowDeferredLocationUpdates(untilTraveled: 500, timeout: 5)
            SwiftyBeaver.debug("coreLocationManager.allowDeferredLocationUpdates(untilTraveled: 500, timeout: 5)")
        }
        SwiftyBeaver.debug("applicationDidEnterBackground")
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        SwiftyBeaver.debug("applicationDidEnterBackground start")
        guard CLLocationManager.locationServicesEnabled() != false
            else {
                // Update your app’s UI to show that the location is unavailable.
                isLocationUnavailable=true
                SwiftyBeaver.debug("isLocationUnavailable=true")
                return
            }
        isLocationUnavailable=false
        /*
        if CLLocationManager.deferredLocationUpdatesAvailable() && isTrackingEnabled {
            coreLocationManager.disallowDeferredLocationUpdates() // cancel deferred updates 
   
        } */
        
        coreLocationManager.startUpdatingLocation() // start normal location updates anyway

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SwiftyBeaver.debug("applicationDidBecomeActive")
        if isTrackingEnabled {
            SwiftyBeaver.debug("tracking enabled")
            guard currentLocations.count > 1 else {
                return
            }
            NotificationCenter.default.post(name: Notification.Name(kLocationsRecovered), object: currentLocations)
            SwiftyBeaver.info("currentlocations = \(currentLocations)")
        } else {
            SwiftyBeaver.debug("tracking not enabled")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        SwiftyBeaver.error("application will terminate")
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
                SwiftyBeaver.error("Unresolved error \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        SwiftyBeaver.debug("savecontext")
        
        if context.hasChanges {
            do {
                try context.save()
                SwiftyBeaver.debug("context.save OK")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                SwiftyBeaver.error("Unresolved error \(error), \(nserror.userInfo)")
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
    // MARK shared Core Data information
    var currentJourney: Journey? = nil
    var backgroundContext: NSManagedObjectContext?
    
    
    func startLogging(){
        SwiftyBeaver.debug("startLogging()")
        isTrackingEnabled=true
        SwiftyBeaver.debug("isTrackingEnabled=true")
        // start a new Journey
        startTime=Date()
        SwiftyBeaver.info("start time = \(startTime ?? startTime==nil)")
        stopTime=nil
        currentLocations.removeAll()  // clear current path
        if let context = backgroundContext {
            currentJourney = Journey(context: context)
            currentJourney?.startDate=startTime! as NSDate
        } else {
            SwiftyBeaver.error("could not assign background context")
        }

    }
    
    func stopLogging(){
        isTrackingEnabled=false
        
        // end current Journey
        stopTime=Date()
        
        if currentLocations.count>1 {
            if (currentJourney != nil)  {
                currentJourney!.endDate=stopTime! as NSDate
            
                do {
                    try currentJourney?.managedObjectContext?.save()
                } catch {
                    SwiftyBeaver.error("could not save CURRENT JOURNEY STOP! \(error)")
                }
            }
        }
        
    }
    
    func startLocationService() {
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            coreLocationManager.requestAlwaysAuthorization()
        } else {
            coreLocationManager.requestLocation()
        }
    }
    
    // MARK Core Location Manager and Position
    lazy var coreLocationManager = CLLocationManager()
    var currentCoordinates : (lat: CLLocationDegrees, lon: CLLocationDegrees) = (0,0)
    
    // MARK: Core Location Delegate
    
    
    

    
    

    
    // App received location error
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        SwiftyBeaver.error("received locations: \(String(describing: error))")
    }
    
    //
    // App received location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        SwiftyBeaver.warning("received locations: \(locations)")
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
                SwiftyBeaver.debug("location manager: isTrackingEnabled = \(isTrackingEnabled) ")
                guard isTrackingEnabled else { return }
                guard currentJourney != nil else { return }
                SwiftyBeaver.debug("location manager: currentJourney != nil")
                SwiftyBeaver.debug("location manager: currentJourney == \(String(describing: currentJourney)) ) ")
 
                currentLocations.append(location)
                    let pointObject = Point(context: currentJourney!.managedObjectContext!)
                    pointObject.latitude = location.coordinate.latitude
                    pointObject.longitude = location.coordinate.longitude
                    pointObject.timestamp = location.timestamp as NSDate
                    pointObject.speed=location.speed
                    pointObject.altitude=location.altitude
                
                    currentJourney!.addToPoint(pointObject)
                    SwiftyBeaver.warning ("currentJourney == \(String(describing: currentJourney))")
                do {
                
                    try currentJourney!.managedObjectContext!.save()
                    SwiftyBeaver.info("saved locations!")
                } catch {
                    SwiftyBeaver.error("DID NOT MANAGE TO SAVE LOCATIONS!")
                }

            }
        }
    }
    func locationManager(_ manager: CLLocationManager,  locations: [CLLocation]) {
        SwiftyBeaver.info("locations == \(locations)")
        // filter CoreLocation notifications:
        // we are only interested in new coordinates (we might get the same coordinates
        // repeatedly, with different precision)
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
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            coreLocationManager.startUpdatingLocation()
            print ("authorized")
        }
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
    
    // MARK Logging
    
    func setupSwiftyBeaverLogging() { /*
        let console = ConsoleDestination()
        SwiftyBeaver.addDestination(console)
        let platform = SBPlatformDestination(appID: "QxnjxR",
                                             appSecret: "wtJ3tmokOljnsh5hnpmtjcfjGmunr8dx",
                                             encryptionKey: "0vuFffugyzefscmvqtrtpFoCe1gcqVvW")
        
        SwiftyBeaver.addDestination(platform) */
    }


}

