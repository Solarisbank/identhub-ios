//
//  InstructionHandlerImpl.swift
//  IdentHubSDKFourthline
//

import Foundation
import IdentHubSDKCore

internal enum InstructionOutput: Equatable {
    case nextStep
    case quit
}

// MARK: - InstructionOutput events logic -

typealias InstructionCallback = (InstructionOutput) -> Void

final internal class InstructionHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<InstructionEvent> {
    
    weak var updatableView: ViewController?
    
    internal var colors: Colors
    private var callback: InstructionCallback
    
    init(
        colors: Colors,
        callback: @escaping InstructionCallback
    ) {
        self.colors = colors
        self.callback = callback
    }
    
    func handleEvent(_ event: InstructionEvent) {
        switch event {
        case .triggerContinue: callback(.nextStep)
        case .triggerQuit: callback(.quit)
        }
    }
    
}
