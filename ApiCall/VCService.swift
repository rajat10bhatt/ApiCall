//
//  VCService.swift
//  ApiCall
//
//  Created by Rajat Bhatt on 21/06/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation
import Alamofire

class VCService {
    func callApi(completion: @escaping (_ product: [[String: String]], _ error: String?)->()) {
        Alamofire.request("https://s3.ap-south-1.amazonaws.com/ss-local-files/products.json").responseJSON { response in
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    if let products = json?["products"] as? [String:Any] {
                        let productsArray = products.map({
                            return $0.value as! [String: String]
                        })
                        completion(productsArray, nil)
                    }
                } catch {
                    completion([], error.localizedDescription)
                    print("Something went wrong")
                }
            } else {
                completion([], "Data not available")
                print("Something went wrong")
            }
        }
    }
}
