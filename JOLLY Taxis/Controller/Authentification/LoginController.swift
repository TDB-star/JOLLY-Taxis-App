//
//  LoginController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 13.02.2022.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    let titleLabel = UILabel()
    let loginView = LoginView()
    let logInButton = UIButton(type: .system)
    let signUpLabel = UILabel()
    let signUpButton = UIButton(type: .system)
    let stackView = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
}
extension LoginViewController {
    
    func style() {
    
        loginView.translatesAutoresizingMaskIntoConstraints = false
       
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "JOLLY Taxi"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
       
        
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        logInButton.backgroundColor = .systemPink
        logInButton.setTitleColor(.white, for: .normal)
        logInButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        logInButton.layer.cornerRadius = 8
        logInButton.layer.cornerCurve = .continuous
        
        logInButton.setTitle("Log In", for: [])
        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .primaryActionTriggered)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpLabel.text = "Don't have an account?"
        signUpLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.backgroundColor = .clear
        signUpButton.setTitleColor(.systemPink, for: .normal)
        signUpButton.setTitle("Sign Up", for: [])
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .primaryActionTriggered)
    }
    
    func layout() {
        view.addSubview(titleLabel)
        view.addSubview(loginView)
        view.addSubview(logInButton)
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(signUpLabel)
        stackView.addArrangedSubview(signUpButton)
        
      
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
            loginView.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: loginView.trailingAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            logInButton.topAnchor.constraint(equalToSystemSpacingBelow: loginView.bottomAnchor, multiplier: 3),
            logInButton.leadingAnchor.constraint(equalTo: loginView.leadingAnchor),
            logInButton.trailingAnchor.constraint(equalTo: loginView.trailingAnchor),
            logInButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension LoginViewController {

    @objc func logInButtonTapped(_ sender: UIButton) {
        guard let userName = loginView.usernameTextField.text else { return }
        guard let password = loginView.passwordTextField.text else { return }
        signInUserWith(userName: userName, password: password)
        }
    
    
    @objc func signUpButtonTapped(_ sender: UIButton) {
        let controller = SignUpViewController()
        navigationController?.pushViewController(controller, animated: false)
    }
    
    private func login() {
        
    }
    
    private func signInUserWith(userName: String, password: String) {
        Auth.auth().signIn(withEmail: userName, password: password) { [unowned self] result, error in
            if let error = error {
                print("DEBUG: Failed to log user in with error: \(error.localizedDescription)")
                return
            }
            
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeViewController else { return }
            controller.configure()
            self.dismiss(animated: true, completion: nil)
            print("DEBUG: Siccesfully logged user in")
        }
    }
}

extension LoginViewController {
    
    private func textFieldsHaveText() -> Bool {
        return (loginView.usernameTextField.text != "" && loginView.passwordTextField.text != "")
    }
}
