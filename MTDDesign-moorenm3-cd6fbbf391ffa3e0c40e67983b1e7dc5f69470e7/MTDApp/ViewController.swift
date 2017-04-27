//
//  ViewController.swift
//  MTDApp
//

import UIKit
import CoreBluetooth

// UUID information to receive and transmit to the bluetooth
private let uuid: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
private let rx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
private let tx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

public var dataStream = ""

var date1 = NSDate()

class ViewController: UIViewController {
    @IBAction func showAlert(_ sender: AnyObject) {
        let date2 = NSDate().timeIntervalSince(date1 as Date);
        if (date2 > 10) {
            let alertController = UIAlertController(title: "ERROR  CODE 8", message: "Battery Temperature Warning", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "I Understand", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            date1 = NSDate();
        
        }
    }
    
    @IBOutlet weak var battery1Main = UIButton()
    @IBOutlet weak var battery1Page = UIButton()
    @IBOutlet weak var battery2Main = UIButton()
    @IBOutlet weak var battery2Page = UIButton()
    @IBOutlet weak var motorTempMain = UILabel()
    @IBOutlet weak var motorTempPage = UITextField()
    @IBOutlet weak var ctrlTempMain = UILabel()
    @IBOutlet weak var ctrlTempPage = UITextField()
    @IBOutlet weak var hpMain = UILabel()
    @IBOutlet weak var hpPage = UILabel()
    @IBOutlet weak var motorSpeedMain = UILabel()
    @IBOutlet weak var motorSpeedPage = UILabel()
    @IBOutlet weak var currentMain = UILabel()
    @IBOutlet weak var currentPage = UILabel()
    
    var manager: CBCentralManager?
    var peripheral: CBPeripheral?
    var write: CBCharacteristic?  //{
//        didSet {
//            // Comment this all out when connecting to lawnmower
//            // 6). Called when writing to the device
//            if let write = write {
//                if let test = "+++\n".data(using: .utf8) {
//                    //print("Sending... \(String(describing: test))")
//                    peripheral?.writeValue(test, for: write, type: CBCharacteristicWriteType.withResponse)
//                }
//                if let test = "AT+BAUDRATE=115200".data(using: .utf8) {
//                    //print("Sending... \(String(describing: test))")
//                    peripheral?.writeValue(test, for: write, type: CBCharacteristicWriteType.withResponse)
//                }
//                if let test = "+++\n".data(using: .utf8) {
//                    //print("Sending... \(String(describing: test))")
//                    peripheral?.writeValue(test, for: write, type: CBCharacteristicWriteType.withResponse)
//                }
//            }
//        }
    //}
    
    var read: CBCharacteristic?  {
        didSet {
            // 6). Called when ready to start reading from the device
            if let read = read {
                peripheral?.readValue(for: read)
                //print("Reading...")
            }
        }
    }
    
    var sampleData = MowerDataObject.getInstance()
    
    func changeBatteryColor() {
        let battery1Charged = sampleData.getBatteryOne()
        let battery2Charged = sampleData.getBatteryTwo()
        if (battery1Charged > 67) {
            battery1Main?.backgroundColor = UIColor.green
            battery1Page?.backgroundColor = UIColor.green
        } else if (battery1Charged > 33) {
            battery1Main?.backgroundColor = UIColor.yellow
            battery1Page?.backgroundColor = UIColor.yellow
        } else {
            battery1Main?.backgroundColor = UIColor.red
            battery1Page?.backgroundColor = UIColor.red
        }
        if (battery2Charged > 67) {
            battery2Main?.backgroundColor = UIColor.green
            battery2Page?.backgroundColor = UIColor.green
        } else if (battery2Charged > 33) {
            battery2Main?.backgroundColor = UIColor.yellow
            battery2Page?.backgroundColor = UIColor.yellow
        } else {
            battery2Main?.backgroundColor = UIColor.red
            battery2Page?.backgroundColor = UIColor.red
        }
        
    }
    
    func setData() {
        changeBatteryColor()
        ctrlTempMain?.text = String(sampleData.getCtrlTemp())
        motorTempMain?.text = String(sampleData.getMotorTemp())
        hpMain?.text = String(sampleData.getHP())
        currentMain?.text = String(sampleData.getCurrent())
        motorSpeedMain?.text = String(sampleData.getMotorSpeed())
        
        ctrlTempPage?.text = String(sampleData.getCtrlTemp())
        motorTempPage?.text = String(sampleData.getMotorTemp())
        hpPage?.text = String(sampleData.getHP())
        currentPage?.text = String(sampleData.getCurrent())
        motorSpeedPage?.text = String(sampleData.getMotorSpeed())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        setData()
    }
}

extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("Wrote value???")
    }
    
    // 7). Called when there's new data to be read from the device
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // print("Updated value for UUID: \(characteristic.uuid)\n")
        
        // Throw error if present
        if let error = error {
            print("error: \(error)")
            return
        }
        
        if let data = characteristic.value {
            let dataBLE = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            if (dataBLE?.characters.first == "#") {
                if (dataStream != "") {
                    // Call parser with the data collected
                    parse(data: dataStream)
                    dataStream = ""
                }
            }
            
            if let d = dataBLE {
                dataStream += d
                //print("DATA: \(String(describing: d)) \n")
            }
        }
    }
    
    // 4). Called when services are found, after connection
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //print("Discovered services for: \(String(describing: peripheral.name))\n")
        
        // Throw error if present
        if let error = error {
            print("Discovered Services Error: \(error)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // 5). Called when characteristics of specified services are found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //print("Discovered characteristics for: \(String(describing: service.characteristics))\n")
        //print("Discovered characteristics #: \(String(describing: service.characteristics?.count))\n")
        
        // Throw error if present
        if let error = error {
            print("Discovered Characteristics Error: \(error)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                //print("\n\(String(describing: characteristic))\n")
                
                if let uuid = UUID(uuidString: tx) {
                    let cb = CBUUID(nsuuid: uuid)
                    if characteristic.uuid == cb {
                        // Write to TX
                        self.write = characteristic
                    } else {
                        // Read from RX continuously
                        peripheral.setNotifyValue(true, for: characteristic)
                        self.read = characteristic
                    }
                }
            }
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    
    // 1). Gets called when main page loads
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state changed")
        switch central.state {
        case .poweredOff:
            print("powered off")
        case .poweredOn:
            print("powered on")
            let cbuuid = CBUUID(string: uuid)
            central.scanForPeripherals(withServices: [cbuuid], options: nil)
        case .resetting:
            print("resetting")
        case .unauthorized:
            print("unauthorized")
        case .unsupported:
            print("unsupported")
        case .unknown:
            print("unknown")
        }
    }
    
    // 3). Called when successfully connected to device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print("Connected to \(String(describing: peripheral.name))")
        peripheral.delegate = self
        let cbuuid = CBUUID(string: uuid)
        //let cbuuid = CBUUID()
        
        peripheral.discoverServices([cbuuid])
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("data: \(dataStream)")
        print("Disconnected from: \(String(describing: peripheral.name))")
    }
    
    
    // 2). Called when device to connect to is found
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered: \(String(describing: peripheral.name))")
        self.peripheral = peripheral
        central.connect(peripheral, options: nil)
        central.stopScan()
    }
    
}

