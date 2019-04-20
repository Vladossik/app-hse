//
//  VKDelegate.swift
//  App_hse
//
//  Created by Vladislava on 03/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation
import SwiftyVK
import Just
import WebKit

struct DefaultsKeys {
    static let accessToken = "access_token"
    static let userId = "user_id"
}

final class VKDelegate: SwiftyVKDelegate {
    
    let scopes: Scopes = [.offline, .photos, .wall, .groups]
    let connectionUrl = "https://oauth.vk.com/authorize"
    let clientId = "6849870"

    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return scopes
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        UIApplication.topViewController()?.present(viewController, animated: true)
    }
    
    func vkTokenRemoved(for sessionId: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: DefaultsKeys.accessToken)
        defaults.removeObject(forKey: DefaultsKeys.userId)
        
        clearSessionData()
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String])  {
        guard
            let userId = info["user_id"],
            let accessToken = info["access_token"]
        else { return }
        
        updateDefaults(id: userId, token: accessToken)
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        guard
            let userId = info["user_id"],
            let accessToken = info["access_token"]
       else { return }
        
        updateDefaults(id: userId, token: accessToken)
    }
    
    private func updateDefaults(id: String, token: String) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: DefaultsKeys.accessToken)
        defaults.set(id, forKey: DefaultsKeys.userId)
    }
    
    private func clearSessionData() {
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        DispatchQueue.main.async {
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
        }
        UserDefaults.standard.synchronize()
    }
}

func authorize(success: @escaping ([String : String]) -> (), onError: @escaping (VKError) -> ()) {
    VK.sessions.default.logIn(
        onSuccess: success,
        onError: onError
    )
}
