//
//  Image.swift
//  IdentHubSDKCore
//

import UIKit

public enum Image {
    public enum Shared: String, CaseIterable {
        case closeButton = "close_btn"
    }
}

public extension Image.Shared {
    func image() -> UIImage {
        Bundle.current.image(named: rawValue)
    }
}
