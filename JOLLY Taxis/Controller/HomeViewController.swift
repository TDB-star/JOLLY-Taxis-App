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

private enum ActionButtonConfiguration {
    case showManue
    case dismissActionView
    
    init() {
        self = .showManue
    }
}

private enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeViewControllerDelegate: AnyObject {
    func handleMenuToggle()
}

    class HomeViewController: UIViewController {
 
        private let mapView = MKMapView()
        private let locationManager = LocationHandler.shared.locationManager
        private let locationInputView = LocationInputView()
        private let rideActionView = RideActionView()
        let tableView = UITableView()
        private var actionButtonConfig = ActionButtonConfiguration()
        private var route: MKRoute?
        weak var delegate: HomeViewControllerDelegate?
        
        let actionButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
            button.tintColor = .black
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(actionButtonPressed), for: .primaryActionTriggered)
            return button
        }()
        
        let locationInputActivationView = LocationInputActivationView()
        private final let locationInputViewHeight: CGFloat = 200
        private let rideActionViewHeight: CGFloat = 300
        private var bottomEdgeOffScreen: CGFloat = -300
        private var bottomEdgeOnScreen: CGFloat = 0
        
        private var rideActionViewBottomAnchor: NSLayoutConstraint?
        private var seachResults = [MKPlacemark]()
        
         var user: User? {
            didSet {
                locationInputView.user = user
                if user?.accountType == .passenger {
                    fetchDrivers()
                    configureLocationInputActivationView()
                    observeCurrentTrip()
                } else {
                    observeTrips()
                }
            }
        }
        
        private var trip: Trip? {
            didSet {
                guard let user = user else { return }
                if user.accountType == .driver {
                    guard let trip = trip else { return }
                    let controller = PickupViewController(trip: trip)
                    controller.delegate = self
                    controller.modalPresentationStyle = .fullScreen
                    present(controller, animated: true, completion: nil)
                    
                } else {
                    print("DEBUG: Show ride action view for accepted trip")
                }
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            locationInputActivationView.translatesAutoresizingMaskIntoConstraints = false
            enableLocationServices()
            configureUI()
           
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            guard let trip = trip else { return }
            print("DEBUG: Trip state is \(trip.state)")

        }
        deinit {
            print("DEINIT:HomeController was depricated")
        }
    }
        
// MARK: - Passanger API

extension HomeViewController {
    
 

    private func fetchDrivers() {
        guard let location = locationManager.location else { return }
        PassengerService.shared.fetchDrivers(location: location) { [unowned self] driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                
                mapView.annotations.contains { annotation in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false }
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        zoomFromActiveTrip(withDriverUid: driver.uid)
                        return true
                    }
                    return false
                }
            }
            if !driverIsVisible {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    func startTrip() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { [unowned self] error, ref in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates)
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
            self.generatePolyLine(toDestination: mapItem)
            
            self.mapView.zoomToFit(annotation: self.mapView.annotations)
        }
    }
    
    
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { [unowned self] trip in
            self.trip = trip
            guard let state = trip.state else { return }
            guard let driverUid = trip.driverUid else { return }
            
            switch state {
            case .requested:
                break
            case .accepted:
                shouldPresentLoadingView(false)
                removeAnnotationsAndOverlays()
                zoomFromActiveTrip(withDriverUid: driverUid)
                
                ServiceManager.shared.fetchUserData(uid: driverUid) { [unowned self] driver in
                    self.animateRideActionView(shoudShow: true, config: .tripAccepted, user: driver)
                    UIView.animate(withDuration: 0.3) { [unowned self] in
                        self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOnScreen
                        self.rideActionView.layoutIfNeeded()
                    }
                }
            case .driverArrived:
                rideActionView.config = .driverArrived
            case .inProgress:
                rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                rideActionView.config = .endTrip
            case .completed:
                PassengerService.shared.deleteTrip { [unowned self] error, ref in
                    UIView.animate(withDuration: 0.3) { [unowned self] in
                        self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOffScreen
                        self.rideActionView.layoutIfNeeded()
                    }
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showManue)
                    self.locationInputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Trip completed", message: "We hope you enjoyed your trip")
                }
            }
        }
    }
    
    // MARK: - Driver API
    
    func observeTrips() {
        DriverService.shared.observeTrips { [weak self] trip in
            self?.trip = trip
        }
    }
    
    func observeCancelTrip(trip: Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) { [unowned self] in
            self.removeAnnotationsAndOverlays()
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOffScreen
                self.rideActionView.layoutIfNeeded()
            }
            centerMapOnUserLocation()
            presentAlertController(withTitle: "Oops!", message: "The passenger has canceled this trip. Press OK to continue.")
        }
    }
}
 // MARK: - Cofigure UI

extension HomeViewController {
        func configureUI() {
        configureMapView()
        configureTableView()
        configureMenueButton()
        configureRideActionView()
    }
    
