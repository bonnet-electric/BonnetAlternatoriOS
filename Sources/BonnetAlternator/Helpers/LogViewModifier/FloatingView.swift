//
//  FloatingView.swift
//
//
//  Created by Ana Marquez on 20/03/2024.
//

import SwiftUI

// TODO: Find the way to add bounderies to pin the view to specific areas taking into account the view size
struct FloatingView<Content: View>: View {
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    @ViewBuilder var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        self.content
            .offset(x: self.currentPosition.width, y: self.currentPosition.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width,
                                                      height: value.translation.height + self.newPosition.height)
                    }
                    .onEnded { value in
                        self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width,
                                                      height: value.translation.height + self.newPosition.height)
                        
                        self.newPosition = self.currentPosition
                    }
            )
    }
}
