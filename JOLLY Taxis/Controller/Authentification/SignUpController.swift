//
//  SignUpController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 13.02.2022.
//

import UIKit
import Firebase
import GeoFire

class SignUpViewController: UIViewController {
    
    private var location = LocationHandler.shared.locationManager.location
    
    let signUpView = SignUpView()
    let segmentedControl = UISegmentedControl(items: ["Rider", "Driver"])
    let signUpButton = UIButton(type: .system)
    let stackView = UIStackView()
    let signInLabel = UILabel()
    let logInButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        let sharedLocationManager = LocationHandler.shared.locationManager
        print("DEBUG: Location is \(String(describing: sharedLocationManager.location))")
    }
}

extension SignUpViewController {
    
    func style() {
        signUpView.translatesAutoresizingMaskIntoConstraints = false
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.systemGroupedBackground
        segmentedControl.backgroundColor = UIColor.systemGroupedBackground
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.backgroundColor = .systemPink
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signUpButton.layer.cornerRadius = 8
        signUpButton.layer.cornerCurve = .continuous

        signUpButton.setTitle("Sign Up", for: [])
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .primaryActionTriggered)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        signInLabel.text = "Alredy have an account?"
        signInLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        logInButton.backgroundColor = .clear
        logInButton.setTitleColor(.systemPink, for: .normal)
        logInButton.setTitle("Log In", for: [])
        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .primaryActionTriggered)
    }
    
    func layout() {
        
        view.addSubview(signUpView)
        view.addSubview(segmentedControl)
        view.addSubview(signUpButton)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(signInLabel)
        stackView.addArrangedSubview(logInButton)
       
        NSLayoutConstraint.activate([
            signUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            signUpView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: signUpView.trailingAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: signUpView.bottomAnchor, multiplier: 2),
            segmentedControl.leadingAnchor.constraint(equalTo: signUpView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: signUpView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalToSystemSpacingBelow: segmentedControl.bottomAnchor, multiplier: 2),
            signUpButton.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension SignUpViewController {
    
    @objc func segmentedValueChanged(_sender: UISegmentedControl) {
        print("Value changed")
    }
    
    @objc func signUpButtonTapped(_ sender: UIButton) {
        guard let email = signUpView.emailTextField.text else { return }
        guard let password = signUpView.passwordTextField.text else { return }
        guard let fullname = signUpView.fullNameTextField.text else { return }
        let accountTypeIndex = segmentedControl.selectedSegmentIndex
        
        createUserWith(email: email, password: password, fullname: fullname, accountType: accountTypeIndex)
        print("\(email) \(password)" )
    }
    
    @objc func logInButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (signUpView.emailTextField.text != "" && signUpView.passwordTextField.text != "")
    }
}
extension SignUpViewController {
    private func createUserWith(email: String, password: String, fullname: String, accountType: Int) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("DEBUG: Failed to register user with error: \(error.localizedDescription) ")
                return
            }
            guard let uid = result?.user.uid else { return }
            
            let values = ["email": email,
                          "fullname": fullname,
                          "password": password,
                          "accountType": accountType] as [String: Any ]
            
            if accountType == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self?.location else { return }
                geofire.setLocation(location, forKey: uid) { [weak self] error in
                    self?.uploadUserAndShowHomeController(uid: uid, values: values)
                }
            }
            self?.uploadUserAndShowHomeController(uid: uid, values: values)
        }
    }
}

extension SignUpViewController {
    // MARK: - Helpers
    
    func uploadUserAndShowHomeController(uid: String, values: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(values) { [unowned self] error, ref in
              guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeViewController else { return }
              controller.configure()
              self.dismiss(animated: true, completion: nil)
          }
    }
}


