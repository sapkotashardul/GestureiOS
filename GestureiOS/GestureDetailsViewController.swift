//
//  GestureDetailsViewController.swift
//  GestureiOS
//
//  Created by fluid on 11/8/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit
import os.log
import CoreMotion
import CoreData
import MessageUI


class GestureDetailsViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    var gesture: Gesture?
    let motion = CMMotionManager()
    var timer: Timer = Timer()
    var flag = true
    var sensorData = [String]()
    var sampleFileNames: [String] = ["TestData"]//[String]()
    var nameToSave: String = ""
    var fileNameCount: [String: Int] = [:]
    
    var sensor: String = "Accelerometer" {
        didSet {
            detailLabel.text = sensor
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    
    
    @IBOutlet weak var detailLabel: UILabel!
    
    
    @IBOutlet weak var saveGesture: UIBarButtonItem!
    
    
    @IBOutlet weak var sampleTableView: UITableView!
    
    var dataSource = DynamicDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleTableView.dataSource = dataSource
        sampleTableView.delegate = dataSource
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        nameTextField.delegate = self
        if let gesture = gesture{
            navigationItem.title = gesture.name
            nameTextField.text = gesture.name
            detailLabel.text = gesture.sensor
            self.sampleFileNames = gesture.fileName ?? []
            self.fileNameCount = gesture.uniqueFileCount ?? [:]
            self.dataSource.setData(sampleFileNames: self.sampleFileNames)
            self.dataSource.setCount(fileDict: self.fileNameCount)
            self.flag = false
        }
        
        
        updateSaveButtonState()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    deinit {
        print("deinit GestureDetailsViewController")
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == "PickSensor",
            let sensorPickerViewController = segue.destination as? SensorPickerViewController {
            sensorPickerViewController.selectedSensor = detailLabel.text //sensor
        }
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveGesture else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let gestureName = nameTextField.text ?? ""
        
        save(gestureName: gestureName, gestureSensor: detailLabel.text ?? "", gestureFiles: self.dataSource.getData(), gestureFileCount: self.dataSource.getCount())
    }
    
    func save(gestureName: String, gestureSensor: String, gestureFiles: [String], gestureFileCount: [String: Int]){
        // 1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        if self.flag{
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Gesture",
                                       in: managedContext)!
        
        self.gesture = Gesture(entity: entity,
                               insertInto: managedContext)
        
        self.gesture?.name = gestureName
        self.gesture?.sensor = gestureSensor
        self.gesture?.fileName = gestureFiles
        self.gesture?.uniqueFileCount = gestureFileCount
            
        }
        else{
        if let id = self.gesture?.objectID {
            do{
            try self.gesture = managedContext.existingObject(with: id) as? Gesture
                self.gesture?.name = gestureName
                self.gesture?.sensor = gestureSensor
                self.gesture?.fileName = gestureFiles
                self.gesture?.uniqueFileCount = gestureFileCount
            } catch {
                print("Error loading and editing existing CoreData object")
            }
            }
        }
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveGesture.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    func saveToFile(fileName: String, stringToWrite: [String]){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("txt")
            print("File Path: \(fileURL.path)")
            
            let stringToWrite = stringToWrite.joined(separator: "\n")
            try stringToWrite.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            print(error)
        }
        
    }
    

    @IBAction func addSample(_ sender: Any) {

        let firstAlertController = UIAlertController(
            title: "Add a Sample",
            message: "Start sampling your data below",
            preferredStyle: UIAlertController.Style.alert)
        
        let secondAlertController = UIAlertController(
            title: "Recording Sample",
            message: "Recording....",
            preferredStyle: UIAlertController.Style.alert)
        
        
        let thirdAlertController = UIAlertController(
            title: "Save",
            message: "Enter the recording label",
            preferredStyle: UIAlertController.Style.alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                        guard let textField = thirdAlertController.textFields?.first
                                        else {
                                                return
                                            }
                                        self.nameToSave = textField.text as! String
                                        
                                        
                                        self.sampleFileNames = self.dataSource.getData()
                                        self.fileNameCount = self.dataSource.getCount()
                                        let newIndexPath = IndexPath(row: self.sampleFileNames.count, section: 0)
                                        
                                        //make filename unique
                                        
                                        if self.sampleFileNames.contains(self.nameToSave){
                                            if self.fileNameCount[self.nameToSave] == nil {
                                                self.fileNameCount[self.nameToSave] = 1
                                            } else {
                                                if let count = self.fileNameCount[self.nameToSave]
                                                {
                                                    self.fileNameCount[self.nameToSave] = count + 1
                                                }
                                            }
                                            if let count = self.fileNameCount[self.nameToSave]{
                                                self.nameToSave = self.nameToSave + "-\(count)"
                                            }
                                        }
                                        
                                        self.sampleFileNames.append(self.nameToSave)
                                        
                                        self.dataSource.setData(sampleFileNames: self.sampleFileNames)
                                        self.dataSource.setCount(fileDict: self.fileNameCount)
                                        print("name of file", self.nameToSave)
                                        
                                        self.saveToFile(fileName: self.nameToSave, stringToWrite: self.sensorData)
                                        self.sensorData = []
                                        
                                        self.sampleTableView.beginUpdates()
                                        self.sampleTableView.insertRows(at: [newIndexPath], with: .automatic)
                                        self.sampleTableView.endUpdates()
                                    }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        thirdAlertController.addTextField()
        
        thirdAlertController.addAction(saveAction)
        thirdAlertController.addAction(cancelAction)
        

        secondAlertController.addAction(UIAlertAction(title: "Stop", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
                print("STOP")
                self.motion.stopAccelerometerUpdates()
                print("sensorData", self.sensorData)
            
                //create a third alert view here to get the file name and save it
            
                self.present(thirdAlertController, animated: true, completion: nil)
                //self.sensorData = []
                //save the .txt file here and update the table view row
        }))
        
        secondAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
            print("CANCEL")
            self.motion.stopAccelerometerUpdates()
            print("sensorData", self.sensorData)
            self.sensorData = []
        }))

        
        // work on cancelling accelerometer updates ...
        
        
        firstAlertController.addAction(UIAlertAction(title: "Start", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
            print ("START")
            
            func startAccelerometers(){
                // Make sure the accelerometer hardware is available.
                if self.motion.isAccelerometerAvailable {
                    self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
                    self.motion.startAccelerometerUpdates()
                    
                    // Configure a timer to fetch the data.
                    self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                                       repeats: true, block: { (timer) in
                                        // Get the accelerometer data.
                                        if let data = self.motion.accelerometerData {
                                            let x: Int = Int(data.acceleration.x*100)
                                            let y: Int = Int(data.acceleration.y*100)
                                            let z: Int = Int(data.acceleration.z*100)
                                            //print(x,y,z)
                                            
                                            self.sensorData.append("\(x) \(y) \(z)")
                                        }
                    })
                    
                    // Add the timer to the current run loop.
                    RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
                }
            }
            startAccelerometers()
            
            //save the x y z reading to file system
            
            // Show another alert view
            self.present(secondAlertController, animated: true, completion: nil)
        }))
        
        firstAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
            print("CANCEL")
        }))

        self.present(firstAlertController, animated: true)//, completion: nil)
    }
    
    @IBAction func unwindWithSelectedSensor(segue: UIStoryboardSegue) {
        if let sensorPickerViewController = segue.source as? SensorPickerViewController,
            let selectedSensor = sensorPickerViewController.selectedSensor {
            sensor = selectedSensor
        }
        
    }
    
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveGesture.isEnabled = !text.isEmpty
    }
  
  @IBAction func exportData(_ sender: Any) {
    //Check to see the device can send email.
    if( MFMailComposeViewController.canSendMail() ) {
      print("Can send email.")
      
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      
      //Set the subject and message of the email
      mail.setSubject("Subject")
      mail.setMessageBody("Message body.", isHTML: false)
      mail.setToRecipients(["sapkota@mit.edu", "tomasero@mit.edu"])
      
//      if let filePath = Bundle.main.path(forResource: "swifts", ofType: "wav") {
//        print("File path loaded.")
//
//        if let fileData = NSData(contentsOfFile: filePath) {
//          print("File data loaded.")
//          mailComposer.addAttachmentData(fileData as Data, mimeType: "audio/wav", fileName: "swifts")
//        }
//      }
      self.present(mail, animated: true, completion: nil)
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    self.dismiss(animated: true, completion: nil)
  }
  
}


// MARK: - UITableViewDelegate
extension GestureDetailsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            nameTextField.becomeFirstResponder()
        }
    }
}


// Put this piece of code anywhere you like
extension GestureDetailsViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GestureDetailsViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension GestureDetailsViewController{
    
    
}
