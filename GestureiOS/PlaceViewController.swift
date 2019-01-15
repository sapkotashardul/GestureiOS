//
//  PlaceViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/14/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import MapKit
import os.log

class PlaceViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBAction func cancelToPlaceViewController(_ segue: UIStoryboardSegue) {
    }
    
    var place: String = "" {
        didSet {
            os_log("Choosing a new place.", log: OSLog.default, type: .debug)

            detailLabel.text = place
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.delegate = self
//        locationManager.delegate = self
        
//        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PlaceViewController.searchButtonAction(_:)))
//        self.navigationItem.rightBarButtonItem = searchButton
//        exoEar.initExoEar()
//        sampleTableView.dataSource = dataSource
//        sampleTableView.delegate = dataSource
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        nameTextField.delegate = self
//        if let gesture = gesture{
//            navigationItem.title = gesture.name
//            nameTextField.text = gesture.name
//            detailLabel.text = gesture.sensor
//            self.sampleFileNames = gesture.fileName ?? []
//            self.fileNameCount = gesture.uniqueFileCount ?? [:]
//            self.fileNameToUniqueName = gesture.uniqueFileName ?? [:]
//            self.dataSource.setData(sampleFileNames: self.sampleFileNames)
//            self.dataSource.setCount(fileDict: self.fileNameCount)
//            self.dataSource.setName(fileNameDict: self.fileNameToUniqueName)
//            self.flag = false
//        }
//
//
//        updateSaveButtonState()
        
//        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//
//        //2
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "Place")
        
        //3
//        do {
//            places = try managedContext.fetch(fetchRequest) as! [Place]
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == "PickPlace",
            let searchPlaceViewController = segue.destination as? SearchPlaceViewController {
//            searchPlaceViewController.selectedPlace = detailLabel.text //sensor
            
        }
        
        super.prepare(for: segue, sender: sender)
        
//        // Configure the destination view controller only when the save button is pressed.
//        guard let button = sender as? UIBarButtonItem, button === saveGesture else {
//            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
//            return
//        }
//
//        let gestureName = nameTextField.text ?? ""
//
//        save(gestureName: gestureName, gestureSensor: detailLabel.text ?? "", gestureFiles: self.dataSource.getData(), gestureFileCount: self.dataSource.getCount(), gestureUniqueFileName: self.dataSource.getName())
    }

    
    @IBAction func unwindWithSelectedPlace(segue: UIStoryboardSegue) {
        print("unwind!")
        let vc = segue.source as? SearchPlaceViewController
        print(vc?.selectedPlace)
        if let searchPlaceViewController = segue.source as? SearchPlaceViewController,
            let selectedPlace = searchPlaceViewController.dataSource.selectedPlace {
            print("hola")
            print(selectedPlace)
//            print("h")
//            print(selectedPlace.name)
//            print("h")
//            place = selectedPlace
//            print(place)
        }
    }


}
