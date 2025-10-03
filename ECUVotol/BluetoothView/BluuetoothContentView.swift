//
//  BluuetoothContentView.swift
//  ECUVotol
//
//  Created by Tam Vu on 2/10/25.
//

import SwiftUI

struct BluuetoothContentView: View {
    @StateObject private var viewModel = BluetoothViewModel()
    
    @State private var inputText: String = ""
    
    var body: some View {
        VStack {
            // Hiển thị danh sách thiết bị
            List(
                viewModel.peripheralNames.indices,
                id: \.self
            ) { index in
                Button(action: {
                    viewModel.connectToPeripheral(at: index)
                }) {
                    HStack {
                        Text(viewModel.peripheralNames[index])
                        if let peripheral = viewModel.bluetoothManager?.peripherals[index],
                           viewModel.isPeripheralConnected(peripheral) {
                            Text(" (Connected)")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            TextField("Under Voltage:", text: $inputText)
                            .padding() // Thêm khoảng cách
                            .background(Color.gray.opacity(0.2)) // Nền màu xám nhạt
                            .cornerRadius(8) // Bo tròn các góc
                            .padding(.horizontal)
                            .keyboardType(.numberPad)
            
            if let connectedPeripheral = viewModel.connectedPeripheral {
                Button("Send") {
                    viewModel.sendData(value: inputText)
                }
                .disabled(connectedPeripheral == nil) // Vô hiệu hóa nút nếu không có thiết bị kết nối
                .frame(width: 200, height: 50) // Đặt kích thước cho nút
                .background(connectedPeripheral == nil ? Color.gray : Color.blue) // Màu nền xanh khi có thiết bị kết nối, xám khi không
                .foregroundColor(.white) // Màu chữ trắng
                .cornerRadius(10) // Bo tròn các góc của nút
                .font(.headline)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 10) // Viền 10px
                )
                .padding() // Thêm khoảng cách
            }
        }
        .onAppear() {
            viewModel.bluetoothManager?.startScanning()
        }
    }
}
