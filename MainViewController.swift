//
//  MainViewController.swift
//  Networking
//
//  Created by Max on 12.01.2023.
//  Copyright © 2023 Max. All rights reserved.
//

import UIKit
import UserNotifications
import FacebookLogin
import FirebaseAuth

enum Actions: String, CaseIterable {
    
    case downloadImage = "Download Image"
    case get = "GET"
    case post = "POST"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download File"
    case ourCoursesAlamofire = "Our Courses (Alamofire)"
    case responseData = "Response Data"
    case responseString = "Response String"
    case response = "Response"
    case downloadlargeImage = "Download Large Image"
    case postAlamofire = "POST with Alamofire"
    case putRequest = "PUT Request with Alamofire"
    case uploadImageAlamofire = "Upload Image (Alamofire)"
}

private let reuseIdentifier = "Cell"
private let url = "https://jsonplaceholder.typicode.com/posts"
private let uploadImage = "https://api.imgur.com/3/image"
private let swiftbookApi = "https://swiftbook.ru//wp-content/uploads/api/api_courses"

class MainViewController: UICollectionViewController {
    
    let actions = Actions.allCases
    private var alert: UIAlertController!
    private let dataProvider = DataProvider()
    private var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotification()
        
        dataProvider.fileLocation = { location in
            
            print("Download finished \(location.absoluteString)")
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: false)
            self.postNotofication()
        }
        
        checkLoggenIn()
    }
    
    private func showAlert() {
        
        alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        
        let height = NSLayoutConstraint(item: alert.view!,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0,
                                        constant: 170)
        
        alert.view.addConstraint(height)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive ) {_ in
            self.dataProvider.stopDownload()
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true) {
            
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height / 2)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            self.alert.view.addSubview(activityIndicator)
            
            let progressView = UIProgressView(frame: CGRect(x: 0, y: self.alert.view.frame.height - 44, width: self.alert.view.frame.width, height: 2))
            progressView.tintColor = .blue
            //progressView.progress = 0.5
            
            self.dataProvider.onProgress = { progress in
                
                progressView.progress = Float(progress)
                self.alert.message = String(Int(progress * 100)) + "%"
            }
            
            
            self.alert.view.addSubview(progressView)
             
        }
    }


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return actions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        cell.label.text = actions[indexPath.row].rawValue
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = actions[indexPath.row]
        
        switch action {
        case .downloadImage:
            performSegue(withIdentifier: "ShowImage", sender: self)
        case .get:
            NetworkManager.getRequest(url: url)
        case .post:
            NetworkManager.postRequest(url: url)
        case .ourCourses:
            performSegue(withIdentifier: "OurCourses", sender: self)
        case .uploadImage:
            NetworkManager.uploadImage(url: uploadImage)
        case .downloadFile:
            showAlert()
            dataProvider.startDownload()
        case .ourCoursesAlamofire:
            performSegue(withIdentifier: "OurCoursesWithAlamofire", sender: self)
        case .responseData:
            performSegue(withIdentifier: "ResponseData", sender: self)
            AlamofireNetworkRequest.responseData(url: swiftbookApi)
        case .responseString:
            AlamofireNetworkRequest.responseString(url: swiftbookApi)
        case .response:
            AlamofireNetworkRequest.response(url: swiftbookApi)
        case .downloadlargeImage:
            performSegue(withIdentifier: "LargeImage", sender: self)
        case .postAlamofire:
            performSegue(withIdentifier: "PostRequest", sender: self)
        case .putRequest:
            performSegue(withIdentifier: "PutRequest", sender: self)
        case .uploadImageAlamofire:
            AlamofireNetworkRequest.uploadImage(url: uploadImage)
            
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let coorsesVC = segue.destination as? CoursesViewController
        let imageVC = segue.destination as? ImageViewController
        
        switch segue.identifier {
        case "OurCourses":
            coorsesVC?.fetchData()
        case "OurCoursesWithAlamofire":
            coorsesVC?.fetchDataWithAlamofire()
        case "ShowImage":
            imageVC?.fetchImage()
        case "ResponseData":
            imageVC?.fetchDataWithAlamofire()
        case "LargeImage":
            imageVC?.downloadImageWithProgress()
        case "PostRequest":
            coorsesVC?.postRequest()
        case "PutRequest":
            coorsesVC?.putRequest()
        default:
            break
        }
    }

}

extension MainViewController {
    
    private func registerForNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            
        }
    }
    
    private func postNotofication() {
        
        let content = UNMutableNotificationContent()
        content.title = "Download compleat!"
        content.body = "You background transfer has completed. File path: \(filePath!)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}


// MARK: Facebook SDK

extension MainViewController {
    
    private func checkLoggenIn() {
        
        if Auth.auth().currentUser == nil {
            
            print("The user is logged in")
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        }
    }
}
