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

class UserProfileVC: UIViewController {
    
    lazy var fbLoginButton: UIButton = {
        
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32,
                                   y: view.frame.height - 172,
                                   width: view.frame.width - 64,
                                   height: 50)
        loginButton.delegate = self
        return loginButton
        
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
        
        view.addSubview(fbLoginButton)
    }

}

// MARK: Facebook SDK

extension UserProfileVC: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error!)
            return
        }
        
        print("Successfully logged in with Facebook...")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
        openLoginViewController()
        
    }
    
    private func openLoginViewController() {
        
        do {
            try Auth.auth().signOut()
            
            print("The user is logged in")
            
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
                let currentUser = CurrentUser(uid: uid, data: userData)
                
                self.activityIndicator.stopAnimating()
                self.userNamelabel.isHidden = false
                
                self.userNamelabel.text = "\(currentUser?.name ?? "NoName") logged in with Facebook"
                
                
            } withCancel: { error in
                print(error)
            }

        }
    }
}
