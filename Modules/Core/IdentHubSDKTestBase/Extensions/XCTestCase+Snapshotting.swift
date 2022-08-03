//
//  XCTestCase+Snapshotting.swift
//  IdentHubSDKTestBase
//

import XCTest
import SnapshotTesting
import UIKit

public extension XCTestCase {
    func assertSnapshot(for viewController: UIViewController, isRecording: Bool = false, file: StaticString = #file, testName: String = #function) {
        let languageCode = CommandLine.locale?.languageCode ?? Locale.current.languageCode!

        if #available(iOS 13.0, *) {
            viewController.overrideUserInterfaceStyle = .light
        }

        SnapshotTesting.assertSnapshot(
            matching: viewController,
            as: .custom,
            record: isRecording,
            file: file,
            testName: languageCode + "_" + testName
        )
        
        viewController.removeFromParent()
    }
}

private extension Snapshotting where Value == UIViewController, Format == UIImage {
    private static var size: CGSize { CGSize(width: 320, height: 568) } // iPhone 5s

    static var custom: Self {
        var snapshotting = Self.image(
            precision: 1.0,
            size: Snapshotting.size
        )
        snapshotting.diffing = .resized(.image(precision: 1.0, scale: 1.0), scale: 1.0)
        return snapshotting
    }
}

private extension Diffing where Value == UIImage {
    static func resized(_ diffing: Self, scale: CGFloat) -> Self {
        Diffing { value in
            return diffing.toData(value.scaled(scale))
        } fromData: { data in
            diffing.fromData(data)
        } diff: { old, new in
            return diffing.diff(old, new.scaled(1.0))
        }
    }
}

private extension UIImage {
    func scaled(_ scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
