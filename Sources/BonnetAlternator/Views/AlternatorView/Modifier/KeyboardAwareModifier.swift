//
//  KeyboardAwareModifier.swift
//  
//
//  Created by Ana Márquez on 25/07/2023.
//
// Source: https://stackoverflow.com/questions/57746006/how-to-get-the-keyboard-height-on-multiple-screens-with-swiftui-and-move-the-but

#if os(iOS)
import SwiftUI
import Combine

internal struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @Binding var shouldUpdate: Bool

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
       ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, shouldUpdate ? keyboardHeight : 0)
            .onReceive(keyboardHeightPublisher) {
                debugPrint("Keyboard height: \($0), should update: \(shouldUpdate)")
                self.keyboardHeight = $0
            }
    }
}

extension View {
    internal func updatePaddingWithKeyboardChanges(_ allowChanges: Binding<Bool> = .constant(true)) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier(shouldUpdate: allowChanges))
    }
}
#endif
