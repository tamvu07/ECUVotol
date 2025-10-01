//
//  BluetoothViewModel.swift
//  ECUVotol
//
//  Created by Tam Vu on 1/10/25.
//

import Foundation
import Combine

class BluetoothViewModel: ObservableObject {
    var bluetoothManager: BluetoothManager
    @Published var peripheralNames: [String] = []

    init() {
        bluetoothManager = BluetoothManager()
        bluetoothManager.$peripheralNames
            .assign(to: &$peripheralNames)
    }
}
