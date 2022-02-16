//
//  HomeViewController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 14.02.2022.
//

import UIKit
import Firebase
import MapKit

private let reuseCellIdentifire = "locationInputCell"
private let annotationIdentifire = "DriverAnnotation"

    class HomeViewController: UIViewController {
 
        private let mapView = MKMapView()
        private let locationManager = LocationHandler.shared.locationManager
        private let locationInputView = LocationInputView()
        let tableView = UITableView()
        
        let locationInputActivationView = LocationInputActivationView()
        private final let locationInputViewHeight: CGFloat = 200
        private var seachResults = [MKPlacemark]()
        
        private var user: User? {
            didSet {
                locationInputView.user = user
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            locationInputActivationView.translatesAutoresizingMaskIntoConstraints = false
            
            checkIfUserIsLoggedIn()
            enableLocationServices()
           // signOut()
        }
    }
        
// MARK: - API

extension HomeViewController {
    
    private func checkIfUserIsLoggedIn() {
        let currentUserId = Auth.auth().currentUser?.uid
        if currentUserId == nil  {
            print("DEBUG: User not logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configure()
        }
    }
    
    private func fetchDrivers() {
        guard let location = locationManager.location else { return }
        ServiceManager.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                
                self.mapView.annotations.contains { annotation in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false }
                    if driverAnno.uid == driver.uid {
                        // update position here запрос позиции из базы данных
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("DEBUG: Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        ServiceManager.shared.fetchUserData(uid: currentUid) { [weak self] user in
            self?.user = user
        }
    }
}
 // MARK: - Cofigure UI

extension HomeViewController {
    
    func configureUI() {
        configureMapView()
        configureLocationInputActivationView()
        configureTableView()
    }
    
    func configureLocationInputActivationView() {
        view.addSubview(locationInputActivationView)
        
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = 0
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut) {
            self.locationInputActivationView.alpha = 1
        }
        
        NSLayoutConstraint.activate([
            locationInputActivationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            locationInputActivationView.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: locationInputActivationView.trailingAnchor, multiplier: 2)
        ])
    }
   
    func configureMapView() {
        view.addSubview(mapView)
        
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.delegate = self
        locationInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationInputView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            locationInputView.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 0),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: locationInputView.trailingAnchor, multiplier: 0),
            locationInputView.heightAnchor.constraint(equalToConstant: locationInputViewHeight)
        ])
        
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: reuseCellIdentifire)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : seachResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifire, for: indexPath) as! LocationTableViewCell
        return cell
    }
}


extension HomeViewController: locationInputActivationViewDelegate {
    func presentLocationInputView() {
        
        locationInputActivationView.alpha = 0
        configureLocationInputView()
    }
}

extension HomeViewController: LocationInputViewDelegate {
    func executeSeach(query: String) {
        searchBy(naturalLanguageQuery: query) { [weak self] results in
            self?.seachResults = results
            self?.tableView.reloadData()
        }
            }

    func dissmissLocationInputView() {
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
            }
        }
    }
}

// MARK: - Location Manager

extension HomeViewController {
    
    private func enableLocationServices() {
        
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
        case .notDetermined:
            print("Not determind")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("Auth always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("Auth when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - MKMapViewDelegate

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            view.image = UIImage(named: "taxi-s")
            return view
        }
        return nil
    }
}
// MARK: - Helpers

extension HomeViewController {
    func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
}

//MARK: - Map Helper functions

extension HomeViewController {
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else { return }
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            completion(results)
        }
    }
}



