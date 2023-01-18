//
//  ImageViewController.swift
//  Networking
//
//  Created by Max on 12.01.2023.
//  Copyright © 2023 Max. All rights reserved.
//

import UIKit
import Alamofire

class ImageViewController: UIViewController {
    
    private let url = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        self.activityIndicator.startAnimating()
        
    }
    
    func fetchImage() {
        
        NetworkManager.downloadImage(url: url) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }

    }
    
    func fetchDataWithAlamofire() {
        
        AF.request(url).responseData { responseData in
            
            switch responseData.result {
                
            case .success(let data):
                
                guard let image = UIImage(data: data) else { return }
                
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
                
            case .failure(let error):
                print(error )
                
            }
        }
    }
    
}
