//
//  SpinnerWidget.swift
//  
//
//  Created by Ana Márquez on 10/07/2023.
//

#if os(iOS)
import SwiftUI

struct SpinnerWidget: View {
    @State private var isAnimating: Bool = false
    
    let color: Color
    init(color: Color = .init(hex: "#4C4549")) {
        self.color = color
    }
    var foreverAnimation: Animation {
        Animation.linear(duration: 3.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
            .animation(self.isAnimating ? foreverAnimation : .default)
            .onAppear { self.isAnimating = true }
            .onDisappear { self.isAnimating = false }
    }
}

struct SpinnerWidget_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerWidget()
    }
}
#endif
