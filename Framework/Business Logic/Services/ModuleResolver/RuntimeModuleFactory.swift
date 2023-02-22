//
//  RuntimeModuleFactory.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

private extension RuntimeModuleFactory {
    private enum Configuration {
        static let COREModuleClassName = "IdentHubSDKCore.CoreModule"
        static let QESModuleClassName = "IdentHubSDKQES.QESModule"
        static let FourthlineClassName = "IdentHubSDKFourthline.FourthlineModule"
        static let BankModuleClassName = "IdentHubSDKBank.BankModule"
    }
}

public final class RuntimeModuleFactory: ModuleFactory {
    init() {}

    public func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory? {
        makeModule(with: Configuration.QESModuleClassName, serviceLocator: serviceLocator)
    }
    
    public func makeFourthline(serviceLocator: ModuleServiceLocator) -> FourthlineCoordinatorFactory? {
        makeModule(with: Configuration.FourthlineClassName, serviceLocator: serviceLocator)
    }
    
    public func makeBank(serviceLocator: ModuleServiceLocator) -> BankCoordinatorFactory? {
        makeModule(with: Configuration.BankModuleClassName, serviceLocator: serviceLocator)
    }
    
    public func makeCore(serviceLocator: ModuleServiceLocator) -> CoreCoordinatorFactory? {
        makeModule(with: Configuration.COREModuleClassName, serviceLocator: serviceLocator)
    }

    private func makeModule<M>(with className: String, serviceLocator: ModuleServiceLocator) -> M? {
        guard let moduleClass = NSClassFromString(className) as? Module.Type else {
            return nil
        }
        return moduleClass.init(serviceLocator: serviceLocator) as? M
    }
}
