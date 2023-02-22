//
//  StepsProgressView.swift
//  IdentHubSDKCore
//

import UIKit

let viewsPadding = 5
let stepsAmount = 4

/// Identificaiton progress step views
/// Used for informing user how many steps was passed
public final class StepsProgressView: UIView {

    // MARK: - Properties methods -
    var datasource: StepsProgressViewDataSource? {
        didSet {
            setupStepViews()
        }
    }

    private var highlightColor: UIColor?
    private var regularColor: UIColor?
    private var stepViews: [UIView] = []

    // MARK: - Lifecycle methods -
    public override func layoutSubviews() {
        super.layoutSubviews()

        updateLayouts()
    }

}

// MARK: - Internal methods -
extension StepsProgressView {

    private func setupStepViews() {
        guard let datasource = datasource else { return }

        highlightColor = datasource.highlightColor()
        regularColor = datasource.regularColor()

        for _ in 0..<datasource.stepsCount() {
            let stepView = buildStepView()

            self.addSubview(stepView)

            stepViews.append(stepView)
        }

        highlightViews()
    }

    private func buildStepView() -> UIView {
        let stepView = UIView(frame: CGRect.zero)

        stepView.layer.cornerRadius = self.frame.height / 2
        stepView.backgroundColor = regularColor

        return stepView
    }

    private func highlightViews() {
        guard let datasource = datasource else { return }

        let highlightIndex = datasource.currentStep()
        let currentColor = datasource.currentStepHightlightColor()

        for i in 0..<highlightIndex {
            let view = stepViews[i]

            if i == highlightIndex - 1 {
                view.backgroundColor = currentColor
            } else {
                view.backgroundColor = highlightColor
            }
        }
    }

    private func updateLayouts() {
        guard let datasource = datasource else { return }

        let stepViewWidth = calculateStepViewWidth()

        for (idx, stepView) in stepViews.enumerated() {

            let xPosition = CGFloat(idx) * stepViewWidth + CGFloat(idx * datasource.stepViewPadding())
            let viewFrame = CGRect(x: xPosition, y: 0, width: stepViewWidth, height: self.frame.height)

            stepView.frame = viewFrame
        }
    }

    private func calculateStepViewWidth() -> CGFloat {
        guard let datasource = datasource else { return 0 }
        let stepsCount = datasource.stepsCount()

        let allViewsWidth = self.frame.width - CGFloat(stepsCount * datasource.stepViewPadding())

        return CGFloat(allViewsWidth / CGFloat(stepsCount))
    }
}

public protocol StepsProgressViewDataSource {

    /// Method returns count of the step views
    func stepsCount() -> Int

    /// Method returns number of the current step
    func currentStep() -> Int

    /// Method returns padding between step views
    func stepViewPadding() -> Int

    /// Method returns color of the highlight step view
    func highlightColor() -> UIColor

    /// Method returns color of the not highlighted views
    func regularColor() -> UIColor

    /// Method returns color of the current step
    func currentStepHightlightColor() -> UIColor
}

public extension StepsProgressViewDataSource {

    func stepsCount() -> Int {
        return stepsAmount
    }

    func stepViewPadding() -> Int {
        return viewsPadding
    }

    func highlightColor() -> UIColor {
        return UIColor.red //colors[.secondaryAccent]
    }

    func regularColor() -> UIColor {
        return UIColor.yellow // colors[.base10]
    }

    func currentStepHightlightColor() -> UIColor {
        return highlightColor()
    }
}
