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
import CoreLocation
import CoreData


protocol isAbleToReceivePlace {
    func pass(data:MKMapItem)
}

class MomentViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, isAbleToReceivePlace  {
    
    var delegate: isAbleToReceiveMoment?
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var subDetailLabel: UILabel!
    @IBOutlet weak var switchTime: UISwitch!
    @IBOutlet weak var switchPerson: UISwitch!
    @IBOutlet weak var switchPlace: UISwitch!
    @IBOutlet weak var textfieldName: UITextField!
    @IBOutlet weak var cellTime: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cellPerson: UITableViewCell!
    @IBOutlet weak var cellPlace: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.initMap()
        self.locateMe()
        if momentEdit != nil { return }
//        textfieldName.text = momentEdit.name
//        datePicker.date = momentEdit.time ?? Date()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
    }
    
    var timeEnabled: Bool = true
    var personEnabled: Bool = true
    var placeEnabled: Bool = true
    
    @IBAction func cancelAddMoment(_ sender: UIBarButtonItem) {
        print("cancelAddMoment")
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    var momentEdit: Moment!
    
    @IBAction func doneAddMoment(_ sender: Any) {
        print("doneAddMoment")
        let momentTime: Date = datePicker.date
        let momentPerson: String = ""
        guard let momentName = textfieldName.text else {
            return
        }
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Moment", in: managedContext)!
        let moment = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        moment.setValue(momentName, forKeyPath: "name")
        moment.setValue(momentTime, forKeyPath: "time")
        moment.setValue(momentPerson, forKey: "person")
        moment.setValue(placeName, forKey: "place")
        moment.setValue(coordinates.longitude, forKey: "lon")
        moment.setValue(coordinates.latitude, forKey: "lat")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        print(moment)

//        moment = Moment(name: String, time: Date, person: String, place: Place)
        self.delegate?.pass(moment:moment as! Moment)
        print("before dismiss")
        self.dismiss(animated: true, completion: nil)
        print("before after")
    }
    
    @IBAction func didToggleSwitch(_ sender: UISwitch) {
        let id: String = sender.restorationIdentifier!
        let state: Bool = sender.isOn
        switch id {
        case "switchTime":
            cellTime.isUserInteractionEnabled = state
            datePicker.isEnabled = state
            break
        case "switchPerson":
            personEnabled = state
            cellPerson.isUserInteractionEnabled = state
            cellPerson.textLabel?.isEnabled = state
            break
        case "switchPlace":
            placeEnabled = state
            cellPlace.isUserInteractionEnabled = state
            cellPlace.textLabel?.isEnabled = state
            mapView.isUserInteractionEnabled = state
            break
        default:
            print("weird al switch")
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    var location: MKMapItem!
    var locationManager = CLLocationManager()
    var locationInit: Bool = false
    var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    func locateMe() {
        print("locate me")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        
        if locationInit {
            return
        } else {
            locationInit = true
        }
        
        let userLocation: CLLocation = locations[0] as CLLocation
        
        //manager.stopUpdatingLocation()
        
        coordinates = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.setRegion(region, animated: true)

//        ClosestUserLocation()
        
        var geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude:  coordinates.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                self.placeName =  "Unable to Find Address for Location"

            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    self.placeName = placemark.compactAddress!
                } else {
                    self.placeName = "No Matching Addresses Found"
                }
            }

        }
    }
    
    
    func pass(data: MKMapItem) {
        print("received data")
        location = data
        placeName = data.name!
        coordinates = data.placemark.coordinate
//        let place: Place = Place(placeName, coordinates.longitude, coordinates.latitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        print("coordinates")
        print(coordinates)
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
//        annotation.title = "totulo"
//        //You can also add a subtitle that displays under the annotation such as
//        annotation.subtitle = "One day I'll go here..."
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }

    var placeName: String = "" {
        didSet {
            os_log("Choosing a new placeName.", log: OSLog.default, type: .debug)
            cellPlace.textLabel?.text = placeName
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModal" {
            print ("it is show modal")
            let nav = segue.destination as! UINavigationController
            let modalVC = nav.topViewController as! SelectPlaceTableViewController
            modalVC.delegate = self
            modalVC.placeName = placeName
        }

    }
}

extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var result = name
//            if let street = thoroughfare {
//                result += ", \(street)"
//            }
            if let city = locality {
                result += ", \(city)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return nil
    }
}
