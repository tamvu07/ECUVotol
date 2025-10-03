//
//  Untitled.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//

import SwiftUI
import CoreBluetooth
import Lottie

struct BluetoothListView: View {
//    @StateObject private var viewModel = BluetoothViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isScanning = false
    
    var body: some View {
        ZStack {
            Color.black // Nền màu xám
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header View
                ZStack {
                    HStack {
                        // Nút quay lại
                        Button(action: {
                            // Hành động khi nhấn nút quay lại
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left") // Hình biểu tượng quay lại
                                .font(.title) // Kích thước biểu tượng
                                .foregroundColor(.white) // Màu sắc chữ trắng
                        }
                        .padding() // Khoảng cách cho nút quay lại
                        Spacer()
                        
                    }.frame(maxWidth: .infinity, maxHeight: 50)
                    Spacer() // Đẩy tiêu đề về giữa

                    // Tiêu đề
                    Text("Votol")
                        .font(.headline) // Kích thước chữ tiêu đề
                        .foregroundColor(.white) // Màu chữ trắng
                    
                    Spacer() // Đẩy tiêu đề về giữa
                }
                .frame(maxWidth: .infinity, maxHeight: 50) // Chiếm toàn bộ chiều rộng
                .background(Color.black) // Nền màu đen
                
                Spacer()
                if !isScanning {
                    Button(action: {
                        isScanning = true
                    }) {
                        Image("icon_stop_scan_bluetooth") // Hình ảnh logo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .padding() // Màu sắc chữ trắng
                    }
                } else {
                    BluuetoothContentView()
                }
                
                // Thời gian hiển thị splash screen
                Spacer() // Để căn chỉnh logo lên giữa
            }
            .background(Color.white)
        }
        .navigationBarHidden(true) // Ẩn NavigationBar
        .navigationBarBackButtonHidden(true)
    }
}


struct ScanSwiftUIView: View {
    var body: some View {
        VStack {
            LottieView(animation: .named("icon_amination_bluetooth"))
                .configure(\.contentMode, to: .scaleAspectFit)
                .looping()
                .frame(width: 300, height: 300)
        }
    }
}


//struct BluetoothListView: View {
//    @StateObject private var viewModel = BluetoothViewModel()
//
//    var body: some View {
//        NavigationView {
//            List(viewModel.peripheralNames.indices, id: \.self) { index in
//                Button(action: {
//                    viewModel.connectToPeripheral(at: index)
//                }) {
//                    HStack {
//                        Text(viewModel.peripheralNames[index])
//                        if let peripheral = viewModel.bluetoothManager?.peripherals[index],
//                           viewModel.isPeripheralConnected(peripheral) {
//                            Text(" (Connected)")
//                                .foregroundColor(.green)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Bluetooth Devices")
//            .toolbar {
//                if let connectedPeripheral = viewModel.connectedPeripheral {
//                    Button("Send") {
//                        viewModel.sendData()
//                    }
//                    .disabled(connectedPeripheral == nil)
//                }
//                // Nút để quét lại thiết bị Bluetooth
//                Button("Reload") {
//                    viewModel.startScanBluetooth() // Gọi phương thức quét lại
//                }
//            }
//        }
//        .onAppear {
//            // Bắt đầu quét khi view xuất hiện
//            viewModel.bluetoothManager?.startScanning()
//        }
//        .navigationBarHidden(true) // Ẩn NavigationBar
//        .navigationBarBackButtonHidden(true)
//    }
//}
