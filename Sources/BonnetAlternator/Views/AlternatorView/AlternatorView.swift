//
//  AlternatorView.swift
//  
//
//  Created by Ana Márquez on 20/06/2023.
//

#if os(iOS)
import SwiftUI

struct AlternatorView: View {
    @StateObject private var model: AlternatorViewModel
    @Binding var isPresented: Bool
    @State private var closeBottomSheetPresented: Bool = false
    
    var parentController: UIViewController?
    private let logoImage: LogoIcon?
    
    init(viewModel: AlternatorViewModel,
         isPresented: Binding<Bool> = .constant(true),
         parentController: UIViewController? = nil,
         logoImage: LogoIcon? = nil
    ) {
        self._model = .init(wrappedValue: viewModel)
        self._isPresented = isPresented
        self.parentController = parentController
        self.logoImage = logoImage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if let logoImage {
                    Image(logoImage.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoImage.size.width, height: logoImage.size.height, alignment: .leading)
                }
                
                Spacer()
                
                if self.model.isLoading {
                    SpinnerWidget()
                        .frame(width: 28, height: 28)
                }
                
                if self.model.environment == .staging {
                    Menu {
                        Button("Test open Browser") {
                            self.model.openBrowser()
                        }
                        Button("Test JWToken") {
                            self.model.requestJSToken()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.sdkGrey)
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.black)
                        }
                        .frame(width: 28, height: 28)
                    }
                }
                
                Button {
                    withAnimation {
                        self.closeBottomSheetPresented = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E1D9DE8C"))
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.black)
                    }
                    .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 44)
            .background(Color.white)
            
            WebViewUI(webView: model.webView)
                .onAppear {
                    self.model.loadUrl()
                }
        }
        .updatePaddingWithKeyboardChanges(self.$model.allowKeyboardChanges)
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear(perform: {
            self.model.isLoading = true
        })
        .presentToast($model.toast)
        .presentBottomSheet(presented: self.$closeBottomSheetPresented,
                            bgType: .blurDismissableBG
        ) {
            VStack(spacing: 24) {
                Text("Are you sure you want to exit charging?")
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button {
                        withAnimation {
                            self.closeBottomSheetPresented = false
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("No")
                                .font(.body)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .frame(height: 44)
                        .background(Color.black)
                        .cornerRadius(16)
                    }
                    .foregroundColor(.white)
                    
                    Button {
                        if let parentController {
                            parentController.presentedViewController?.dismiss(animated: true)
                        }
                        self.isPresented = false
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 1)

                            HStack {
                                Spacer()
                                Text("Yes")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .frame(height: 44)
                    }
                    .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct AlternatorView_Previews: PreviewProvider {
    static var previews: some View {
        AlternatorView(viewModel: .init(tokenDelegate: nil))
    }
}
#endif
