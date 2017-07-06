//
//  InfoTableViewController.swift
//  TrackMyJourneys
//
//  Created by Michele Fadda on 07/07/17.
//  Copyright © 2017 Michele Giuseppe Fadda. All rights reserved.
//

import UIKit
import CoreLocation

class InfoTableViewController: UITableViewController {
    
    var locations = [CLLocation]() // array containing path information on Voyage
    
    @IBOutlet weak var numberOfPointsLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var maxAltitudeLabel: UILabel!
    @IBOutlet weak var minSpeedLabel: UILabel!
    @IBOutlet weak var minAltitudeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberOfPoints = locations.count
        numberOfPointsLabel.text = " \(numberOfPoints)"
        
        var speeds = [Double]()
        var altitudes = [Double]()
        
        for location in locations {
          speeds.append (location.speed)
          altitudes.append (location.altitude)
            
        }
        if let maxSpeed = speeds.max() {
            maxSpeedLabel.text = String(format: "%.2f", maxSpeed)
        }
        
        if let maxAltitude = altitudes.max() {
            maxAltitudeLabel.text = String(format: "%.2f", maxAltitude)
        }
        if let minSpeed = speeds.max() {
            minSpeedLabel.text = String(format: "%.2f", minSpeed)
        }
        
        if let minAltitude = altitudes.max() {
            minAltitudeLabel.text = String(format: "%.2f", minAltitude)
        }
        

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
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
