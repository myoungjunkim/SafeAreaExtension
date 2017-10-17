//
//  SafeAreaExtension.swift
//  SafeAreaExtension
//
//  Created by Myoungjun Kim on 2017. 10. 10..
//  Copyright © 2017년 Myoungjun Kim. All rights reserved.
//

import UIKit

// MARK: - extention
@available(iOS 11, *)
public class SafeAreaExtension {
    public var insetsDidChange: ((UIEdgeInsets) -> ())?
    private weak var view: UIView?
    fileprivate init(view: UIView) {
        self.view = view
    }
}

extension UIView {
    @available(iOS 11, *)
    private struct AssociatedKey {
        static var safeArea: UInt8 = 0
    }
    
    @available(iOS 11, *)
    public var safeArea: SafeAreaExtension {
        _ = UIView.swizzleSafeAreaInsetsDidChange
        guard let safeArea = objc_getAssociatedObject(self, &AssociatedKey.safeArea) as? SafeAreaExtension else {
            let safeArea = SafeAreaExtension(view: self)
            objc_setAssociatedObject(self, &AssociatedKey.safeArea, safeArea, .OBJC_ASSOCIATION_RETAIN)
            return safeArea
        }
        return safeArea
    }
}

// MARK: - swizzling
extension UIView {
    @available(iOS 11, *)
    fileprivate static var swizzleSafeAreaInsetsDidChange: () = {
        let originalSelector = #selector(UIView.safeAreaInsetsDidChange)
        let swizzledSelector = #selector(UIView.sa_safeAreaInsetsDidChange)
        
        guard
            let originalMethod = class_getInstanceMethod(UIView.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIView.self, swizzledSelector)
            else { return }
        
        let flag = class_addMethod(UIView.self,
                                   originalSelector,
                                   method_getImplementation(swizzledMethod),
                                   method_getTypeEncoding(swizzledMethod))
        
        if flag {
            class_replaceMethod(UIView.self,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    @available(iOS 11, *)
    @objc private func sa_safeAreaInsetsDidChange() {
        self.sa_safeAreaInsetsDidChange()
        safeArea.insetsDidChange?(safeAreaInsets)
    }
}
