//
//  SplashView.swift
//  ECUVotol
//
//  Created by Tam Vu on 2/10/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color.black // Nền màu xám
                .edgesIgnoringSafeArea(.all) // Để chiếm toàn bộ màn hình
            
            if isActive {
                HomeView() // Chuyển đến BluetoothListView khi splash screen hoàn tất
            } else {
                VStack {
                    Spacer()
                    // Thêm logo hoặc hình ảnh nếu cần
                    Image("ic_logo") // Hình ảnh logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding()

                    // Thời gian hiển thị splash screen
                    Spacer() // Để căn chỉnh logo lên giữa
                }
                .onAppear {
                    // Sau 2 giây, chuyển đến BluetoothListView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}
