//
//  SearchPlaceViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/14/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class SearchPlaceViewController: UITableViewController {
    
//    @IBOutlet weak var tableView: UITableView!

    private var searchController:UISearchController = UISearchController()
    
    private let manager = CLLocationManager()
    
    let dataSource = MapDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Do any additional setup after loading the view.
        searchController =  UISearchController(searchResultsController:nil)
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController.searchBar.delegate = dataSource
        searchController.isActive = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
//
//        title = "Location Search"
//        
        dataSource.delegate = self
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        manager.delegate = dataSource
        print(selectedPlace)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            
            manager.requestWhenInUseAuthorization()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var selectedPlace: MKMapItem? {
        didSet {
            let selectedPlace = dataSource.selectedPlace
            print("didSet")
            print(selectedPlace)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "SaveSelectedPlace",
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                return
        }
        
        let index = indexPath.row
        selectedPlace = dataSource.selectedPlace
    }
}


extension SearchPlaceViewController:MapDataSourceDelegate {
    func refreshData() {
        self.tableView.reloadData()
    }
    func setPlace(place: MKMapItem) {
        selectedPlace = place
    }
}



