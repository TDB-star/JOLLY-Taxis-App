//
//  Extentions.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 13.02.2022.
//

import UIKit

let passwordToggleButton = UIButton(type: .custom)

extension UITextField {
    
    func enablePasswordToggle() {
        passwordToggleButton.setImage(UIImage(systemName: "lock"), for: .normal)
        passwordToggleButton.setImage(UIImage(systemName: "lock.open"), for: .selected)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        let buttobContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        buttobContainerView.addSubview(passwordToggleButton)
        rightView = passwordToggleButton
        rightViewMode = .always
    }
    
    @objc func togglePasswordView(_ sender: Any) {
        isSecureTextEntry.toggle()
        passwordToggleButton.isSelected.toggle()
        
    }
    
    func setRightView(image: String) {
        let iconView = UIImageView(frame: CGRect(x: -10, y: 0, width: 20, height: 20)) // set your Own size
        iconView.image = UIImage(systemName: image)
        iconView.tintColor = .lightGray
        iconView.contentMode = .scaleAspectFit
       
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        iconContainerView.addSubview(iconView)
        rightViewMode = .always
        rightView = iconContainerView
    }
    
    func setLeftView(image: String) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 25, height: 25)) // set your Own size
        iconView.image = UIImage(systemName: image)
        iconView.tintColor = .lightGray
        iconView.contentMode = .scaleAspectFit
       
          
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        iconContainerView.addSubview(iconView)
        leftViewMode = .always
        leftView = iconContainerView
    }
}

extension UIColor {
    static func rgbColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    static let appColor = UIColor.rgbColor(red: 17, green: 154, blue: 237)
}
