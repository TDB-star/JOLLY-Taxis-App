//
//  RideActionView.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 18.02.2022.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: NSObject {
    func uploadTrip(_ view: RideActionView)
}

class RideActionView: UIView {
    
    weak var delegate: RideActionViewDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Adress title"
        label.numberOfLines = 0
        return label
    }()
    
    let adressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "19 Sovetskaya str"
        label.numberOfLines = 0
        return label
    }()
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            adressLabel.text = destination?.adress
        }
    }
    
    let stackView = UIStackView()
    
    lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "X"
        view.addSubview(label)
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    let jollyTaxiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "JOLLYTaxiX"
        return label
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPink
        button.setTitle("Confirm Ride", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: has not been implemented)")
    }

}

extension RideActionView {
    
    func style() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        adressLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        jollyTaxiLabel.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        infoView.layer.cornerRadius = 40
        infoView.clipsToBounds = true
        
        backgroundColor = .white
        addShadow()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        
    }
    func layout() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(adressLabel)
        addSubview(infoView)
        addSubview(jollyTaxiLabel)
        addSubview(dividerView)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            //stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoView.topAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1),
            infoView.heightAnchor.constraint(equalToConstant: 80),
            infoView.widthAnchor.constraint(equalToConstant: 80),
            jollyTaxiLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor),
            jollyTaxiLabel.topAnchor.constraint(equalToSystemSpacingBelow: infoView.bottomAnchor, multiplier: 1),
            dividerView.topAnchor.constraint(equalToSystemSpacingBelow: jollyTaxiLabel.bottomAnchor, multiplier: 2),
            dividerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dividerView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0),
            trailingAnchor.constraint(equalToSystemSpacingAfter: dividerView.trailingAnchor, multiplier: 0),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            actionButton.topAnchor.constraint(equalToSystemSpacingBelow: dividerView.bottomAnchor, multiplier: 2),
            actionButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: actionButton.trailingAnchor, multiplier: 1),
            actionButton.heightAnchor.constraint(equalToConstant: 38)
            
        ])
    }
    
    @objc func actionButtonPressed() {
        delegate?.uploadTrip(self)
    }
}
