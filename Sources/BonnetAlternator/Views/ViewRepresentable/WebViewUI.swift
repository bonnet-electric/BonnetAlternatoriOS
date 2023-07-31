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
    
    private let scrollDelegate = ScrollDelegate()
    
    init(webView: WKWebView) {
        self.webView = webView
        self.webView.scrollView.delegate = scrollDelegate
    }
        
    func makeUIView(context: Context) -> WKWebView {
        self.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

fileprivate class ScrollDelegate: NSObject, UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
#endif

