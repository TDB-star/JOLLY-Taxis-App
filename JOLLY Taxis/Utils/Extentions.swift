//
//  Extentions.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 13.02.2022.
//

import UIKit
import MapKit

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

extension MKPlacemark {
    var adress: String? {
        get {
            guard let subThroughfare = subThoroughfare,
                    let thoroughfare = thoroughfare,
                    let locality = locality,
                    let adminArea = administrativeArea
            else { return nil }
            return "\(subThroughfare) \(thoroughfare), \(locality), \(adminArea)"
        }
        
    }
}

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
}

extension MKMapView {
    func zoomToFit(annotation: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach({
            annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        })
        let insets = UIEdgeInsets(top: 200, left: 200, bottom: 250, right: 200)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    func addAnnotationAndSelect(forCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true)
       
    }
}

extension UIViewController {
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.preferredFont(forTextStyle: .title2)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.8
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.topAnchor.constraint(equalToSystemSpacingBelow: indicator.bottomAnchor, multiplier: 4)
            ])
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func presentAlertController(withTitle: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}
