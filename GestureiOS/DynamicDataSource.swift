//
//  DynamicDataSource.swift
//  GestureiOS
//
//  Created by fluid on 11/21/18.
//  Copyright © 2018 fluid. All rights reserved.
//
import UIKit

class DynamicDataSource: NSObject,UITableViewDataSource,UITableViewDelegate {
    
   var sampleFileNames: [String] = []
    
    
    override init(){
        super.init()
    }
    
    
    func setData(sampleFileNames:[String]){
        self.sampleFileNames = sampleFileNames
    }
    
    func getData() -> [String]{
        return self.sampleFileNames
    }
    
    func addData(fileName:String){
        self.sampleFileNames.append(fileName)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleFileNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell  else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }
        
        cell.textLabel?.text = sampleFileNames[indexPath.row] + ".txt"
        
        return cell
    }
    
        // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                sampleFileNames.remove(at: indexPath.row)
//                self.gDVC.setData(sampleFileNames: self.sampleFileNames)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}
