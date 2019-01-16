//
//  MomentViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/14/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import MapKit
import os.log


protocol isAbleToReceiveData {
    func pass(data:MKMapItem)
}

class MomentViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, isAbleToReceiveData {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var subDetailLabel: UILabel!
    var location: MKMapItem!
    
 
    func pass(data: MKMapItem) {
        print("received data")
        place = data.name!
        
    }
    
    var place: String = "" {
        didSet {
            os_log("Choosing a new place.", log: OSLog.default, type: .debug)
            detailLabel.text = place
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModal" {
            print ("it is show modal")
            let nav = segue.destination as! UINavigationController
            let modalVC = nav.topViewController as! SelectPlaceTableViewController
            modalVC.delegate = self
        }

    }

}
