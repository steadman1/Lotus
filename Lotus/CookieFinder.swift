//
//  sp_dcFinder.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/26/24.
//

import SwiftUI
import WebKit

struct CookieFinder: UIViewRepresentable {
    var url: URL
    var cookieName: String
    var onCookieFound: (HTTPCookie) -> Void
    var onIncomingURL: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url)) // Load initially here
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
//        this code below breaks functionality when keyboard is raised
//        by refreshing the view to the original url, idk why i had it
        
//        if webView.url != url && !webView.isLoading {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, cookieName)
            
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: CookieFinder
        var target: String

        init(_ parent: CookieFinder, _ target: String) {
            self.parent = parent
            self.target = target
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies where cookie.name == self.target {
                    self.parent.onCookieFound(cookie)
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            let url = navigationAction.request.url
            
            // Check if the URL is the one you are interested in
            if let url = url, shouldIntercept(url: url) {
                self.parent.onIncomingURL(url)
                decisionHandler(.cancel)

                return
            }
            
            // Allow the web view to continue loading URLs as normal
            decisionHandler(.allow)
        }
        
        private func shouldIntercept(url: URL) -> Bool {
            // Determine whether you should intercept the URL
            // You can check the URL scheme, host, path, or other properties
            // For example, if you're looking for a specific callback:
            return url.scheme == "lotus-for-spotify" && url.host == "spotify-login-callback"
        }
    }
    
    struct WebViewWrapper: UIViewRepresentable {
            let webView: WKWebView
            
            func makeUIView(context: Context) -> WKWebView {
                return webView
            }
            
            func updateUIView(_ uiView: WKWebView, context: Context) {
            }
        }
}

