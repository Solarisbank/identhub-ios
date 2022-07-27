//
//  Bundle+Extensions.swift
//  IdentHubSDKCore
//

import UIKit

public extension Bundle {
    static var core: Bundle {
        return Bundle.current
    }

    func image(named name: String) -> UIImage {
        guard let image = UIImage(named: name, in: self, compatibleWith: nil) else {
            fatalError("Image \(name) not found in bundle \(self)")
        }
        return image
    }
}
