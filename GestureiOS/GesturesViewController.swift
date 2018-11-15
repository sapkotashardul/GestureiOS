//
//  GesturesViewController.swift
//  GestureiOS
//
//  Created by fluid on 11/8/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit
import CoreData
import os.log



class GesturesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
       navigationItem.leftBarButtonItem = editButtonItem
  
        // Set up views if editing an existing Meal.
    }

    // MARK: - Table view data source
    
    var gestures = [Gesture]() //SampleData.generateGesturesData()
    //var gestures: [NSManagedObject] = []//[Gesture]() //SampleData.generateGesturesData()
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tableView(_ tableView: UITableView,
//                            commit editingStyle: UITableViewCell.EditingStyle,
//                            forRowAt indexPath: IndexPath) {
//       gestures.remove(at: indexPath.row)
//
//        let indexPaths = [indexPath]
//        tableView.deleteRows(at: indexPaths, with: .automatic)
//    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            gestures.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

 
  /*  // MARK: - Navigation
    func prepare(for segue: UIStoryboardSegue, sender: Any?, cellForRowAt indexPath: IndexPath)  {
        if segue.identifier == "EditGesture",
            let gestureDetailsViewController = segue.destination as? GestureDetailsViewController {
            gestureDetailsViewController.gesture = Gesture(name: gestures[indexPath.row].name, sensor: gestures[indexPath.row].sensor)
            //gestureDetailsViewController.` = gestures[indexPath.row].name
            //gestureDetailsViewController.sensor = "gestures[indexPath.row].sensor"
        }
}
 */
 
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
     
        switch(segue.identifier ?? "") {
            
        case "AddGesture":
            os_log("Adding a new gesture.", log: OSLog.default, type: .debug)

        case "EditGesture":
            guard let gestureDetailsViewController = segue.destination as? GestureDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedGestureCell = sender as? GestureTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedGestureCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedGesture = gestures[indexPath.row]
            gestureDetailsViewController.gesture = selectedGesture
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
            
        }
}
    
    @IBAction func cancelToGesturesViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveGestureDetail(_ segue: UIStoryboardSegue) {
        
        if let gestureDetailsViewController = segue.source as? GestureDetailsViewController,
            let gesture = gestureDetailsViewController.gesture {
     
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Update an existing meal.
                    gestures[selectedIndexPath.row] = gesture
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
                else {
                    // Add a new meal.
                    let newIndexPath = IndexPath(row: gestures.count, section: 0)
                    
                    gestures.append(gesture)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
   
//
//        // add the new player to the players array
//        gestures.append(gesture)
//
//        // update the tableView
//        let indexPath = IndexPath(row: gestures.count - 1, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }
    
}


extension GesturesViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gestures.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "GestureCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GestureTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GestureTableViewCell.")
        }
        
        // Configure the cell...

        let gesture = gestures[indexPath.row]
        cell.textLabel?.text = gesture.name
        cell.detailTextLabel?.text = gesture.sensor
        return cell
    }

    
    }


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



