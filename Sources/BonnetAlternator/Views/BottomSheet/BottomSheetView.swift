//
//  BottomSheetView.swift
//  
//
//  Created by Ana Márquez on 28/06/2023.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @Binding var isPresented: Bool
    var content: Content
    
    init(isPresented: Binding<Bool>,
         @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content()
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                content
                    .padding(.vertical, 32)
                    .padding(.bottom, 16)
                    .background(Color(hex: "F4F1F2"))
                    .cornerRadius(16)
                    .transition(.move(edge: .bottom))
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.height > 100 {
                                withAnimation {
                                    self.isPresented = false
                                }
                            }
                        }))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(isPresented: .constant(true)) {
            VStack {
                Text("My large title here")
                    .font(.title)
                Text("This is just some testing information that will allow you to see how the bottom sheet works")
            }
        }
    }
}
