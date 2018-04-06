//
//  ViewController.swift
//  PermissionViewController
//
//  Created by Iven Prillwitz on 06.04.18.
//  Copyright © 2018 Iven Prillwitz. All rights reserved.
//

import UIKit

class PermissionViewController: UIViewController {

    private let permissionCellIdentifier = "permissionCellIdentifier"
    private let backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)

    var permissions = [Permission]()

    private lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.register(PermissionCell.self, forCellReuseIdentifier: self.permissionCellIdentifier)
        tableview.dataSource = self
        tableview.delegate = self
        tableview.separatorStyle = .none
        tableview.tableFooterView = UIView()
        tableview.backgroundColor = backgroundColor
        return tableview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = Permission(title: "Notifications",
                                      desription: "Uses notification banner, app icon badges, and sounds to inform you of relevant reminders",
                                      type: .notifications)

        let locationWhenInUse = Permission(title: "Location - When In Use",
                                           desription: "Uses your current location to trigger notifications when you leave or arrive at a location.",
                                           type: .locationWhenInUse)

        let reminders = Permission(title: "Reminders",
                                   desription: "Allows you to view and modify the reminder already stored on your phone.",
                                   type: .reminder)

        let locationAlways = Permission(title: "Location - Always",
                                        desription: "Uses your location passively in the background to remove old location notifications",
                                        type: .locationAlways)

        let camera = Permission(title: "Camera",
                                desription: "Allows you to take photos inside this App",
                                type: .camera)

        let photolibrary = Permission(title: "Photos",
                                      desription: "Allows you to use your Photos in this App",
                                      type: .photolibrary)

        permissions.append(notification)
        permissions.append(reminders)
        permissions.append(locationWhenInUse)
        permissions.append(locationAlways)
        permissions.append(camera)
        permissions.append(photolibrary)

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableView),
                                               name: Notification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }

    @objc
    private func updateTableView() {
        tableView.reloadData()
    }

    private func setupView() {

        title = "Permissions"
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(tableView)
        view.backgroundColor = backgroundColor
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension PermissionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension PermissionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: permissionCellIdentifier, for: indexPath) as? PermissionCell {
            cell.permission = permissions[indexPath.row]
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }

}



