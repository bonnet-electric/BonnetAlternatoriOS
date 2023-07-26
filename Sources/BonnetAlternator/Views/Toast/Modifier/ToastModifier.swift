//
//  ToastModifier.swift
//  
//
//  Created by Ana Márquez on 21/06/2023.
//

import SwiftUI

@MainActor
struct ToastModifier: ViewModifier {
    
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            let offset: CGFloat = toast?.position == .bottom ? -16 : 16
            mainToastView()
                .offset(y: offset)
                .animation(.spring(), value: toast)
        }
        .onChange(of: toast) { newValue in
            self.show()
        }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast {
            VStack {
                if toast.position == .bottom {
                    Spacer()
                }
                
                ToastView(message: toast.message) {
                    self.dismiss()
                }
                
                if toast.position == .top {
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Present & dismiss
    
    private func show() {
        guard let toast else { return }
        
        // TODO: Check this issue
//        UIImpactFeedbackGenerator(style: .light)
//            .impactOccurred()
        
        guard toast.duration > 0 else { return }
        workItem?.cancel()
        
        let task = DispatchWorkItem { dismiss() }
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
    }
    
    private func dismiss() {
        withAnimation { toast = nil }
        workItem?.cancel()
        workItem = nil
    }
}

// MARK: - Extension

extension View {
    func presentToast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
