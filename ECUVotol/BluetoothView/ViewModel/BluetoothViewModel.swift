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
    
    var data1 = "{C9}{14}{02}{50}{01}{14}{04}{03}{D4}{1D}{E2}{28}{00}{0B}{25}{80}{02}{58}{04}{5F}{00}{7B}{4A}{0D}{C9}{14}{02}{50}{02}{00}{00}{3C}{41}{63}{0B}{B8}{0B}{B8}{08}{FC}{A4}{2A}{0C}{1E}{1E}{0F}{EA}{0D}{C9}{14}{02}{50}{03}{FF}{BE}{50}{64}{69}{04}{1A}{00}{14}{24}{D4}{0F}{00}{17}{19}{E9}{71}{F3}{0D}{C9}{14}{02}{50}{04}{0E}{0C}{CC}{01}{40}{03}{84}{5F}{5F}{0F}{02}{58}{0F}{A0}{00}{00}{03}{7A}{0D}{C9}{14}{02}{50}{05}{C0}{01}{C0}{00}{C0}{00}{C0}{00}{C0}{11}{C0}{05}{C0}{07}{C0}{08}{03}{93}{0D}{C9}{14}{02}{50}{06}{C0}{00}{C0}{8B}{C0}{1B}{C0}{00}{C0}{00}{C0}{14}{C1}{02}{C8}{92}{7B}{EF}{0D}{C9}{14}{02}{50}{07}{2E}{A2}{00}{E0}{50}{78}{00}{00}{00}{00}{80}{02}{58}{04}{5F}{00}{7B}{36}{0D}"
    
    
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
    
    func sendData(value: String) {
        guard let valueInt = Int(value) else { return }
        let data1 = convertHexStringToArray(hexString: data1)
            print("a3.......data1 is:\(data1)......") // Xuất dữ liệu đã chuyển đổi
        let data2 =  setDataToArray(value: (valueInt * 10), index: 17, data: data1)
        print("a33.......data2 is:\(data2)......")
        
        let chunkedData = splitArray(array: data2, chunkSize: 24)
        print("a333.......chunkedData is:\(chunkedData)......")
        
        for (index, item) in chunkedData.enumerated() {
            print("a4.......item is:\(item)......")
            
            if let data3 = convertHexArrayToData(hexArray: item) {
                // Lên lịch gửi dữ liệu với khoảng thời gian 1 giây giữa các lần gọi
                Timer.scheduledTimer(withTimeInterval: 0.4 * Double(index), repeats: false) { [weak self] _ in
                    print("a5.......data3 is:\(data3)......")
                    self?.bluetoothManager?.sendData(data: data3)
                }
            }
        }
        
//        let dataToSend = Data([0xC9, 0x14, 0x02, 0x50, 0x01, 0x05, 0x01, 0x02,
//                               0xD5, 0x02, 0x2B, 0x0A, 0x00, 0x38, 0x25, 0x80,
//                               0x02, 0x0D, 0x04, 0x5F, 0x00, 0x7B, 0xCC, 0x0D])
//        bluetoothManager?.sendData(data: dataToSend)
    }
    
    func convertHexStringToArray(hexString: String) -> [String] {
        // Xóa các ký tự không cần thiết (như dấu ngoặc nhọn)
        let cleanedHexString = hexString.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
        
        // Tạo một mảng để chứa các giá trị hex
        var hexArray = [String]()
        
        // Chia chuỗi thành các ký tự hex đôi
        var startIndex = cleanedHexString.startIndex
        while startIndex < cleanedHexString.endIndex {
            let endIndex = cleanedHexString.index(startIndex, offsetBy: 2)
            let hexSubstring = cleanedHexString[startIndex..<endIndex]
            
            // Thêm vào mảng
            hexArray.append(String(hexSubstring))
            
            // Cập nhật chỉ số bắt đầu
            startIndex = endIndex
        }
        
        return hexArray
    }

    func setDataToArray(value: Int, index: Int, data: [String]) -> [String] {
        var dataTemp = data
        // Kiểm tra xem chỉ số có hợp lệ hay không
        if index >= 0 && index < dataTemp.count {
            // Chuyển đổi giá trị int thành chuỗi hex
            let hexString = String(format: "%02X", value)
            
            // Cập nhật giá trị trong mảng
            dataTemp[index] = hexString
            return dataTemp
        } else {
            print("Chỉ số không hợp lệ")
            return []
        }
    }

    func splitArray<T>(array: [T], chunkSize: Int) -> [[T]] {
        var result: [[T]] = []
        
        for i in stride(from: 0, to: array.count, by: chunkSize) {
            let chunk = Array(array[i..<min(i + chunkSize, array.count)])
            result.append(chunk)
        }
        
        return result
    }
    
    func convertHexArrayToData(hexArray: [String]) -> Data? {
        var byteArray = [UInt8]()
        
        for hexString in hexArray {
            // Chuyển đổi từng chuỗi hex thành byte
            if let byte = UInt8(hexString, radix: 16) {
                byteArray.append(byte)
            } else {
                print("Giá trị không hợp lệ: \(hexString)")
                return nil // Trả về nil nếu có giá trị không hợp lệ
            }
        }
        
        return Data(byteArray)
    }
}

