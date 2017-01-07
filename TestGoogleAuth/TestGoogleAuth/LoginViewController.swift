//
//  LoginViewController.swift
//  TestGoogleAuth
//
//  Created by Raymond Brion on 06/01/2017.
//  Copyright © 2017 Raymond Brion. All rights reserved.
//

import Cocoa
import AppAuth
import GTMSessionFetcher
import WebKit

class LoginViewController: NSViewController, WKNavigationDelegate {

  let kIssuer = "https://accounts.google.com"
  let kClientID = "CLIENT ID NIMO xxxxxxxx.apps.googleusercontent.com"
  let kClientSecret = "CLIENT SECRET NIMO"
  let kRedirectURI = "REDIRECT URI NIMO com.googleusercontent.apps.xxxxxxxxxxxxxxxx:/oauthredirect"
  let kAuthorizerKey = "authorization"
  
  var webView: WKWebView?
  var authRequest: OIDAuthorizationRequest?
  
  @IBOutlet weak var containerView: NSView!
  @IBOutlet weak var loginButton: NSButton!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(LoginViewController.handleEvent(_:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
      
      self.webView = WKWebView()
      self.webView?.navigationDelegate = self
      self.webView?.translatesAutoresizingMaskIntoConstraints = false
      self.containerView.addSubview(self.webView!)
      
      let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webview":self.webView!])
      let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webview]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webview":self.webView!])
      
      self.containerView.addConstraints(vConstraints)
      self.containerView.addConstraints(hConstraints)
    }
    
  @IBAction func loginButtonTapped(_ sender: Any) {
    
    let issuer = URL.init(string: kIssuer)
    let redirectURI = URL.init(string: kRedirectURI)
    
    
    OIDAuthorizationService.discoverConfiguration(forIssuer: issuer!, completion: {(configuration:OIDServiceConfiguration?, error:Error?) -> Void in
      
      let request = OIDAuthorizationRequest.init(configuration: configuration!, clientId: self.kClientID, clientSecret: self.kClientSecret, scopes: [OIDScopeOpenID,OIDScopeProfile], redirectURL: redirectURI!, responseType: OIDResponseTypeCode, additionalParameters: nil)
      self.authRequest = request
      
      self.webView!.load(URLRequest(url:request.authorizationRequestURL()))
    })
  }
  
  func handleEvent(_ event: NSAppleEventDescriptor!, replyEvent: NSAppleEventDescriptor!) {
    let URLString = event?.paramDescriptor(forKeyword: keyDirectObject)?.stringValue
    let url = URL.init(string: URLString!)
    
    let query = OIDURLQueryComponent.init(url: url!)
    
    let response = OIDAuthorizationResponse.init(request: self.authRequest!, parameters: (query?.dictionaryValue)!)

    let tokenRequest = response?.tokenExchangeRequest()
    
    OIDAuthorizationService.perform(tokenRequest!, callback: {(tokenResponse:OIDTokenResponse?, error:Error?) -> Void in
      print("ACCESS TOKEN \(tokenResponse!.accessToken!)")
      print("REFRESH TOKEN \(tokenResponse!.refreshToken!)")
    } )
  }
}
