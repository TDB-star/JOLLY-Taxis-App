//
//  UserInfoHeader.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 08/03/2022.
//

import UIKit

class UserInfoHeader: UIView {
    
    private let user: User
    
    private let profileImageView: UIImageView = {
     let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.text = user.fullname
        label.numberOfLines = 0
        return label
    }()
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        label.textAlignment = .left
        label.text = user.email
        return label
    }()
    
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        style()
        layout()
    }
   
    private let stackView = UIStackView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func style() {
        
        backgroundColor = .white
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
        profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: safeAreaLayoutGuide.topAnchor, multiplier: 1.5),
        profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 3.5),
        profileImageView.heightAnchor.constraint(equalToConstant: 64),
        profileImageView.widthAnchor.constraint(equalToConstant: 64),
        stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
        stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: profileImageView.trailingAnchor, multiplier: 1)
       ])
    }
}
