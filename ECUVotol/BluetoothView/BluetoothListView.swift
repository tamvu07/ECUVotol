//
//  Untitled.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//

import SwiftUI
import CoreBluetooth

struct BluetoothListView: View {
    @StateObject private var viewModel = BluetoothViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.peripheralNames.indices, id: \.self) { index in
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
            .navigationTitle("Bluetooth Devices")
            .toolbar {
                if let connectedPeripheral = viewModel.connectedPeripheral {
                    Button("Send") {
                        viewModel.sendData()
                    }
                    .disabled(connectedPeripheral == nil)
                }
            }
        }
        .onAppear {
            // Bắt đầu quét khi view xuất hiện
            viewModel.bluetoothManager?.startScanning()
        }
    }
}
