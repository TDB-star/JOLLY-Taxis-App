//
//  LocationInputView.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 14.02.2022.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dissmissLocationInputView()
    func executeSeach(query: String)
}

class LocationInputView: UIView {
    
    weak var delegate: LocationInputViewDelegate?
    
    var user: User? {
        didSet {
            titleLabel.text = user?.fullname
        }
    }
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.configuration = .plain()
        button.addTarget(self, action: #selector(handleBackTapped), for: .primaryActionTriggered)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "William Parker"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
      let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextField = UITextField()
    private lazy var destinationLocationTextField =  UITextField()
      
    let textFieldsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: has not been implemented)")
    }
    
    func style() {
        backgroundColor = .white
        addShadow()
        translatesAutoresizingMaskIntoConstraints = false
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStackView.axis = .vertical
        textFieldsStackView.distribution = .fillEqually
        textFieldsStackView.spacing = 8
        
        startingLocationTextField.translatesAutoresizingMaskIntoConstraints = false
        startingLocationTextField.borderStyle = .roundedRect
        startingLocationTextField.backgroundColor = .systemGroupedBackground
        startingLocationTextField.placeholder = "Current location"
        startingLocationTextField.isEnabled = false
        startingLocationTextField.delegate = self
        
        destinationLocationTextField.translatesAutoresizingMaskIntoConstraints = false
        destinationLocationTextField.borderStyle = .roundedRect
        destinationLocationTextField.backgroundColor = .systemGroupedBackground
        destinationLocationTextField.placeholder = "Enter a destination"
        destinationLocationTextField.returnKeyType = .search
        destinationLocationTextField.delegate = self
        
        startLocationIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        startLocationIndicatorView.clipsToBounds = true
        
        linkingView.translatesAutoresizingMaskIntoConstraints = false
        destinationIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func layout() {
        addSubview(backButton)
        addSubview(titleLabel)
        
        textFieldsStackView.addArrangedSubview(startingLocationTextField)
        textFieldsStackView.addArrangedSubview(destinationLocationTextField)
        
        addSubview(textFieldsStackView)
        addSubview(startLocationIndicatorView)
        addSubview(destinationIndicatorView)
        addSubview(linkingView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 5),
            backButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1)
        ])
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            textFieldsStackView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            textFieldsStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 5),
            trailingAnchor.constraint(equalToSystemSpacingAfter: textFieldsStackView.trailingAnchor, multiplier: 2)
        ])
        NSLayoutConstraint.activate([
            startLocationIndicatorView.heightAnchor.constraint(equalToConstant: 6),
            startLocationIndicatorView.widthAnchor.constraint(equalToConstant: 6),
            startLocationIndicatorView.centerYAnchor.constraint(equalTo: startingLocationTextField.centerYAnchor),
            startLocationIndicatorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2)
        ])
        NSLayoutConstraint.activate([
            destinationIndicatorView.heightAnchor.constraint(equalToConstant: 4),
            destinationIndicatorView.widthAnchor.constraint(equalToConstant: 4),
            destinationIndicatorView.centerYAnchor.constraint(equalTo: destinationLocationTextField.centerYAnchor),
            destinationIndicatorView.centerXAnchor.constraint(equalTo: startLocationIndicatorView.centerXAnchor)
            //destinationIndicatorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2)
        ])
        NSLayoutConstraint.activate([
            linkingView.widthAnchor.constraint(equalToConstant: 1),
            linkingView.centerXAnchor.constraint(equalTo: startLocationIndicatorView.centerXAnchor),
            linkingView.topAnchor.constraint(equalToSystemSpacingBelow: startLocationIndicatorView.bottomAnchor, multiplier: 0.5),
            linkingView.bottomAnchor.constraint(equalTo: destinationIndicatorView.topAnchor, constant: -4)
        ])
    }
}

extension LocationInputView {
    @objc func handleBackTapped() {
        delegate?.dissmissLocationInputView()
    }
}

// MARK: - UITextField Delegate

extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return  false}
        delegate?.executeSeach(query: query)
        return true
    }
}

