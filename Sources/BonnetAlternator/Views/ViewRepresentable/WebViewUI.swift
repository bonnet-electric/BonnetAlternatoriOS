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
    private let webViewNavigationDelegate = WebViewNavigationDelegate()
    
    init(webView: WKWebView) {
        self.webView = webView
        self.webView.scrollView.delegate = scrollDelegate
        self.webView.navigationDelegate = webViewNavigationDelegate
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

fileprivate class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        debugPrint("[Bonnet Alternator] [Web delegate] didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("[Bonnet Alternator] [Web delegate] didFinish navigation")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("[Bonnet Alternator] [Web delegate] didFail navigation with error: \(error.message)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        debugPrint("[Bonnet Alternator] [Web delegate] didFailProvisionalNavigation with error: \(error.message)")
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        debugPrint("[Bonnet Alternator] [Web delegate] contentProcessDidTerminate")
    }
}
#endif
