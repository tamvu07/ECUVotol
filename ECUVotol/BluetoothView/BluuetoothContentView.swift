//
//  BluuetoothContentView.swift
//  ECUVotol
//
//  Created by Tam Vu on 2/10/25.
//

import SwiftUI

struct BluuetoothContentView: View {
    @StateObject private var viewModel = BluetoothViewModel()
    @State private var underVolText: String = ""
    @State private var maxCurrentText: String = ""
    
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
                            Text(" (Connected) ")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            TextField("Under Voltage:", text: $underVolText)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .keyboardType(.numberPad)
            
            TextField("Max curent:", text: $maxCurrentText)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .keyboardType(.numberPad)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    Button("Done") {
                                        // Dismiss the keyboard
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
            
            if let connectedPeripheral = viewModel.connectedPeripheral {
                Button("Send") {
                    viewModel.sendData(value1: underVolText, value2: maxCurrentText)
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
