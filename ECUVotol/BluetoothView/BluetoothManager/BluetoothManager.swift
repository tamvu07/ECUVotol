//
//  BluetoothManager.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//
import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    @Published var connectedPeripheral: CBPeripheral?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not available.")
        }
    }

    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning for devices...")
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let uuid = peripheral.identifier.uuidString
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)

            if let device = VTDevice(
                peripheral: peripheral,
                adv: advertisementData,
                RSSI: RSSI
            ) {
                peripheralNames.append(device.advName)
            }
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("Connected to \(peripheral.name ?? "unknown device")")
        connectedPeripheral = peripheral
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        print("Disconnected from \(peripheral.name ?? "unknown device")")
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        // Thiết lập lại connectedPeripheral nếu cần
        if connectedPeripheral == peripheral {
            connectedPeripheral = nil
        }
    }
    
    func isConnected(to peripheral: CBPeripheral) -> Bool {
        print("a3........\(connectedPeripheral == peripheral)........connectedPeripheral is:\(connectedPeripheral)......peripheral is:\(peripheral)......")
        return connectedPeripheral == peripheral
    }
}

class VTDevice: NSObject {
    
    var rawPeripheral: CBPeripheral
    var advName: String
    var RSSI: NSNumber
    
    init?(peripheral: CBPeripheral, adv: [String: Any], RSSI: NSNumber) {
        self.rawPeripheral = peripheral
        self.RSSI = RSSI
        
        // Extract the advertisement name
        self.advName = adv[CBAdvertisementDataLocalNameKey] as? String ?? ""
        
        // Check conditions to set the peripheral's name
        if let name = peripheral.name,
           !name.isEmpty,
           advName != "",
           name != advName {
            // Set the peripheral's name using Key-Value Coding
            peripheral.setValue(advName, forKey: "name")
        }
        
        // Check if peripheral name starts with specific prefixes
        let validPrefixes = [
            "JDY-23", "JDY "
        ]
        
        guard let peripheralName = peripheral.name else {
            return nil
        }
        
        // Ensure the peripheral name starts with one of the valid prefixes
        if !validPrefixes.contains(where: { peripheralName.hasPrefix($0) }) {
            return nil
        }
        
        super.init()
    }
}
