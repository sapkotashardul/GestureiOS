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

class GestureDetailsViewController: UITableViewController, UITextFieldDelegate {
    
    var gesture: Gesture?
    let motion = CMMotionManager()
    var timer: Timer = Timer()
    var flag = true
    var sensorData = [String]()
    var sampleFileNames: [String] = ["TestData"]//[String]()

    
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
            self.flag = false
        }
        
        
        updateSaveButtonState()
        
        self.hideKeyboardWhenTappedAround()
        
//        self.sampleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
//    // MARK: - Initializers
//    required init?(coder aDecoder: NSCoder) {
//        print("init GestureDetailsViewController")
//        super.init(coder: aDecoder)
//    }
    
    deinit {
        print("deinit GestureDetailsViewController")
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
//        if segue.identifier == "SaveGestureDetail",
//            let gestureName = nameTextField.text {
//            gesture = Gesture(name: gestureName, sensor: sensor)
//        }
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
        
        save(gestureName: gestureName, gestureSensor: detailLabel.text ?? "")
    }
    
    func save(gestureName: String, gestureSensor: String){
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
        }
        else{
        if let id = self.gesture?.objectID {
            do{
            try self.gesture = managedContext.existingObject(with: id) as? Gesture
                self.gesture?.name = gestureName
                self.gesture?.sensor = gestureSensor
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
    

    @IBAction func addSample(_ sender: Any) {
        // 1.
//        var usernameTextField: UITextField?
//        var passwordTextField: UITextField?
        
        // 2.
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
        
//        // 3.
//        let loginAction = UIAlertAction(
//        title: "Log in", style: UIAlertAction.Style.default) {
//            (action) -> Void in
//
//            if let username = usernameTextField?.text {
//                print(" Username = \(username)")
//            } else {
//                print("No Username entered")
//            }
//
//            if let password = passwordTextField?.text {
//                print("Password = \(password)")
//            } else {
//                print("No password entered")
//            }
//        }
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                    guard let textField = thirdAlertController.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        
                                        self.sampleFileNames = self.dataSource.getData()
                                        let newIndexPath = IndexPath(row: self.sampleFileNames.count, section: 0)
                                        self.sampleFileNames.append(nameToSave)
                                        self.dataSource.setData(sampleFileNames: self.sampleFileNames)
                                        print("name of file", nameToSave)
                                        self.sampleTableView.beginUpdates()
                                        self.sampleTableView.insertRows(at: [newIndexPath], with: .automatic)
                                        //self.sampleTableView.reloadData()
                                        self.sampleTableView.endUpdates()   
                                        //self.tableView.reloadData()
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
                self.sensorData = []
                
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

        
//        // 4.
//        alertController.addTextField {
//            (txtUsername) -> Void in
//            usernameTextField = txtUsername
//            usernameTextField!.placeholder = "<Your username here>"
//        }
//
//        alertController.addTextField {
//            (txtPassword) -> Void in
//            passwordTextField = txtPassword
//            passwordTextField!.isSecureTextEntry = true
//            passwordTextField!.placeholder = "<Your password here>"
//        }
        
        // 5.
        //alertController.addAction(loginAction)
        self.present(firstAlertController, animated: true)//, completion: nil)
    }
    
//    @IBAction func showAlertButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//        self.present(myAlert, animated: true, completion: nil)
//    }
    
    
    @IBAction func unwindWithSelectedSensor(segue: UIStoryboardSegue) {
        if let sensorPickerViewController = segue.source as? SensorPickerViewController,
            let selectedSensor = sensorPickerViewController.selectedSensor {
            sensor = selectedSensor
        }
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveGesture.isEnabled = !text.isEmpty
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


//extension GestureDetailsViewController{
//    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//
//    }
//
//    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        if tableView == sampleTableView {
//            return self.sampleFileNames.count;
//        }
//        return 0
//    }
//
//    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: IndexPath!) -> UITableViewCell! {
//
//        let cellIdentifier = "Cell"
//
//
//        guard let cell = sampleTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell  else {
//                fatalError("The dequeued cell is not an instance of TableViewCell.")
//        }
//
//        cell.textLabel?.text = String(self.sampleFileNames[indexPath.row])
//        print("Got the file name as ", cell.textLabel?.text)
//        return cell
//    }
//
//    // Override to support editing the table view.
//    func tableView(tableView: UITableView!, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            sampleFileNames.remove(at: indexPath.row)
//            sampleTableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
//
//}

//extension GestureDetailsViewController{
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//
//
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            //Delete from CoreData
//
//            guard let appDelegate =
//                UIApplication.shared.delegate as? AppDelegate else {
//                    return
//            }
//
//            let managedContext =
//                appDelegate.persistentContainer.viewContext
//
//            managedContext.delete(gestures[indexPath.row] as NSManagedObject)
//
//            // Delete the row from the data source
//            gestures.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//            do {
//                try managedContext.save()
//
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
//
//
//
//}
//
