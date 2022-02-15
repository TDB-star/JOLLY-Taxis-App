//
//  LocationInputActivationView.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 14.02.2022.
//

import UIKit

protocol locationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    
    let stackView = UIStackView()
    
    private let indicatorView = UIView()
    private let pointView = UIView()
    private let plachelderLabel = UILabel()
    
    weak var delegate: locationInputActivationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder: has not been implemented)")
    }
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: 200, height: 200)
//    }
}

extension LocationInputActivationView {
    
    func style() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.45
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.backgroundColor = .darkGray
        
        plachelderLabel.translatesAutoresizingMaskIntoConstraints = false
        plachelderLabel.text = "Where to go?"
        plachelderLabel.font = UIFont.systemFont(ofSize: 16)
        plachelderLabel.textColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    func layout() {
        
        addSubview(indicatorView)
        addSubview(plachelderLabel)
        
        NSLayoutConstraint.activate([
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            indicatorView.widthAnchor.constraint(equalToConstant: 4),
            plachelderLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            plachelderLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: indicatorView.trailingAnchor, multiplier: 2),
            trailingAnchor.constraint(equalToSystemSpacingAfter: plachelderLabel.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: plachelderLabel.bottomAnchor, multiplier: 1)
        ])
    }
}

extension LocationInputActivationView {
    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }
}
