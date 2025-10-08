//
//  BluetoothViewModel.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//

import Foundation
import CoreBluetooth
import Combine

struct DataICResponse {
    var array1: [String] = []
    var array2: [String] = []
    var array3: [String] = []
    var array4: [String] = []
    var array5: [String] = []
    var array6: [String] = []
    var array7: [String] = []
    var countAllArray: Int = 0
}

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate {
    var bluetoothManager: BluetoothManager?
    @Published var peripheralNames: [String] = []
    private var centralManager: CBCentralManager!
    @Published var connectedPeripheral: CBPeripheral?
    var subscriptions = [AnyCancellable]()
    
    var data1 = "{C9}{14}{02}{50}{01}{14}{01}{02}{D5}{02}{2B}{0A}{00}{38}{25}{80}{02}{0A}{04}{5F}{00}{7B}{DA}{0D}{C9}{14}{02}{50}{02}{00}{00}{3C}{41}{63}{0B}{B8}{0B}{B8}{08}{FC}{A4}{2A}{0C}{1E}{1E}{0F}{EA}{0D}{C9}{14}{02}{50}{03}{FF}{BE}{50}{64}{69}{04}{1A}{00}{14}{24}{D4}{0F}{00}{17}{19}{E9}{71}{F3}{0D}{C9}{14}{02}{50}{04}{0E}{0C}{CC}{01}{40}{03}{84}{5F}{5F}{0F}{02}{58}{0F}{A0}{00}{00}{03}{7A}{0D}{C9}{14}{02}{50}{05}{C0}{01}{C0}{00}{C0}{00}{C0}{00}{C0}{11}{C0}{05}{C0}{07}{C0}{08}{03}{93}{0D}{C9}{14}{02}{50}{06}{C0}{00}{C0}{8B}{C0}{1B}{C0}{00}{C0}{00}{C0}{14}{C1}{02}{C8}{92}{7B}{EF}{0D}{C9}{14}{02}{50}{07}{2E}{A2}{00}{E0}{50}{78}{00}{00}{00}{00}{80}{02}{0A}{04}{5F}{00}{7B}{64}{0D}"
    
    var data = DataICResponse()
    @Published var countArray: Int = 0

    @Published var underVol: Double = 0.0
    
    
    
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
        
        bluetoothManager?.setVM(vm: self)
        // Bắt đầu quét thiết bị
        bluetoothManager?.startScanning()
        
        observerData()
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
    
    func sendData(value1: String, value2: String) {
        guard let value1Double = Double(value1), let value2Int = Int(value2) else { return }
        
        let value1Temp = convertDecimalToHexType10(input: value1Double) // 52.2 -> 02 0A
        
        let value2Temp = convertDecimalToHexTypeDefault(input: value2Int) // 300 -> 01 2C
        
        
        // chuyen string sang mảng
        let dataInitial = convertHexStringToArray(hexString: data1)
        
        // set gia trị mới vào mảng
        let dataUpdateStep1 =  setDataToArrayByHexadecimal(value: value1Temp.0, index: 16, data: dataInitial)
        let dataUpdateStep2 =  setDataToArrayByHexadecimal(value: value1Temp.1, index: 17, data: dataUpdateStep1)
        
        let dataUpdateStep3 =  setDataToArrayByHexadecimal(value: value2Temp.0, index: 29, data: dataUpdateStep2)
        let dataUpdateStep4 =  setDataToArrayByHexadecimal(value: value2Temp.1, index: 30, data: dataUpdateStep3)
        
        // tìm giá trị checkSum va set vao mảng
        let dataCheckSumPage1 =  setDataToArrayByDecimal(value: Int(checkSumData(indexStart: 0, indexEnd: 21, data: dataUpdateStep4)), index: 22, data: dataUpdateStep4)
        
        let dataCheckSumPage2 =  setDataToArrayByDecimal(value: Int(checkSumData(indexStart: 24, indexEnd: 45, data: dataCheckSumPage1)), index: 46, data: dataCheckSumPage1)
        
        // tach mảng ra thành các phẩn tử nhỏ
        let chunkedData = splitArray(array: dataCheckSumPage2, chunkSize: 24)
        
        for (index, item) in chunkedData.enumerated() {
            print("a4...........................index is:\(index).............")
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

    // nếu kiểu dữ liệu input là Dec thì phải chuyển sang Hex
    func setDataToArrayByDecimal(value: Int, index: Int, data: [String]) -> [String] {
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
    
    // đưa data Hẽ vao mảng
    func setDataToArrayByHexadecimal(value: String, index: Int, data: [String]) -> [String] {
        var dataTemp = data
        // Kiểm tra xem chỉ số có hợp lệ hay không
        if index >= 0 && index < dataTemp.count {
            // Cập nhật giá trị trong mảng
            dataTemp[index] = value
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
    
    // lay ra mảng tại 2 vi trí input
    func getSubArray(from array: [String], indexStart: Int, indexEnd: Int) -> [String]? {
        // Kiểm tra chỉ số hợp lệ
        guard indexStart >= 0, indexEnd < array.count, indexStart <= indexEnd else {
            return nil // Trả về nil nếu chỉ số không hợp lệ
        }
        
        // Lấy mảng con từ indexStart đến indexEnd
        return Array(array[indexStart...indexEnd])
    }
    
    // ham check Sum
    func calcXorChecksum(buf: [UInt8]) -> UInt8 {
        var checksum: UInt8 = 0
        for byte in buf {
            checksum ^= byte
        }
        return checksum
    }
    
    func convertHexArrayToUInt8Array(hexArray: [String]) -> [UInt8]? {
        var byteArray: [UInt8] = []
        
        for hex in hexArray {
            // Chuyển đổi chuỗi hex thành UInt8
            if let byte = UInt8(hex, radix: 16) {
                byteArray.append(byte)
            } else {
                // Trả về nil nếu có giá trị không hợp lệ
                return nil
            }
        }
        
        return byteArray
    }
    
    // checkSum: 0 -> 21 set vao -> 22, 24 -> 45 set vao 46
    func checkSumData(indexStart: Int, indexEnd: Int, data: [String]) -> UInt8  {
        guard let a = getSubArray(from: data, indexStart: indexStart, indexEnd: indexEnd) else { return 0}
        guard let b = convertHexArrayToUInt8Array(hexArray: a) else { return 0 } //  [UInt8]

        // Tính toán checksum
        let checksum = calcXorChecksum(buf: b)
        // In kết quả
        print("a6.....\(String(format: "XOR Checksum: 0x%02X", checksum))")
        return checksum
        
    }
    
    // ham 52.2 ->  Kết quả: h: 02, d: 0A
    func convertDecimalToHexType10(input: Double) -> (String, String) {
        // Nhân đầu vào với 10 để có giá trị cần tính
        let multipliedInput = input * 10
        let integerPart = Int(multipliedInput)
        
        // Tính giá trị cho h và d
        let h = integerPart / 255
        let d = integerPart % 255
        
        // Tính giá trị cho h
        let hHex = String(format: "%02X", h)
        
        // Tính giá trị cho d
        let dValue = integerPart - (h * 255)
        let dHex = String(format: "%02X", dValue)
        
        return (hHex, dHex)
    }
    
    func convertDecimalToHexTypeDefault(input: Int) -> (String, String) {
        let integerPart = Int(input)
        
        // Tính giá trị cho h và d
        let h = integerPart / 255
        let d = integerPart % 255
        
        // Tính giá trị cho h
        let hHex = String(format: "%02X", h)
        
        // Tính giá trị cho d
        let dValue = integerPart - (h * 255)
        let dHex = String(format: "%02X", dValue)
        
        return (hHex, dHex)
    }
    
    // dung khi nhan data tu IC chuyen data thanh dạng ["C0", "14", "05", "52"]
    func convertDataToHexStringArray(data: Data) -> [String] {
        return data.map { String(format: "%02X", $0) }
    }
    
    //dung khi nhan data tu IC  chuyen data thanh.dạng {C0}{14}{05}{52}{07}
    func convertDataToFormattedString(data: Data) -> String {
        let hexStrings = data.map { String(format: "%02X", $0) }
        return hexStrings.map { "{\($0)}" }.joined()
    }
    
    // chuyen decimal to Hex
    func decimalToHex(decimal: Int) -> String {
        return String(decimal, radix: 16).uppercased() // Chuyển đổi sang hex và chuyển đổi thành chữ in hoa
    }
    
    func observerData() {
        self.$countArray
            .sink(receiveValue: { [weak self] result in
                guard let strongSelf = self else { return }
                if result == 7 {
                    print("a3........array1 is:\(strongSelf.data.array1).....")
                    let a = strongSelf.data.array1[16]
                    let b = strongSelf.data.array1[17]
                    strongSelf.underVol = strongSelf.convertHexToDecimalType10(hexString: "\(a) \(b)") ?? 0.0
                }
            })
            .store(in: &subscriptions)
    }
    
    // để convert data và show lên UI: "02 0A" -> 52.2
    func convertHexToDecimalType10(hexString: String) -> Double? {
        // Tách chuỗi hex thành các phần tử
        let hexValues = hexString.split(separator: " ")

        // Kiểm tra có đủ 2 giá trị không
        guard hexValues.count == 2,
              let firstValue = Int(hexValues[0], radix: 16),
              let secondValue = Int(hexValues[1], radix: 16) else {
            return nil // Trả về nil nếu không hợp lệ
        }

        // Tính toán giá trị
        let result = Double(firstValue) * 255 + Double(secondValue)
        
        // Chia cho 10 để ra giá trị thập phân
        return result / 10.0
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

