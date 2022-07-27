//
//  RuntimeModuleFactory.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

private extension RuntimeModuleFactory {
    private enum Configuration {
        static let QESModuleClassName = "IdentHubSDKQES.QESModule"
    }
}

public final class RuntimeModuleFactory: ModuleFactory {
    init() {}

    public func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory? {
        makeModule(with: Configuration.QESModuleClassName, serviceLocator: serviceLocator)
    }

    private func makeModule<M>(with className: String, serviceLocator: ModuleServiceLocator) -> M? {
        guard let moduleClass = NSClassFromString(className) as? Module.Type else {
            return nil
        }
        return moduleClass.init(serviceLocator: serviceLocator) as? M
    }
}