//["C9", "14", "02", "50", "01", "14", "04", "03", "D4", "1D", "E2", "28", "00", "0B", "25", "80", "02", "58", "04", "5F", "00", "7B", "4A", "0D", "C9", "14", "02", "50", "02", "00", "00", "3C", "41", "63", "0B", "B8", "0B", "B8", "08", "FC", "A4", "2A", "0C", "1E", "1E", "0F", "EA", "0D", "C9", "14", "02", "50", "03", "FF", "BE", "50", "64", "69", "04", "1A", "00", "14", "24", "D4", "0F", "00", "17", "19", "E9", "71", "F3", "0D", "C9", "14", "02", "50", "04", "0E", "0C", "CC", "01", "40", "03", "84", "5F", "5F", "0F", "02", "58", "0F", "A0", "00", "00", "03", "7A", "0D", "C9", "14", "02", "50", "05", "C0", "01", "C0", "00", "C0", "00", "C0", "00", "C0", "11", "C0", "05", "C0", "07", "C0", "08", "03", "93", "0D", "C9", "14", "02", "50", "06", "C0", "00", "C0", "8B", "C0", "1B", "C0", "00", "C0", "00", "C0", "14", "C1", "02", "C8", "92", "7B", "EF", "0D", "C9", "14", "02", "50", "07", "2E", "A2", "00", "E0", "50", "78", "00", "00", "00", "00", "80", "02", "58", "04", "5F", "00", "7B", "36", "0D"]......
//
//["C9", "14", "02", "50", "01", "14", "04", "03", "D4", "1D", "E2", "28", "00", "0B", "25", "80", "02", "6E", "04", "5F", "00", "7B", "4A", "0D", "C9", "14", "02", "50", "02", "00", "00", "3C", "41", "63", "0B", "B8", "0B", "B8", "08", "FC", "A4", "2A", "0C", "1E", "1E", "0F", "EA", "0D", "C9", "14", "02", "50", "03", "FF", "BE", "50", "64", "69", "04", "1A", "00", "14", "24", "D4", "0F", "00", "17", "19", "E9", "71", "F3", "0D", "C9", "14", "02", "50", "04", "0E", "0C", "CC", "01", "40", "03", "84", "5F", "5F", "0F", "02", "58", "0F", "A0", "00", "00", "03", "7A", "0D", "C9", "14", "02", "50", "05", "C0", "01", "C0", "00", "C0", "00", "C0", "00", "C0", "11", "C0", "05", "C0", "07", "C0", "08", "03", "93", "0D", "C9", "14", "02", "50", "06", "C0", "00", "C0", "8B", "C0", "1B", "C0", "00", "C0", "00", "C0", "14", "C1", "02", "C8", "92", "7B", "EF", "0D", "C9", "14", "02", "50", "07", "2E", "A2", "00", "E0", "50", "78", "00", "00", "00", "00", "80", "02", "58", "04", "5F", "00", "7B", "36", "0D"]

//[["C9", "14", "02", "50", "01", "14", "04", "03", "D4", "1D", "E2", "28", "00", "0B", "25", "80", "02", "6E", "04", "5F", "00", "7B", "4A", "0D"],
// ["C9", "14", "02", "50", "02", "00", "00", "3C", "41", "63", "0B", "B8", "0B", "B8", "08", "FC", "A4", "2A", "0C", "1E", "1E", "0F", "EA", "0D"],
// ["C9", "14", "02", "50", "03", "FF", "BE", "50", "64", "69", "04", "1A", "00", "14", "24", "D4", "0F", "00", "17", "19", "E9", "71", "F3", "0D"],
// ["C9", "14", "02", "50", "04", "0E", "0C", "CC", "01", "40", "03", "84", "5F", "5F", "0F", "02", "58", "0F", "A0", "00", "00", "03", "7A", "0D"],
// ["C9", "14", "02", "50", "05", "C0", "01", "C0", "00", "C0", "00", "C0", "00", "C0", "11", "C0", "05", "C0", "07", "C0", "08", "03", "93", "0D"],
// ["C9", "14", "02", "50", "06", "C0", "00", "C0", "8B", "C0", "1B", "C0", "00", "C0", "00", "C0", "14", "C1", "02", "C8", "92", "7B", "EF", "0D"],
// ["C9", "14", "02", "50", "07", "2E", "A2", "00", "E0", "50", "78", "00", "00", "00", "00", "80", "02", "58", "04", "5F", "00", "7B", "36", "0D"]]

