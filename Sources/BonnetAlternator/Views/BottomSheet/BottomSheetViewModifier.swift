//
//  BottomSheetViewModifier.swift
//  
//
//  Created by Ana Márquez on 28/06/2023.
//

import Foundation
import SwiftUI

struct BottomSheetViewModifier<CustomContent: View>: ViewModifier {
    @Binding var presented: Bool
    
    let bgType: BottomSheetBGType
    let customContent: CustomContent
    
    init(isPresented: Binding<Bool>,
         bgType: BottomSheetBGType = .notBG,
         @ViewBuilder customContent: () -> CustomContent) {
        
        self._presented = isPresented
        self.bgType = bgType
        self.customContent = customContent()
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Handle BG presentation with presented binding
            if self.presented, bgType != .notBG {
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeIn, value: presented)
                    .onTapGesture {
                        guard bgType == .blurDismissableBG else { return }
                        withAnimation {
                            self.presented = false
                        }
                    }
            }
            
            BottomSheetView(isPresented: $presented) {
                customContent
            }
        }
    }
}

extension View {
    func presentBottomSheet<CustomContent: View>(presented: Binding<Bool>,
                                                 bgType: BottomSheetBGType = .notBG,
                                                 @ViewBuilder customContent: () -> CustomContent) -> some View {
        return modifier(BottomSheetViewModifier(isPresented: presented, bgType: bgType, customContent: customContent))
    }
}
