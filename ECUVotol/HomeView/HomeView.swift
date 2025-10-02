//
//  HomeView.swift
//  ECUVotol
//
//  Created by Tam Vu on 2/10/25.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black // Nền màu xám
                .edgesIgnoringSafeArea(.all) // Để chiếm toàn bộ màn hình
            
            NavigationView {
                VStack {
                    // Header View
                    Text("Tâm Xe Điện")
                        .font(.headline) // Kích thước chữ
                        .foregroundColor(.white) // Màu chữ trắng
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: 50
                        ) // Kích thước của header
                        .background(Color.black) // Nền màu đen

                    // Hàng chứa 3 view
                    HStack {
                        // View 1
                        NavigationLink(
                            destination: BluetoothListView()
                        ) { // Sử dụng NavigationLink
                            VStack {
                                Image("ic_logo") // Hình ảnh
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: 70,
                                        height: 70
                                    ) // Kích thước của hình ảnh
                                Text("Votol") // Văn bản phía dưới hình ảnh
                                    .font(.headline) // Kích thước chữ
                                    .foregroundColor(.black) // Màu chữ đen
                            }
                        }
                                   
                        Spacer() // Khoảng cách giữa các view
                                   
                        // View 2
                        VStack {
                            Image("ic_logo") // Hình ảnh
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 70,
                                    height: 70
                                ) // Kích thước của hình ảnh
                            Text("Vinfast") // Văn bản phía dưới hình ảnh
                                .font(.headline) // Kích thước chữ nhỏ
                                .foregroundColor(.black) // Màu chữ đen
                        }
                                   
                        Spacer() // Khoảng cách giữa các view
                                   
                        // View 3
                        VStack {
                            Image("ic_logo") // Hình ảnh
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 70,
                                    height: 70
                                ) // Kích thước của hình ảnh
                            Text("ND") // Văn bản phía dưới hình ảnh
                                .font(.headline)// Kích thước chữ nhỏ
                                .foregroundColor(.black) // Màu chữ đen
                        }
                    }
                    .padding() // Khoảng cách cho HStack
                    .frame(maxWidth: .infinity) // Chiếm toàn bộ chiều rộng

                    Spacer() // Khoảng cách giữa header và nội dung dưới
                }
                .background(Color.white)
            }
        }
    }
}
