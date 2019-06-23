//
//  VCViewModel.swift
//  ApiCall
//
//  Created by Rajat Bhatt on 21/06/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation

protocol ViewModelProtocol: class {
    func gotProducts()
    func gotError(error: String?)
}

class VCViewModel {
    weak var viewModelProtocol: ViewModelProtocol?
    lazy var service = VCService()
    private (set) var products: [[String: String]] {
        didSet {
            self.viewModelProtocol?.gotProducts()
        }
    }
    
    init(vMProtocol: ViewModelProtocol?) {
        self.viewModelProtocol = vMProtocol
        self.products = []
    }
    
    func getProducts() {
        service.callApi { [weak self] (products, error) in
            guard error == nil else {
                self?.viewModelProtocol?.gotError(error: error)
                return
            }
            self?.products = products
        }
    }
}
