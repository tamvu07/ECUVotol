//
//  BluetoothManager.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//
import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    @Published var connectedPeripheral: CBPeripheral?

    let dataToSend = Data([0xC9, 0x14, 0x02, 0x50, 0x01, 0x05, 0x01, 0x02,
                           0xD5, 0x02, 0x2B, 0x0A, 0x00, 0x38, 0x25, 0x80,
                           0x02, 0x0D, 0x04, 0x5F, 0x00, 0x7B, 0xCC, 0x0D])
    
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
        peripheral.delegate = self // Thiết lập delegate
        peripheral.discoverServices(nil) // Khám phá tất cả dịch vụ
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
        return connectedPeripheral == peripheral
    }
    
    // Hàm gửi dữ liệu
//    func sendData(data: Data) {
//        // Đảm bảo rằng có kết nối với peripheral
//        guard let peripheral = connectedPeripheral else {
//            print("No connected peripheral.")
//            return
//        }
//        
//        // Khai báo UUID cho service và characteristic
//        let serviceUUID = CBUUID(string: "FF11") // UUID service
//        let characteristicUUID = CBUUID(string: "FFE1") // UUID characteristic
//
//        // Tìm kiếm dịch vụ và characteristic
//        for service in peripheral.services ?? [] {
//            if service.uuid == serviceUUID {
//                for characteristic in service.characteristics ?? [] {
//                    if characteristic.uuid == characteristicUUID && characteristic.properties.contains(.write) {
//                        // Gửi dữ liệu đến characteristic
//                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
//                        print("Data sent to \(peripheral.name ?? "unknown device").")
//                        return
//                    }
//                }
//            }
//        }
//        print("Characteristic not found or not writable.")
//    }
    
    func sendData(data: Data) {
        guard let peripheral = connectedPeripheral else { return }
        
        // Service UUID và characteristic UUID cho JDY-23
        let serviceUUID = CBUUID(string: "FFE0")
        let characteristicUUID = CBUUID(string: "FFE2") // UUID chính xác cho characteristic
        print("a3.....send data nha ......")
        // Khám phá dịch vụ
        peripheral.discoverServices([serviceUUID])
        // Sau khi khám phá, bạn cần gọi discoverCharacteristics cho mỗi service
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        for service in peripheral.services ?? [] {
            // Khám phá các characteristic cho service
            print("Found service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service) // Khám phá characteristic cho dịch vụ
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        for characteristic in service.characteristics ?? [] {
                print("Found characteristic: \(characteristic.uuid)")

                // Kiểm tra quyền write
                if characteristic.properties.contains(.write) {
                    // Gửi dữ liệu
//                    let dataToSend = Data([0xC9, 0x14, 0x02, 0x50, 0x01, 0x05, 0x01, 0x02,
//                                           0xD5, 0x02, 0x2B, 0x0A, 0x00, 0x38, 0x25, 0x80,
//                                           0x02, 0x0D, 0x04, 0x5F, 0x00, 0x7B, 0xCC, 0x0D])//Data([0x01, 0x02, 0x03]) // Dữ liệu bạn muốn gửi
                    peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)
                    print("Data sent to characteristic \(characteristic.uuid)")
                }
            }
//        for characteristic in service.characteristics ?? [] {
//            if characteristic.uuid == CBUUID(string: "FFE2") && characteristic.properties.contains(.write) {
//                // Bây giờ bạn có thể gửi dữ liệu
////                peripheral.writeValue(data, for: characteristic, type: .withResponse)
//                print("Data sent to \(peripheral.name ?? "unknown device")")
//                return
//            }
//        }
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
//        if !validPrefixes.contains(where: { peripheralName.hasPrefix($0) }) {
//            return nil
//        }
        
        super.init()
    }
}
