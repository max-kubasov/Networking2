//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by Max on 12.01.2023.
//  Copyright © 2023 Max. All rights reserved.
//

import Foundation
import Alamofire
import UIKit


class AlamofireNetworkRequest {
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    static func sendRequest(url: String, complition: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).response { response in
            print(response)
        }
        
        AF.request(url).validate().responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                
                var courses = [Course]()
                courses = Course.getArray(from: value)!
                complition(courses)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func downloadImage(url: String, complition: @escaping (_ image: UIImage) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseData { responseData in
            
            switch responseData.result {
                
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                complition(image)
                
            case .failure(let error):
                print(error )
                
            }
        }
    }
    
    static func responseData(url: String) {
        
        AF.request(url).responseData { responseData in
            
            switch responseData.result {
                
            case .success(let data):
                guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func responseString(url: String) {
        
        AF.request(url).responseString { responseString in
            
            switch responseString.result {
                
            case .success(let string):
                print(string)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func response(url: String) {
        
        AF.request(url).response { response in
            
            guard let data = response.data,
                  let string = String(data: data, encoding: .utf8)
            else { return }
            
            print(string)
        }
    }
    
    static func downloadImageWithProgress(url: String, complition: @escaping (_ image: UIImage) -> ()) {

        guard let url = URL(string: url) else { return }

        AF.request(url).validate().downloadProgress { progress in

            print("totalUnitCount: \(progress.totalUnitCount)")
            print("completedUnitCount: \(progress.completedUnitCount)")
            print("fractionCompleted: \(progress.fractionCompleted)")
            print("localizedDescription: \(progress.localizedDescription!)")
            print("-----------------------------------------")
            
            self.onProgress?(progress.fractionCompleted )
            self.completed?(progress.localizedDescription)
            
            
        }.response { response in
            
            guard let data = response.data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                complition(image)
            }
        }
    }
    

    
}
