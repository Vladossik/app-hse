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
    let connectionUrl = "https://oauth.vk.com/authorize"
    let clientId = "6849870"

    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return scopes
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        UIApplication.topViewController()?.present(viewController, animated: true)
    }
    
//    func vkTokenCreated(for sessionId: String, info: [String : String]) {
//        willTokenCreateOrUpdate(info: info)
//    }
//
//    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
//        willTokenCreateOrUpdate(info: info)
//    }
    
    func vkTokenRemoved(for sessionId: String) {
        updateDefaults()
        VKDelegate.user = nil
    }
//    private func willTokenCreateOrUpdate(info: [String : String]) {
//
//        let responce = Just.get(connectionUrl,
//                                params: [
//                                    "client_id": "6849870",
//                                    "redirect_uri": "https://oauth.vk.com/blank.html",
//                                    "token": "access_token"])
//
//        if(!responce.ok)
//        {
//            updateDefaults()
//            return
//        }
//
//        guard
//            let data = responce.content,
//            let loginModel = try? JSONDecoder().decode(LogInModel.self, from: data)
//            else { return }
//
//        updateDefaults(id: info["user_id"]!,
//                       token: info["access_token"]!,
//                       authType: "VK",
//                       name: loginModel.name!,
//                       avatar: loginModel.avatar ?? "",
//                       serverID: loginModel.serverID ?? 0)
//
//        VKDelegate.user = loginModel
//    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String])  {
        let responce = Just.get(connectionUrl,
                                params: [
                                    "client_id": clientId,
                                    "redirect_uri": "https://oauth.vk.com/blank.html",
//                                    "response_type" : "token",
                                    "token": info["access_token"]!])
        if(!responce.ok)
        {
            updateDefaults()
            return
        }

//        let link: String = try! String(contentsOf: responce.url!)
//        let session = URLSession(configuration: .default)
//        var dataTask: URLSessionDataTask?
//
//        dataTask = session.dataTask(with: URL(string: link) {
//            [weak self] data, r, error in
//            guard let self = self else { return }
//
//             if error == nil, let data = data {
//             let response = try? JSONDecoder().decode(ProfileUser.self, from: data)
//             guard let userData = response?.response[0] else { return }
//
//                guard
//                    let data = responce.content,
//                    let loginModel = try? JSONDecoder().decode(LogInModel.self, from: data)
//                    else { return }
//
//                updateDefaults(id: info["user_id"]!,
//                               token: info["access_token"]!,
//                               authType: "VK",
//                               name: loginModel.name!,
//                               avatar: loginModel.avatar ?? "",
//                               serverID: loginModel.serverID ?? 0)
//
//                VKDelegate.user = loginModel
//        }
//            },
//         dataTask?.resume()
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
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        
        let responce = Just.get(connectionUrl,
                                params: [
                                    "integration_id":info["user_id"]!,
                                    "token": info["access_token"]!])
       
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

func authorize( success: @escaping ([String : String]) -> (), onError: @escaping (VKError) -> ())
{
    VK.sessions.default.logIn(
        onSuccess: success,
        onError: onError
    )
}

