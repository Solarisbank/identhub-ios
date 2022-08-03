//
//  ModuleFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public class ModuleFactoryMock: ModuleFactory {
    public var qesMock: QESCoordinatorFactoryMock?
    
    public init() {}

    public func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory? {
        qesMock
    }
}
