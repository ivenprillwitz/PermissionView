//
//  PermissionCell.swift
//  PermissionViewController
//
//  Created by Iven Prillwitz on 06.04.18.
//  Copyright © 2018 Iven Prillwitz. All rights reserved.
//

import UIKit
import AVKit
import Photos
import UserNotifications

class PermissionCell: UITableViewCell {

    var delegate: PermissionViewController?
    var permissionEnabled = false

    var permission: Permission? {
        didSet {
            if let permission = permission {
                titleLabel.text = permission.title
                descriptionLabel.text = permission.desription
                setupSwitch()
            }
        }
    }

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()

    private lazy var permissionSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(checkPermission), for: .valueChanged)
        return switcher
    }()


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear

        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(permissionSwitch)

        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        containerView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true

        permissionSwitch.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14).isActive = true
        permissionSwitch.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
        permissionSwitch.heightAnchor.constraint(equalToConstant: permissionSwitch.intrinsicContentSize.height).isActive = true
        permissionSwitch.widthAnchor.constraint(equalToConstant: permissionSwitch.intrinsicContentSize.width).isActive = true

        descriptionLabel.topAnchor.constraint(equalTo: permissionSwitch.topAnchor, constant: 6).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: permissionSwitch.leftAnchor, constant: -6).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
    }

    private func setupSwitch() {

        guard let permissionType = permission?.type else {
            return
        }

        var state = false

        switch permissionType {
        case .camera:
            state = isCameraAccessGranted()
            break
        case .locationAlways:
            break
        case .locationWhenInUse:
            break
        case .notifications:
            state = isNotificationAccessGranted()
            break
        case .calender:
            break
        case .reminder:
            break
        case .photolibrary:
            state = isPhotoLibraryAccessGranted()
            break
        }

        permissionSwitch.setOn(state, animated: true)
    }

    @objc
    private func checkPermission() {

        guard let permissionType = permission?.type else {
            return
        }

        if permissionEnabled {
            showSettingsAlert(type: .disabled)
        } else {
            switch permissionType {
            case .camera:
                getCameraAccess()
                break
            case .locationAlways:
                break
            case .locationWhenInUse:
                break
            case .notifications:
                getNotificationsAccess()
                break
            case .calender:
                break
            case .reminder:
                break
            case .photolibrary:
                getPhotoLibraryAccess()
                break
            }
        }
    }

    private func getCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.permissionEnabled = true
            } else {
                DispatchQueue.main.async {
                    self.showSettingsAlert(type: .update)
                    self.permissionSwitch.isOn = false
                    self.permissionEnabled = false
                }
            }
        }
    }

    private func isCameraAccessGranted() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            permissionEnabled = true
            return true
        } else {
            permissionEnabled = false
            return false
        }
    }

    private func getPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.permissionEnabled = true
            } else {
                DispatchQueue.main.async {
                    self.showSettingsAlert(type: .update)
                    self.permissionSwitch.isOn = false
                    self.permissionEnabled = false
                }
            }
        }
    }

    private func isPhotoLibraryAccessGranted() -> Bool {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            permissionEnabled = true
            return true
        } else {
            permissionEnabled = false
            return false
        }
    }

    enum AlertType {
        case update
        case disabled
    }

    private func getNotificationsAccess() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (access, error) in
            if let error = error {
                print("Failed to request auth:", error)
                return
            }
            if access {
                UIApplication.shared.registerForRemoteNotifications()
                self.permissionEnabled = true
            } else {
                DispatchQueue.main.async {
                    self.showSettingsAlert(type: .update)
                    self.permissionSwitch.isOn = false
                    self.permissionEnabled = false
                }
            }
        }
    }

    private func isNotificationAccessGranted() -> Bool {
        return true
    }

    private func showSettingsAlert(type: AlertType){

        guard let permissionTitle = permission?.title else {
            return
        }

        let title = type == .disabled ? "Turn Off In Settings": "Permission Denied"
        let message = type == .disabled ?
            "To disable the " + permissionTitle + " permission, please visit the Settings App" :
            "The " + permissionTitle + " permission is currently denied. Please update the permission in the Settings App"

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        alert.addAction(settingsAction)

        permissionSwitch.setOn(true, animated: true)

        delegate?.present(alert, animated: true, completion: nil)
    }
}
