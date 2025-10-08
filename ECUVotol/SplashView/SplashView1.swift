//
//  Splash1.swift
//  ECUVotol
//
//  Created by Tam Vu on 8/10/25.
//

import SwiftUI

import SwiftUI
import SwiftUI

struct SplashView1: View {
    
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            HomeView()
        } else {
            ZStack {
                Image("ic_login") // Tên hình ảnh
                    .resizable() // Cho phép hình ảnh thay đổi kích thước
                    .aspectRatio(contentMode: .fill) // Đảm bảo hình ảnh lấp đầy màn hình
                    .edgesIgnoringSafeArea(.all) // Để chiếm toàn bộ màn hình
                
                VStack {
                    HStack {
                        Spacer() // Đẩy nút về phía bên phải
                        Button(action: {
                            // Hành động khi nút được nhấn
                            print("Button tapped")
                        }) {
                            Text("Long Press Me")
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        .simultaneousGesture(LongPressGesture(minimumDuration: 3.0)
                            .onEnded { _ in
                                // Hành động khi người dùng long tap
                                print("a3.....Button long pressed")
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    withAnimation {
                                        self.isActive = true
                                    }
                                }
                            }
                        )
                    }
                    Spacer() // Đẩy nút về phía trên cùng
                }
            }
        }
    }
}
