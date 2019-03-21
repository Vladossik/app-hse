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

struct defaultsKeys {
    static let authType = "authType"
    static let socialId = "netId"
    static let token = "token"
    static let avatar = "avatar"
    static let name = "name"
    static let serverId = "serverId"
}

final class VKDelegate: SwiftyVKDelegate {
    
    let scopes: Scopes = [.offline, .photos, .wall, .groups]
    public static var user: LogInModel? = nil
//    let connectionUrl = "https://oauth.vk.com/authorize"
    let connectionUrl = "http://127.0.0.1:9292/"
    static let token = "39dd70f2b4d9f9b5f1877fe89bd50462a5a4f15044f7334f9bd5704bdfe012894b9db4f4cc355d8ef365a"
    
    
//    let token = "ee097a26799ae5faa78ed94a5009ce498389b32da2b4779389faaf03f2f06750ac3104717189fcceccead"
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        // Called when SwiftyVK attempts to get access to user account
        // Should return a set of permission scopes
        return scopes
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        // Called when SwiftyVK wants to present UI (e.g. webView or captcha)
        // Should display given view controller from current top view controller
        UIApplication.topViewController()?.present(viewController, animated: true)
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        // Called when user grants access and SwiftyVK gets new session token
        // Can be used to run SwiftyVK requests and save session data
        willTokenCreateOrUpdate(info: info)
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        // Called when existing session token has expired and successfully refreshed
        // You don't need to do anything special here
        willTokenCreateOrUpdate(info: info)
    }
    
    func vkTokenRemoved(for sessionId: String) {
        // Called when user was logged out
        // Use this method to cancel all SwiftyVK requests and remove session data
        updateDefaults()
        VKDelegate.user = nil
    }
    private func willTokenCreateOrUpdate(info: [String : String]) {
        
        let responce = Just.get(connectionUrl,
//                                params: [
//                                    "client_id": "6849870",
//                                    "redirect_uri": "https://oauth.vk.com/blank.html"
//                                    ])
                                    params: [
                                        "integration_id":info["user_id"]!,
                                        "token":info["access_token"]!])
        if(!responce.ok)
        {
            updateDefaults()
            return
        }
        
        guard
            let data = responce.content,
            let loginModel = try? JSONDecoder().decode(LogInModel.self, from: data)
            else { return }
        
        updateDefaults(id: info["user_id"]!,
                       token: info["access_token"]!,
                       authType: "VK",
                       name: loginModel.name!,
                       avatar: loginModel.avatar ?? "",
                       serverID: loginModel.serverID ?? 0)
        
        VKDelegate.user = loginModel
    }
    
    @discardableResult public func silentLogin() -> Bool {
        
        let defaults = UserDefaults.standard
        
        guard
            let authType = defaults.string(forKey: defaultsKeys.authType),
            authType != ""
        else {
           return false
        }
        
        
        if(defaults.string(forKey: defaultsKeys.authType)=="VK")
        {
            let responce = Just.get(connectionUrl,
                                    params: [
                                        "integration_id":defaults.string(forKey: defaultsKeys.socialId)!,
                                        "token": defaults.string(forKey: defaultsKeys.token)!])
            guard
                responce.ok,
                let data = responce.content,
                let loginModel = try? JSONDecoder().decode(LogInModel.self, from: data)
            else {
                updateDefaults()
                return false
            }
            
            updateDefaults(id: defaults.string(forKey: defaultsKeys.socialId)!,
                               token: defaults.string(forKey: defaultsKeys.token)!,
                               authType: "VK",
                               name: loginModel.name!,
                               avatar: loginModel.avatar ?? "",
                               serverID: loginModel.serverID ?? 0)
            VKDelegate.user = loginModel
        }
        return true
    }
    
    private func updateDefaults(id: String = "", token: String = "",
                                authType: String = "", name: String = "",
                                avatar: String = "", serverID: Int64 = -1)
    {
        let defaults = UserDefaults.standard;
        defaults.set(authType, forKey: defaultsKeys.authType)
        defaults.set(token, forKey: defaultsKeys.token)
        defaults.set(id, forKey: defaultsKeys.socialId)
        defaults.set(serverID, forKey: defaultsKeys.serverId)
        defaults.set(avatar, forKey: defaultsKeys.avatar)
        defaults.set(name, forKey: defaultsKeys.name)
    }
    
}
