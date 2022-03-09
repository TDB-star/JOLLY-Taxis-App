//
//  SettingsViewController.swift
//  JOLLY Taxis
//
//  Created by Tatiana Dmitrieva on 08/03/2022.
//

import UIKit


private let reuseIdentifire = "LocationCell"

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
            
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}

class SettingsViewController: UIViewController {
    
    private let user: User
    
    
    private let tableView = UITableView()
    private let locationManager = LocationHandler.shared.locationManager
 
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        confgureNavigationBar(barTitle: "Settings")
        
    }
}

extension SettingsViewController {
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .white
        tableView.rowHeight = 60
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: reuseIdentifire)
        
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = infoHeader
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
  
    func confgureNavigationBar(barTitle: String) {
            navigationController?.navigationBar.prefersLargeTitles = true
            title = barTitle
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.systemPink

            let attrs = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .bold)
            ]

            navBarAppearance.largeTitleTextAttributes = attrs as [NSAttributedString.Key : Any]
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: self, action: #selector(handleDismissal))
        
        
    }
    
    @objc func handleDismissal() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource/Delegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewForHeader = UIView()
        viewForHeader.backgroundColor = .systemPink
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        viewForHeader.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        title.centerYAnchor.constraint(equalTo: viewForHeader.centerYAnchor).isActive = true
        title.leadingAnchor.constraint(equalToSystemSpacingAfter: viewForHeader.leadingAnchor, multiplier: 2).isActive = true
        
        return viewForHeader

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire, for: indexPath) as! LocationTableViewCell
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.type = type
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager.location else { return }
        let controller = AddLocationViewController(type: type, location: location)
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
}
