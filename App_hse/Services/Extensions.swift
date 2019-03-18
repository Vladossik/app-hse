//
//  Extensions.swift
//  App_hse
//
//  Created by Vladislava on 06/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
