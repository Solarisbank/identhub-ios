//
//  UIView+AutoLayout.swift
//  IdentHubSDK
//

import UIKit

typealias Constraint = (_ layoutView: UIView) -> NSLayoutConstraint

// swiftformat:disable redundantReturn
internal extension UIView {

    /// Sets equal constraint for provided key an
    ///
    /// - Parameter views: array of view which should have some equal constraint
    /// - Parameter key: constraints key path of each view
    static func equal(views: [UIView], key: KeyPath<UIView, NSLayoutDimension>) {
        guard let first = views.first else { return }
        views.suffix(from: 1).forEach {
            $0.addConstraints { [
                $0.equalTo(first, .width, .width)
            ]
            }
        }
    }

    /// Adds constraints using NSLayoutAnchors, based on description provided in params.
    /// Please refer to helper equal funtions for info how to generate constraints easily.
    ///
    /// - Parameter constraintDescription: closure that returns [Constraint]
    /// - Returns: created constraints
    @discardableResult
    func addConstraints(_ constraintDescription: (UIView) -> [Constraint]) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [Constraint] = constraintDescription(self)
        let nsLayoutConstraints = constraints.map { $0(self) }
        NSLayoutConstraint.activate(nsLayoutConstraints)
        return nsLayoutConstraints
    }

    /// Describes constraint that is equal to constraint from other view.
    /// Example: `equalTo(labelView, \.centerXAnchor, \.centerXAnchor) will align view centerXAnchor to labelView centerXAnchor`
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func equalTo<Anchor, Axis>(_ view: UIView, _ fromAnchor: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(equalTo: view[keyPath: toAnchor], constant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is equal to constraint from other view.
    /// Example: `equalTo(labelView, \.centerXAnchor) will align view centerXAnchor to superview centerXAnchor`
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func equalTo<Anchor>(_ view: UIView, _ fromAnchor: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutXAxisAnchor {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(equalTo: view[keyPath: toAnchor], constant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is equal to constraint from other view.
    /// Example: `equalTo(labelView, \.heightAnchor, \.heightAnchor) will align view heightAnchor to labelView heightAnchor`
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - multiplier: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func equalTo<LayoutDimension>(_ view: UIView, _ fromAnchor: KeyPath<UIView, LayoutDimension>, _ toAnchor: KeyPath<UIView, LayoutDimension>, multiplier: CGFloat = 1, priority: UILayoutPriority? = nil) -> Constraint where LayoutDimension: NSLayoutDimension {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(equalTo: view[keyPath: toAnchor], multiplier: multiplier).set(priority: priority)
        }
    }

    /// Describes constraint that is greater than or equal to constraint from other view.
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func greaterThanOrEqualTo<Anchor, Axis>(_ view: UIView, _ fromAnchor: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(greaterThanOrEqualTo: view[keyPath: toAnchor], constant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is less than or equal to constraint from other view.
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func lessThanOrEqualTo<Anchor, Axis>(_ view: UIView, _ fromAnchor: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(lessThanOrEqualTo: view[keyPath: toAnchor], constant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is greater than or equal to constraint from other view.
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func greaterThanOrEqualTo<Anchor>(_ view: UIView, _ fromAnchor: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutXAxisAnchor {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(greaterThanOrEqualTo: view[keyPath: toAnchor], constant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is greater than or equal to constraint from other view.
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func greaterThanOrEqualTo<LayoutDimension>(_ view: UIView, _ fromAnchor: KeyPath<UIView, LayoutDimension>, _ toAnchor: KeyPath<UIView, LayoutDimension>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where LayoutDimension: NSLayoutDimension {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(greaterThanOrEqualTo: view[keyPath: toAnchor], constant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is greater than or equal to constraint from other view.
    ///
    /// - Parameters:
    ///   - view: that constrain should relate to
    ///   - fromAnchor: constraints key path of current view
    ///   - toAnchor: constraints key path of related view
    ///   - multiplier: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func greaterThanOrEqualTo<LayoutDimension>(_ view: UIView, _ fromAnchor: KeyPath<UIView, LayoutDimension>, _ toAnchor: KeyPath<UIView, LayoutDimension>, multiplier: CGFloat, priority: UILayoutPriority? = nil) -> Constraint where LayoutDimension: NSLayoutDimension {
        return { layoutView in
            layoutView[keyPath: fromAnchor].constraint(greaterThanOrEqualTo: view[keyPath: toAnchor], multiplier: multiplier).set(priority: priority)
        }
    }

    /// Describes constraint that is equal to constraint from superview.
    /// Example: `equal(\.leadingAnchor) will align view leadingAnchor to superview leadingAnchor with defined constant`
    ///
    /// - Parameters:
    ///   - anchor: constraints key path of current view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    /// - Warning: This method uses force-unwrap on view's superview!
    func equal<Anchor, Axis>(_ anchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
        equalTo(superview!, anchor, anchor, constant: constant, priority: priority)
    }

    /// Describes constraint that is equal to constraint from superview.
    /// Example: `equal(\.leadingAnchor) will align view leadingAnchor to superview leadingAnchor`
    ///
    /// - Parameters:
    ///   - anchor: constraints key path of current view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    /// - Warning: This method uses force-unwrap on view's superview!
    func equal<Anchor>(_ anchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority? = nil) -> Constraint where Anchor: NSLayoutXAxisAnchor {
        equalTo(superview!, anchor, anchor, constant: constant, priority: priority)
    }

    /// Describes constraint that is equal to constraint from superview.
    /// Example: `equal(\.heightAnchor, multiplier: 0.5) will align view heightAnchor to superview heightAnchor multiplied by 0.5`
    ///
    /// - Parameters:
    ///   - anchor: constraints key path of current view
    ///   - multiplier: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint.
    /// - Warning: This method uses force-unwrap on view's superview!
    func equal<LayoutDimension>(_ anchor: KeyPath<UIView, LayoutDimension>, multiplier: CGFloat = 1, priority: UILayoutPriority? = nil) -> Constraint where LayoutDimension: NSLayoutDimension {
        equalTo(superview!, anchor, anchor, multiplier: multiplier, priority: priority)
    }

    /// Describes edges that are equal to superview edges
    /// - Returns: created constraints
    func equalEdges() -> [Constraint] {
        [
            equal(.top),
            equal(.bottom),
            equal(.leading),
            equal(.trailing)
        ]
    }

    /// Describes edges that are equal to superview edges with constant
    /// - Parameters:
    ///   - constant: margin for all edges
    /// - Returns: created constraints
    func equalEdges(_ constant: CGFloat) -> [Constraint] {
        [
            equal(.top, constant: constant),
            equal(.bottom, constant: -constant),
            equal(.leading, constant: constant),
            equal(.trailing, constant: -constant)
        ]
    }

    /// Describes edges that are equal to superview safe area edges
    /// - Returns: created constraints
    /// - Warning: This method uses force-unwrap on view's superview!
    @available(iOS 13.0, *)
    func equalSafeAreaEdges() -> [Constraint] {
        [
            equalTo(superview!, .top, .safeAreaTop),
            equalTo(superview!, .bottom, .safeAreaBottom),
            equal(.leading),
            equal(.trailing)
        ]
    }

    /// Describes constraint that is equal to width or height constant.
    /// Example: `equal(\.heightAnchor, 100) will align view heightAnchor to 100 constant value`
    ///
    /// - Parameters:
    ///   - anchor: constraints key path of current view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func equalConstant<LayoutDimension>(_ anchor: KeyPath<UIView, LayoutDimension>, _ constant: CGFloat, _ priority: UILayoutPriority? = nil) -> Constraint where LayoutDimension: NSLayoutDimension {
        return { layoutView in
            layoutView[keyPath: anchor].constraint(equalToConstant: constant).set(priority: priority)
        }
    }

    /// Describes constraint that is greater or equal to width or height constant.
    /// Example: `greaterThanOrEqualConstant(\.heightAnchor, 100) will align view heightAnchor to 100 or more constant value`
    ///
    /// - Parameters:
    ///   - anchor: constraints key path of current view
    ///   - constant: value
    ///   - priority: layout priority used to indicate the relative importance of constraints.
    /// - Returns: created constraint
    func greaterThanOrEqualConstant<LayoutDimension>(_ anchor: KeyPath<UIView, LayoutDimension>, _ constant: CGFloat, _ priority: UILayoutPriority? = nil) -> Constraint where LayoutDimension: NSLayoutDimension {
        return { layoutView in
            layoutView[keyPath: anchor].constraint(greaterThanOrEqualToConstant: constant).set(priority: priority)
        }
    }

    /// Sets hugging and compression priorities in provided axis.
    func lock(axis: Axis) {
        switch axis {
        case .horizontal:
            setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
        case .vertical:
            setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultHigh, for: .vertical)
        case .both:
            setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
        case .none:
            setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
    }
}

extension KeyPath where Root == UIView, Value == NSLayoutYAxisAnchor {

    static var top: KeyPath<UIView, NSLayoutYAxisAnchor> {
        \.topAnchor
    }

    static var bottom: KeyPath<UIView, NSLayoutYAxisAnchor> {
        \.bottomAnchor
    }

    @available(iOS 11.0, *)
    static var safeAreaTop: KeyPath<UIView, NSLayoutYAxisAnchor> {
        \.safeAreaLayoutGuide.topAnchor
    }

    @available(iOS 11.0, *)
    static var safeAreaBottom: KeyPath<UIView, NSLayoutYAxisAnchor> {
        \.safeAreaLayoutGuide.bottomAnchor
    }

    static var centerY: KeyPath<UIView, NSLayoutYAxisAnchor> {
        \.centerYAnchor
    }
}

extension KeyPath where Root == UIView, Value == NSLayoutXAxisAnchor {

    static var leading: KeyPath<UIView, NSLayoutXAxisAnchor> {
        \.leadingAnchor
    }

    static var left: KeyPath<UIView, NSLayoutXAxisAnchor> {
        \.leftAnchor
    }

    static var right: KeyPath<UIView, NSLayoutXAxisAnchor> {
        \.rightAnchor
    }

    static var trailing: KeyPath<UIView, NSLayoutXAxisAnchor> {
        \.trailingAnchor
    }

    static var centerX: KeyPath<UIView, NSLayoutXAxisAnchor> {
        \.centerXAnchor
    }
}

extension KeyPath where Root == UIView, Value == NSLayoutDimension {

    static var width: KeyPath<UIView, NSLayoutDimension> {
        \.widthAnchor
    }

    static var height: KeyPath<UIView, NSLayoutDimension> {
        \.heightAnchor
    }
}

private extension NSLayoutConstraint {

    func set(priority: UILayoutPriority?) -> Self {
        priority.flatMap { self.priority = $0 }
        return self
    }
}

public enum Axis {

    /// Limit ViewContainer class to set only traling, leading, width and centerX contraints.
    case horizontal

    /// Limit ViewContainer class to set only top, bottom, height and centerY contraints.
    case vertical

    /// Don't limit ViewContainer with setting constraints.
    case both

    /// Skip all constraints for specific type.
    case none
}
