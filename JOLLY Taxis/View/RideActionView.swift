//
//  RideActionView.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 18.02.2022.
//

import UIKit

class RideActionView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Adress title"
        return label
    }()
    
    let adressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "19 Sovetskaya str"
        return label
    }()
    
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
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "JOLLY Taxi X"
        return label
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
        
        infoView.layer.cornerRadius = 40
        infoView.clipsToBounds = true
        
        backgroundColor = .white
        addShadow()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        
    }
    func layout() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(adressLabel)
        addSubview(infoView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoView.topAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 2),
            infoView.heightAnchor.constraint(equalToConstant: 80),
            infoView.widthAnchor.constraint(equalToConstant: 80),
            
        ])
    }
}
