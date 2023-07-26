//
//  WebViewUI.swift
//  
//
//  Created by Ana Márquez on 21/06/2023.
//

#if os(iOS)
import WebKit
import SwiftUI

struct WebViewUI: UIViewRepresentable {
    let webView: WKWebView
        
    func makeUIView(context: Context) -> WKWebView {
        self.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
#endif

