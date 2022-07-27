//
//  ModulerServiceLocatorMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public struct ModuleServiceLocatorMock: ModuleServiceLocator {
    public var apiClient: APIClient
    public var configuration: Configuration
    public var presenter: Presenter
    public var fileStorage: FileStorage
    public var storage: Storage

    public init(
        apiClient: APIClient = APIClientMock(),
        configuration: Configuration = .init(colors: ColorsImpl()),
        presenter: Presenter = PresenterMock(),
        fileStorage: FileStorage = FileStorageMock(),
        storage: Storage = StorageMock()
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.presenter = presenter
        self.fileStorage = fileStorage
        self.storage = storage
    }
}
