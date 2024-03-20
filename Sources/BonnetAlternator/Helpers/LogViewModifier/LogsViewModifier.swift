//
//  LogsViewModifier.swift
//  Bonnet
//
//  Created by Ana Marquez on 31/01/2024.
//

import SwiftUI

struct LogsViewModifier: ViewModifier {
    @StateObject var viewModel: LogService = .shared
    
    @State private var size: CGSize = .zero
    @State private var showLogs: Bool = false
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            if #available(iOS 15.0, *) {
                content
                    .background {
                        GeometryReader(content: { geometry in
                            Color.clear
                                .onAppear(perform: {
                                    self.size = geometry.size
                                })
                        })
                    }
            } else {
                content
            }
            
            FloatingView {
                Button {
                    self.showLogs.toggle()
                } label: {
                    Image(systemName: "apple.terminal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                        .frame(width: 20)
                        .padding(12)
                }
                .background(Color.white)
                .clipShape(Circle())
                .frame(width: 44, height: 44)
                .padding(.vertical, 16)

//                ButtonIconWidget(configuration: .init(image: .init(name: "apple.terminal", fromSystem: true), containerInset: .init(all: 0), imageInset: 12)) {
//                    self.showLogs.toggle()
//                }
//                .frame(width: 44, height: 44)
//                .padding(.vertical, 16)
            }

            if self.showLogs {
                FloatingView {
                    
                    VStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Button {
                                    self.viewModel.clear()
                                } label: {
                                    Text("Clear")
                                        .font(.callout)
                                        .foregroundColor(Color.black)
                                }
                                Spacer()
                                
                                Button {
                                    self.showLogs.toggle()
                                } label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 12)
                                        .padding(8)
                                }
                                .frame(width: 24, height: 24)
                                .background(Color.gray)
                                .clipShape(Circle())
                            }
                            
                            List(self.viewModel.logs) { log in
                                Text(log.date, style: .time)
                                    .font(.callout)
                                    .foregroundColor(.black)
                                + Text(" \(log.text)")
                                    .font(.callout)
                                    .foregroundColor(log.textColor)
                            }
                        }
                        .padding(8)
                    }
                    .background(Color.white)
                    .frame(height: size.height / 3)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.2), radius: 8)
                    .padding(16)
                }
            }
        }
    }
}

extension View {
    /// Will add button that will open a terminal showing the logs added to the LogService
    func addLogsFloatingButton() -> some View {
        modifier(LogsViewModifier())
    }
}
