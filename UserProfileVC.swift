//
//  UserProfileVC.swift
//  Networking
//
//  Created by Max on 21.01.2023.
//  Copyright © 2023 Max. All rights reserved.
//

import UIKit
import FacebookLogin
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class UserProfileVC: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    lazy var logoutButton: UIButton = {
        
        let button = UIButton()
        button.frame = CGRect(x: 32,
                                   y: view.frame.height - 172,
                                   width: view.frame.width - 64,
                                   height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        
        return button
        
    }()

    @IBOutlet weak var userNamelabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        userNamelabel.isHidden = true
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchingUserData()
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        
        view.addSubview(logoutButton)
    }

}



extension UserProfileVC {
    
    private func openLoginViewController() {
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
            
        } catch let error {
            print("Failed to sign out with error: ", error.localizedDescription)
        }

    }
    

    private func fetchingUserData() {
        
        if Auth.auth().currentUser != nil {
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
                
                guard let userData = snapshot.value as? [String: Any] else { return }
                self.currentUser = CurrentUser(uid: uid, data: userData)
                
                self.activityIndicator.stopAnimating()
                self.userNamelabel.isHidden = false
                
                self.userNamelabel.text = self.getProviderData()
                
            } withCancel: { error in
                print(error)
            }

        }
    }
    
    @objc private func signOut() {
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did logout with facebook")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("User did logout with google")
                    openLoginViewController()
                default:
                    print("User is signed in with \(userInfo.providerID)")
                }
            }
        }
    }
    
    private func getProviderData() -> String {
        
        var greetings = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                default:
                    break
                }
            }
            greetings = "\(currentUser?.name ?? "NoName") Logged in with \(provider!)"
        }
        
        return greetings
    }
}
