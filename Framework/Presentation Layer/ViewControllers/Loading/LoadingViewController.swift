//
//  LoadingViewController.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

final class LoadingViewController: UIViewController, Quitable {
    private enum Constants {
        static let defaultProgress = 0.15
    }
    
    var quitHandler: (() -> Void)?
    
    private let headerView = HeaderView()
    private let progressView = CircleProgressView()
    private let colors: ColorsImpl
    
    init(colors: ColorsImpl = ColorsImpl()) {
        self.colors = colors
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        progressView.configureUI()
    }
    
    func didClickQuit(_ sender: Any) {
        quitHandler?()
    }
    
    private func configureUI() {
        view.backgroundColor = colors[.background]
        
        setUpHeaderView()
        setUpProgressView()
    }
    
    private func setUpHeaderView() {
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        headerView.setStyle(.quit(target: self))
    }
    
    private func setUpProgressView() {
        view.addSubview(progressView)
        progressView.animateProgress.color = colors[.primaryAccent]
             
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        progressView.defaultProgress = Constants.defaultProgress
    }
}
