//
//  ViewController.swift
//  AppAuth-LinkedInLogin
//
//  Created by Henrique Valcanaia on 2019-11-21.
//  Copyright © 2019 Henrique Valcanaia. All rights reserved.
//

import AppAuth
import UIKit

protocol OAuthKeys {
    var clientId: String { get }
    var clientSecret: String { get }
}

protocol OAuthReachable {
    var authorizationURL: URL { get }
    var accessTokenURL: URL { get }
}

struct LinkedInDataProvider {
    private static let baseURL = URL(string: "https://www.linkedin.com/oauth/v2/")!
}

extension LinkedInDataProvider: OAuthKeys {
    var clientId: String { return LinkedInClientId }
    var clientSecret: String { return LinkedInClientSecret }
}

extension LinkedInDataProvider: OAuthReachable {
    var authorizationURL: URL {
        return LinkedInDataProvider.baseURL.appendingPathComponent("authorization")
    }
    
    var accessTokenURL: URL {
        return LinkedInDataProvider.baseURL.appendingPathComponent("accessToken")
    }
}

typealias OAuthDataProvider = OAuthKeys & OAuthReachable

extension String {
    static func random(length: Int = 21) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

final class ViewController: UIViewController {
    
    private lazy var linkedIn: OAuthDataProvider = {
        return LinkedInDataProvider()
    }()

    @IBAction func startLoginWithLinkedIn(_ sender: Any) {
        let codeVerifier = OIDAuthorizationRequest.generateCodeVerifier()
        let codeChallenge = OIDAuthorizationRequest.codeChallengeS256(forVerifier: codeVerifier)
        
        let config = OIDServiceConfiguration(authorizationEndpoint: self.linkedIn.authorizationURL,
                                             tokenEndpoint: self.linkedIn.accessTokenURL)
        
        let authRequest = OIDAuthorizationRequest(configuration: config,
                                                  clientId: self.linkedIn.clientId,
                                                  clientSecret: self.linkedIn.clientSecret,
                                                  scope: "r_liteprofile",
                                                  redirectURL: LinkedInRedirectURL,
                                                  responseType: OIDResponseTypeCode,
                                                  state: String.random(),
                                                  codeVerifier: codeVerifier,
                                                  codeChallenge: codeChallenge,
                                                  codeChallengeMethod: "",
                                                  additionalParameters: nil)
        
        OIDAuthState.authState(byPresenting: authRequest,
                               presenting: self) { (authState: OIDAuthState?, error: Error?) in
                                if (authState != nil) {
                                    print(authState!)
                                } else {
                                    print(error ?? "no error")
                                }
        }
    }
    
}

