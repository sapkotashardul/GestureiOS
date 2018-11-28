//
//  ExoEarController.swift
//  GestureiOS
//
//  Created by Tomas Vega on 11/27/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class ExoEarController: UIViewController,
                        CBCentralManagerDelegate,
                        CBPeripheralDelegate {
  
  var manager:CBCentralManager!
  var _peripheral:CBPeripheral!
  var sendCharacteristic: CBCharacteristic!
  var loadedService: Bool = true

  let NAME = "GVS"
  let UUID_SERVICE = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
  let UUID_WRITE = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
  let UUID_READ = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
  
  
  func initExoEar() {
    manager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == CBManagerState.poweredOn {
      print("Buscando a Marc")
      central.scanForPeripherals(withServices: nil, options: nil)
    }
  }
  
  // Found a peripheral
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
    // Check if this is the device we want
    if device?.contains(NAME) == true {
      // Stop looking for devices
      // Track as connected peripheral
      // Setup delegate for events
      self.manager.stopScan()
      self._peripheral = peripheral
      self._peripheral.delegate = self
      
      // Connect to the perhipheral proper
      manager.connect(peripheral, options: nil)
      debugPrint("Found Bean.")
    }
  }
  
  // Connected to peripheral
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    // Ask for services
    peripheral.discoverServices(nil)
    debugPrint("Getting services ...")
  }
  
  // Discovered peripheral services
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    // Look through the service list
    for service in peripheral.services! {
      let thisService = service as CBService
      // If this is the service we want
      if service.uuid == UUID_SERVICE {
        // Ask for specific characteristics
        peripheral.discoverCharacteristics(nil, for: thisService)
      }
      debugPrint("Service: ", service.uuid)
    }
  }
  
  // Discovered peripheral characteristics
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    debugPrint("Enabling ...")
    // Look at provided characteristics
    for characteristic in service.characteristics! {
      let thisCharacteristic = characteristic as CBCharacteristic
      // If this is the characteristic we want
      print(thisCharacteristic.uuid)
      if thisCharacteristic.uuid == UUID_READ {
        // Start listening for updates
        // Potentially show interface
        self._peripheral.setNotifyValue(true, for: thisCharacteristic)
        
        // Debug
        debugPrint("Set to notify: ", thisCharacteristic.uuid)
      } else if thisCharacteristic.uuid == UUID_WRITE {
        sendCharacteristic = thisCharacteristic
        loadedService = true
      }
      debugPrint("Characteristic: ", thisCharacteristic.uuid)
    }
  }
  
  let alpha: Float = 0.2
  var currAccX: Int32 = 0
  var currAccY: Int32 = 0
  var oldAccX: Int32 = 0
  var oldAccY: Int32 = 0
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    //    print("Data")
    // Make sure it is the peripheral we want
    //    print(characteristic.uuid)
    if characteristic.uuid == UUID_READ {
      // Get bytes into string
      let dataReceived = characteristic.value! as NSData
//      print(dataReceived)
      
      var uAccX: UInt32 = 0
      var uAccY: UInt32 = 0
      
      
      dataReceived.getBytes(&uAccX, range: NSRange(location: 12, length: 4))
      dataReceived.getBytes(&uAccY, range: NSRange(location: 16, length: 4))
      
      
      var accX: Int32 = Int32(uAccX)
      var accY: Int32 = Int32(uAccY)
      
      let max: Int32 = 65536
      let mid: Int32 = 65536/2
      
      if (accX > mid) {
        accX = accX - max
      }
      if (accY > mid) {
        accY = accY - max
      }
      
      currAccX = Int32(alpha * Float(accX) + (1 - alpha) * Float(currAccX))
      currAccY = Int32(alpha * Float(accY) + (1 - alpha) * Float(currAccY))
      
      
      let distX = abs(currAccX - oldAccX)
      let distY = abs(currAccY - oldAccY)
      
//      print(currAccX, oldAccX, distX);
//      print(currAccY, oldAccY, distY);
      
      oldAccX = currAccX
      oldAccY = currAccY
      
//      print(currAccX, currAccY)

    }
  }
  
  func getData() -> [Int32] {
    return [currAccX, currAccY]
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    print("success")
    print(characteristic.uuid)
    print(error)
  }
  
  // Peripheral disconnected
  // Potentially hide relevant interface
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    debugPrint("Disconnected.")
    
    // Start scanning again
    central.scanForPeripherals(withServices: nil, options: nil)
  }
  
}

//func getData() -> NSData{
//  let state: UInt16 = stateValue ? 1 : 0
//  let power:UInt16 = UInt16(thresholdValue)
//  var theData : [UInt16] = [ state, power ]
//  print(theData)
//  let data = NSData(bytes: &theData, length: theData.count)
//  return data
//}
//
//func updateSettings() {
//  if loadedService {
//    if _peripheral?.state == CBPeripheralState.connected {
//      if let characteristic:CBCharacteristic? = sendCharacteristic{
//        let data: Data = getData() as Data
//        _peripheral?.writeValue(data,
//                                for: characteristic!,
//                                type: CBCharacteristicWriteType.withResponse)
//      }
//    }
//  }
//}
