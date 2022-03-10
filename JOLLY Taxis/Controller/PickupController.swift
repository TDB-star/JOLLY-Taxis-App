//
//  PickupController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 22.02.2022.
//

import UIKit
import MapKit

protocol PickupViewControllerDelegate: NSObject {
    func didAcceptTrip(_ trip: Trip)
}

class PickupViewController: UIViewController {
    
    // MARK: - Prpperties
    
    weak var delegate: PickupViewControllerDelegate?
   
    let pickuplabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .darkGray
        return label
    }()
    
    private let mapView = MKMapView()
    let trip: Trip
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(handleDissmisal), for: .touchUpInside)
        return button
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPink
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Accept Trip", for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        cp.addSubview(mapView)
    
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        mapView.centerXAnchor.constraint(equalTo: cp.centerXAnchor),
        mapView.centerYAnchor.constraint(equalTo: cp.centerYAnchor),
        mapView.heightAnchor.constraint(equalToConstant: 268),
        mapView.widthAnchor.constraint(equalToConstant: 268)
    ])
        mapView.layer.cornerRadius = 268 / 2
        

        return cp
        
    }()
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        layout()
        configureMapView()
        perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
   override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Selectors
    
    @objc func handleDissmisal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip() {
        DriverService.shared.acceptTrip(trip: trip) { [unowned self] error, ref in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 10, value: 0) {
            DriverService.shared.updateTripState(trip: self.trip, state: .denied) { error, ref in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - API
    deinit {
        print("DEINIT:PickupController was depricated")
    }
    
}
extension PickupViewController {
    // MARK: - Helper Functions
    
    func configureUI() {
       
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
       // mapView.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        pickuplabel.translatesAutoresizingMaskIntoConstraints = false
        acceptTripButton.translatesAutoresizingMaskIntoConstraints = false
    
        
//        mapView.layer.cornerRadius = 270 / 2
//        mapView.layer.cornerCurve = .circular
        
        acceptTripButton.layer.cornerRadius = 8
    }
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
    }
    
    func layout() {
        
        
        view.addSubview(acceptTripButton)
        view.addSubview(cancelButton)
        //view.addSubview(mapView)
        view.addSubview(pickuplabel)
        view.addSubview(circularProgressView)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            cancelButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            circularProgressView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -130),
            circularProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressView.heightAnchor.constraint(equalToConstant: 360),
            circularProgressView.widthAnchor.constraint(equalToConstant: 360)
          
//            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -130),
//            mapView.heightAnchor.constraint(equalToConstant: 270),
//            mapView.widthAnchor.constraint(equalToConstant: 270)
        ])
        
        NSLayoutConstraint.activate([
            pickuplabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickuplabel.topAnchor.constraint(equalToSystemSpacingBelow: circularProgressView.bottomAnchor, multiplier: 2),
            acceptTripButton.topAnchor.constraint(equalToSystemSpacingBelow: pickuplabel.bottomAnchor, multiplier: 2),
            acceptTripButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: acceptTripButton.trailingAnchor, multiplier: 2),
            acceptTripButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
}
