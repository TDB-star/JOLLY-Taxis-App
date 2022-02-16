//
//  SignUpView.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 13.02.2022.
//

import UIKit


class SignUpView: UIView {
    
    let stackView = UIStackView()
    let fullNameTextField = UITextField()
    let passwordTextField = UITextField()
    let emailTextField = UITextField()
    let emailDividerView = UIView()
    let fullNamedividerView = UIView()
    let bottomdividerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder: has not been implemented)")
    }
}

extension SignUpView {
    
    func style() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.borderStyle = .none
        emailTextField.placeholder = "Email"
        emailTextField.delegate = self
        emailTextField.setRightView(image: "envelope")
        
        fullNameTextField.translatesAutoresizingMaskIntoConstraints = false
        fullNameTextField.borderStyle = .none
        fullNameTextField.placeholder = "Full Name"
        fullNameTextField.delegate = self
        fullNameTextField.setRightView(image: "person")
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.borderStyle = .none
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.setRightView(image: "lock")
        passwordTextField.autocorrectionType = .no
        
        emailDividerView.translatesAutoresizingMaskIntoConstraints = false
        emailDividerView.backgroundColor = .secondarySystemFill
        layer.cornerRadius = 5
        clipsToBounds = true
        
        fullNamedividerView.translatesAutoresizingMaskIntoConstraints = false
        fullNamedividerView.backgroundColor = .secondarySystemFill
        layer.cornerRadius = 5
        clipsToBounds = true
        
        bottomdividerView.translatesAutoresizingMaskIntoConstraints = false
        bottomdividerView.backgroundColor = .secondarySystemFill
        layer.cornerRadius = 5
        clipsToBounds = true
        
    }
    func layout() {
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(emailDividerView)
        stackView.addArrangedSubview(fullNameTextField)
        stackView.addArrangedSubview(fullNamedividerView)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(bottomdividerView)
      
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1)
        ])
        emailDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        fullNamedividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomdividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

extension SignUpView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.endEditing(true)
        fullNameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        

    }
}
