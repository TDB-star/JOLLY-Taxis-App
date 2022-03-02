//
//  MenuHeader.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 01.03.2022.
//

import UIKit

class MenuHeader: UIView {
    
    private let profileImageView: UIImageView = {
     let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .left
        label.text = "Tatiana"
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "test@gmail.com"
        return label
    }()
    
    private let stackView = UIStackView()
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = .systemPink
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func style() {
       profileImageView.translatesAutoresizingMaskIntoConstraints = false
       profileImageView.layer.cornerRadius = 64 / 2
       
       fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
       emailLabel.translatesAutoresizingMaskIntoConstraints = false
       
       stackView.translatesAutoresizingMaskIntoConstraints = false
       stackView.distribution = .fillEqually
       stackView.axis = .vertical
       stackView.spacing = 2
     
   }
    
    func layout() {
        addSubview(profileImageView)
        addSubview(stackView)
        stackView.addArrangedSubview(fullNameLabel)
        stackView.addArrangedSubview(emailLabel)

       
       NSLayoutConstraint.activate([
        profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: safeAreaLayoutGuide.topAnchor, multiplier: 1),
        profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
        profileImageView.heightAnchor.constraint(equalToConstant: 64),
        profileImageView.widthAnchor.constraint(equalToConstant: 64),
        stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
        stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: profileImageView.trailingAnchor, multiplier: 2)
       ])
    }
    
}
