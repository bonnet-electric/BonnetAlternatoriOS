//
//  ToastView.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var style: Toast.Style = .info
    var onTapped: Completion = nil
    
    var body: some View {
        VStack {
            HStack {
                Text(message)
                    .font(.body)
                    .foregroundColor(style.color)
                    .lineLimit(5)
                    .padding(.all, 16)
                Spacer()
            }
            .background(style.color.opacity(0.2))
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(message: "Testing messages")
    }
}
