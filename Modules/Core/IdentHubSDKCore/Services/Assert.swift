//
//  Assert.swift
//  IdentHubSDKCore
//

public enum Assert {
    public static func notNil<T: AnyObject>(_ instance: T?) {
        if instance == nil {
            print("Warning! Instance \(String(describing: instance)) has been released.")
        }
    }
}
