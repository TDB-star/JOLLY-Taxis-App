//
//  DriverAnnotation.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 15.02.2022.
//

import MapKit

// driver pin

class DriverAnnotation: NSObject, MKAnnotation {
   dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    // функция анимирует смену координат водителя
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.3) {
            self.coordinate = coordinate
        }
    }
}
