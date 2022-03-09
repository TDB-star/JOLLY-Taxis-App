//
//  ContainerViewController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 01.03.2022.
//

import UIKit
import Firebase


class ContainerViewController: UIViewController {
    
    private let homeViewController = HomeViewController()
    private var menueController: SideMenuViewController!
    private var isExpanded = false
   
    
    
    private let blackView = UIView()
    
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeViewController.user = user
            configureSideMenuController(withUser: user)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    
   override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func configure() {
        fetchUserData()
        configureHomeViewController()
    }
    // add chiled view controller
    
    func configureHomeViewController() {
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        homeViewController.delegate = self
        
    }
    
    func confugureBlackView() {
       
        blackView.frame = view.bounds
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
      func configureSideMenuController(withUser user: User) {
          menueController = SideMenuViewController(user: user)
          addChild(menueController)
          menueController.didMove(toParent: self)
          view.insertSubview(menueController.view, at: 0)
          menueController.delegate = self
          confugureBlackView()
        
      }
    
    // MARK: - Selectors
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(ShoudExpand: isExpanded)
    }
    
    // MARK: - API
    
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        ServiceManager.shared.fetchUserData(uid: currentUid) { [weak self] user in
            self?.user = user
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async { [unowned self] in
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("DEBUG: Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    private func checkIfUserIsLoggedIn() {
        let currentUserId = Auth.auth().currentUser?.uid
        if currentUserId == nil  {
            print("DEBUG: User not logged in")
            DispatchQueue.main.async { [unowned self] in
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configure()
        }
    }
    
    func animateMenu(ShoudExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        let xOrigine = view.frame.width - 80
        
        if ShoudExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [unowned self] in
                self.homeViewController.view.frame.origin.x = xOrigine
                self.blackView.frame = CGRect(x: xOrigine, y: 0, width: 80, height: view.frame.height)
                self.blackView.alpha = 1
                
               
            }, completion: nil)
            
        } else {
            blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [unowned self] in
                self.homeViewController.view.frame.origin.x = 0
            }, completion: completion)
        }
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}


extension ContainerViewController {
//
//    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [unowned self] in
//        self.homeViewController.view.frame.origin.x = xOrigine
//    } completion: {  [unowned self] _ in
//        self.blackView.alpha = 1
//        self.blackView.frame = CGRect(x: xOrigine, y: 0, width: 80, height: height)
//    }
 
}

// MARK: - HomeControllerDelegate

extension ContainerViewController: HomeViewControllerDelegate {
    
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(ShoudExpand: isExpanded)
    }
}

// MARK: - SettingsViewControllerDelegate

extension ContainerViewController: SettingsViewControllerDelegate {
    func updateUser(_ controller: SettingsViewController) {
        user = controller.user
    }
}

extension ContainerViewController: SideMenuViewControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(ShoudExpand: isExpanded) { [unowned self] _ in
            switch option {
            case .yourTips:
                break
            case .settings:
                guard let user = user else { return }
                let controller = SettingsViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(nav, animated: true, completion: nil)
                
                
            case .logout:
              let alert = UIAlertController(title: nil,
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self]_ in
                    self?.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