    func configureMenueButton() {
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            actionButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2)
        ])
    }
    
    func configureLocationInputActivationView() {

        view.addSubview(locationInputActivationView)
        
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = 0
        locationInputActivationView.layer.cornerRadius = 8
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut) { [unowned self] in
            self.locationInputActivationView.alpha = 1
        }
        
        NSLayoutConstraint.activate([
            locationInputActivationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            locationInputActivationView.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: locationInputActivationView.trailingAnchor, multiplier: 2),
            locationInputActivationView.heightAnchor.constraint(equalToConstant: 50)
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
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    func dissmissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                self.locationInputActivationView.alpha = 1
            })
        }
    }
    
    func configureRideActionView() {
        
        rideActionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        
        NSLayoutConstraint.activate([
            rideActionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: rideActionView.trailingAnchor, multiplier: 0),
            rideActionView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        rideActionViewBottomAnchor = view.bottomAnchor.constraint(equalTo: rideActionView.bottomAnchor, constant: bottomEdgeOffScreen)
        rideActionViewBottomAnchor?.isActive = true
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
        
        if indexPath.section == 1 {
            cell.placemark = seachResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = seachResults[indexPath.row]
       
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyLine(toDestination: destination)
    
        dismissLocationView { [unowned self] _ in
            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
            
            let annotations = self.mapView.annotations.filter({!$0.isKind(of: DriverAnnotation.self)})
            self.mapView.zoomToFit(annotation: annotations)
            self.animateRideActionView(shoudShow: true, destination: selectedPlacemark, config: .requestRide)
            
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOnScreen
                self.rideActionView.layoutIfNeeded()
            }
        }
    }
}

//MARK: - locationInputActivationViewDelegate

extension HomeViewController: locationInputActivationViewDelegate {
    func presentLocationInputView() {
        
        locationInputActivationView.alpha = 0
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate

extension HomeViewController: LocationInputViewDelegate {
    func executeSeach(query: String) {
        searchBy(naturalLanguageQuery: query) { [weak self] results in
            self?.seachResults = results
            self?.tableView.reloadData()
        }
    }
}

// MARK: - LocationServices/ CLLocationManagerDelegate

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pickup region \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { error, ref in
                self.rideActionView.config = .pickupPassenger
            }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region \(region)")
        }
        
        DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { [unowned self] error, ref in
            self.rideActionView.config = .endTrip
        }
    }
    
    
    private func enableLocationServices() {
        locationManager.delegate = self
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
    // function updates user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        guard user.accountType == .driver else { return }
        guard let location = userLocation.location else { return }
        DriverService.shared.updateDriverLocation(location: location)
    }
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            view.image = UIImage(named: "taxi-s")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .blue
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}
// MARK: - Helpers

extension HomeViewController {
    
    private func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showManue:
            let image = UIImage(systemName: "line.3.horizontal")
            actionButton.setImage(image, for: .normal)
            actionButtonConfig = .showManue
        case .dismissActionView:
            actionButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func animateRideActionView(shoudShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        
        if shoudShow {
            
            guard let config = config else { return }
           
            if let destination = destination {
                rideActionView.destination = destination
            }
            if let user = user {
                
                rideActionView.user = user
            }
            rideActionView.config = config
        }
    }
    
    private func setCustomRegion(withType type: AnnotationType, coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager.startMonitoring(for: region)
    }
    
    
    //MARK: - Selectors
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showManue:
            delegate?.handleMenuToggle()
        case.dismissActionView:
            removeAnnotationsAndOverlays()
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOffScreen
                self.rideActionView.layoutIfNeeded()
            }
            
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: .showManue)
                
            }
        }
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
    
    
    func generatePolyLine(toDestination destination: MKMapItem) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { [weak self] response, error in
            guard let response = response else { return }
            self?.route = response.routes[0]
            
            guard let polyline = self?.route?.polyline else { return }
            self?.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        
         mapView.annotations.forEach { annotation in
             if let anno = annotation as? MKPointAnnotation {
                 mapView.removeAnnotation(anno)
             }
         }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations:  { [unowned self] in
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
            }, completion: completion)
        }
    
    func zoomFromActiveTrip (withDriverUid uid: String) {
        
        var annotations = [MKAnnotation]()
        
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == uid {
                    annotations.append(anno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        
        mapView.zoomToFit(annotation: annotations)
    }
}

// MARK: - RideActionViewDelegate

extension HomeViewController: RideActionViewDelegate {

    

    
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
    shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { error, ref in
            if let error = error {
                print("DEBUG: Failed to upload trip with error \(error.localizedDescription)")
                return
            }
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOffScreen
                self.rideActionView.layoutIfNeeded()
            }
        }
    }
    func cancelTrip() {
        PassengerService.shared.deleteTrip { [unowned self] error, ref in
            if let error = error {
                print("DEBUG: Error deliting trip \(error.localizedDescription)")
                return
            }
            self.centerMapOnUserLocation()
            
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOffScreen
                self.rideActionView.layoutIfNeeded()
            }
            self.removeAnnotationsAndOverlays()
            
            let image = UIImage(systemName: "line.3.horizontal")
            self.actionButton.setImage(image, for: .normal)
            self.actionButtonConfig = .showManue
            self.locationInputActivationView.alpha = 1
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .completed) { [unowned self] error, ref in
            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOffScreen
                self.rideActionView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - PickupViewControllerDelegate

extension HomeViewController: PickupViewControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        self.mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyLine(toDestination: mapItem)
        mapView.zoomToFit(annotation: mapView.annotations)
        
        observeCancelTrip(trip: trip)
        
        dismiss(animated: true) {
            ServiceManager.shared.fetchUserData(uid: trip.passengerUid) { [unowned self] passenger in
                self.animateRideActionView(shoudShow: true, config: .tripAccepted, user: passenger)
                UIView.animate(withDuration: 0.3) {
                    self.rideActionViewBottomAnchor?.constant = self.bottomEdgeOnScreen
                    self.rideActionView.layoutIfNeeded()
                }
            }
        }
    }
}


