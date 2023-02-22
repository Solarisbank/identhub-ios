//
//  WelcomePageContent.swift
//  IdentHubSDKFourthline
//

import UIKit

struct WelcomePageContent {

    enum PageType {
        case camera, document, location
    }

    /// Page title
    let title: String

    /// Page description
    let description: String

    /// Page type icon
    let pageLogoName: String

    /// Welcome page type
    let type: PageType

    /// Page icon background
    let pageLogoFrameName: String?
}
