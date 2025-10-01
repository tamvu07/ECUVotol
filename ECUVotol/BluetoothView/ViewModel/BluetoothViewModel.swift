//
//  BluetoothViewModel.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate {
    var bluetoothManager: BluetoothManager?
    @Published var peripheralNames: [String] = []
    private var centralManager: CBCentralManager!
    @Published var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanBluetooth() {
        // Đợi cho đến khi Bluetooth được bật
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }
        
        bluetoothManager = BluetoothManager()
        bluetoothManager?.$peripheralNames
            .assign(to: &$peripheralNames)
        bluetoothManager?.$connectedPeripheral
                    .assign(to: &$connectedPeripheral)
        
        // Bắt đầu quét thiết bị
        bluetoothManager?.startScanning()
    }
    
    func connectToPeripheral(at index: Int) {
        guard index < peripheralNames.count else { return }
        let peripheral = bluetoothManager?.peripherals[index]
        bluetoothManager?.connect(to: peripheral!)
    }
    
    func isPeripheralConnected(_ peripheral: CBPeripheral) -> Bool {
            return bluetoothManager?.isConnected(to: peripheral) ?? false
        }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on.")
            // Bắt đầu quét thiết bị khi Bluetooth đã được bật
            startScanBluetooth()
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .unauthorized:
            print("Bluetooth access is unauthorized.")
        case .unsupported:
            print("Bluetooth is not supported on this device.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            print("A previously unknown state occurred.")
        }
    }
}

