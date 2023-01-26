//
//  LoginViewController.swift
//  Networking
//
//  Created by Max on 21.01.2023.
//  Copyright © 2023 Max. All rights reserved.
//

import UIKit
import FacebookLogin
import FirebaseAuth
import FirebaseDatabase
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
    lazy var fbLoginButton: UIButton = {
        
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
        
    }()
    
    lazy var customFBLoginButton: UIButton = {
        
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        return loginButton
    }()
    
    lazy var googleSignInButton: GIDSignInButton = {
        
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.addTarget(self, action: #selector(signInWithGooglePressed), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var customGoogleLoginButtom: UIButton = {
       
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.backgroundColor = .white
        loginButton.setTitle("Log in with Google", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.gray, for: .normal)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(signInWithGooglePressed), for: .touchUpInside)
        
        return loginButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: .blue, bottomColor: .lightGray)
        
        setupViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        
        view.addSubview(fbLoginButton)
        view.addSubview(customFBLoginButton)
        view.addSubview(googleSignInButton)
        view.addSubview(customGoogleLoginButtom)
    }
}

// MARK: Facebook SDK

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error!)
            return
        }
        
        guard AccessToken.isCurrentAccessTokenActive else { return }
        
        signIntoFirebase()
        
        print("Successfully logged in with Facebook...")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func handleCustomFBLogin() {
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.signIntoFirebase()
            }
        }
    }
    
    private func signIntoFirebase() {
        
        let accessToken = AccessToken.current
        
        guard let  accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { user, error in
            
            if let error = error {
                print("Something went wrong with our facebook user: ", error)
                return
            }
            
            print("Successfully logged in with our FB user")
            self.fetchFacebookFields()
        }
    }
    
    private func fetchFacebookFields() {
        
        guard AccessToken.current != nil else { return }

        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
        request.start() { connection, result, error in
            
            if let error = error {
                print(error)
                return
            }
            
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print(self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
            }
        }
    }
    
    private func saveIntoFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        
        let values = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(values) { error, _ in
            
            if let error = error {
                print(error)
                return
            }
            
            print("Successfuly saved user into Firebase database ")
            self.openMainViewController()
        }
    }
}

// MARK: Google SDK

extension LoginViewController {
    
    @objc private func signInWithGooglePressed() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
     
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] user, error in

          if let error = error {
            print(error)
            return
          }
            
            print("Successfully logged into Google")
            
            if let userName = user?.user.profile?.name, let userEmail = user?.user.profile?.email {
                let userData = ["name": userName, "email": userEmail]
                userProfile = UserProfile(data: userData)
            }
            
             

          guard
            let authentication = user?.user.accessToken.tokenString,
            let idToken = user?.user.idToken?.tokenString
          else {
            return
          }
            
            
            let googleCredential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authentication)
            
            Auth.auth().signIn(with: googleCredential) { user, error in
                
                if let error = error {
                    print("Something went wrong with our Google user: ", error)
                    return
                }
                
                print("Success logget into Firebase with Google")
                self.saveIntoFirebase()
            }
            
        }
        
    }
}
