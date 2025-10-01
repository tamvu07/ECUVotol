//
//  Untitled.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//

import SwiftUI

struct BluetoothListView: View {
    @StateObject private var viewModel = BluetoothViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.peripheralNames, id: \.self) { name in
                Text(name)
            }
            .navigationTitle("Bluetooth Devices")
        }
        .onAppear {
            // Bắt đầu quét khi view xuất hiện
            viewModel.bluetoothManager.startScanning()
        }
    }
}
