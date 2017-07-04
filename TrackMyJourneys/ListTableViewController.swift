//
//  ListTableViewController.swift
//  TrackMyJourneys
//
//  Created by Michele Fadda on 04/07/17.
//  Copyright © 2017 Michele Giuseppe Fadda. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ListTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    var selectedPath = [CLLocationCoordinate2D]()
    
    // MARK CORE DATA
    var fetchedResultsController : NSFetchedResultsController<Journey>!
    var managedContext : NSManagedObjectContext!
    
    func setupFetchedResultsController (){
        let journeyRequest : NSFetchRequest<Journey> = Journey.fetchRequest()
        journeyRequest.returnsObjectsAsFaults=false
        let sortDescriptor =  NSSortDescriptor(key: "startDate", ascending: true)
        journeyRequest.sortDescriptors=[sortDescriptor]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: journeyRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate=self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print (error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        setupFetchedResultsController()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo=sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let journeyObject = fetchedResultsController.object(at: indexPath)
        let startTime = journeyObject.startDate
        let endTime = journeyObject.endDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startString = formatter.string(from: (startTime! as Date))
        let endString = formatter.string(from: (endTime! as Date))
        
        cell.textLabel!.text = "Start "+startString
        cell.detailTextLabel?.text="Stop "+endString
        
        cell.accessoryType=UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
        
        // prepare path of selected Journey
        let journey:Journey = fetchedResultsController.object(at: selectedIndex!)
        if let listOfPoints = journey.point {
            print (listOfPoints)
            var listOfLocations=[CLLocationCoordinate2D]()
            for point in listOfPoints {
                let aPoint = (point as! Point)
                print (aPoint.latitude)
                print (aPoint.longitude)
                let location = CLLocationCoordinate2D(latitude: aPoint.latitude, longitude: aPoint.longitude)
                listOfLocations.append(location)
            }
            selectedPath=listOfLocations
        }
        
        if (segue.identifier=="detailMapSegue"){
            let vc  = segue.destination as! DetailMapViewController
            vc.currentPath = selectedPath
        }
    }
    
    

}
