//
//  AlternatorViewModifier.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

#if os(iOS)
import SwiftUI

struct AlternatorViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let viewModel: AlternatorViewModel
    let logoImage: LogoIcon?
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .fullScreenCover(isPresented: $isPresented) {
            AlternatorView(viewModel: viewModel, isPresented: $isPresented, logoImage: logoImage)
        }
    }
}

extension View {
    public func showChargingUI(_ presented: Binding<Bool>,
                               logoImage: LogoIcon? = nil,
                               delegate: TokenGeneratorDelegate?) -> some View {
        
        let viewModel = AlternatorViewModel(tokenDelegate: delegate)
        return self.modifier(AlternatorViewModifier(isPresented: presented, viewModel: viewModel, logoImage: logoImage))
    }
}
#endif
