//
//  ContainerViewController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 01.03.2022.
//

import UIKit


class ContainerViewController: UIViewController {
    
    private let homeViewController = HomeViewController()
    private let menueController = SideMenuViewController()
    private var isExpanded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHomeViewController()
        configureSideMenuController()
    }
    // add chiled view controller
    func configureHomeViewController() {
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        
        homeViewController.delegate = self
    }
    
    
      func configureSideMenuController() {
          addChild(menueController)
          menueController.didMove(toParent: self)
          view.insertSubview(menueController.view, at: 0)
      }
}

extension ContainerViewController {
 
    func animateMenu(ShoudExpand: Bool) {
        if ShoudExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [unowned self] in
                self.homeViewController.view.frame.origin.x = self.view.frame.width - 80
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [unowned self] in
                self.homeViewController.view.frame.origin.x = 0
            }, completion: nil)
        }
    }
}

extension ContainerViewController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(ShoudExpand: isExpanded)
    }
}

