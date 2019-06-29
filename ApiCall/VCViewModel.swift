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
    private (set) var searchedProducts: [[String: String]] = []
    private let and = "and"
    private let or = "or"
    private let below = "below"
    private let above = "above"
    private let title = "title"
    private let popularity = "popularity"
    private let price = "price"
    fileprivate enum SearchType: Int {
        case or
        case and
        case above
        case below
        case andOr
        case aboveBelowAnd
    }
    
    init(vMProtocol: ViewModelProtocol?) {
        self.viewModelProtocol = vMProtocol
        self.products = []
    }
    
    func getProducts() {
        service.callApi { [unowned self] (products, error) in
            guard error == nil else {
                self.viewModelProtocol?.gotError(error: error)
                return
            }
            self.products = products.sorted(by: {
                if let popularity1 = Int($0[self.popularity] ?? "0"), let popularity2 = Int($1[self.popularity] ?? "0") {
                    return popularity1 > popularity2
                }
                return false
            })
        }
    }
    
    func filterProducts(searchText: String) {
        let searchTextArray = searchText.split(separator: " ")
        if let searchType = getSearchType(searchTextArray: searchTextArray) {
            switch searchType {
            case .aboveBelowAnd:
                let amount = getSearchAmount(searchTextArray: searchTextArray)
                if amount.count == 2 {
                    if amount[0] > amount[1] {
                        filterAboveAndBelow(from: amount[1], to: amount[0])
                    } else {
                        filterAboveAndBelow(from: amount[0], to: amount[1])
                    }
                }
            case .andOr:
                filterAndOrInitial(searchTextArray: searchTextArray)
            case .above:
                let amount = getSearchAmount(searchTextArray: searchTextArray)
                filterAboveAndBelow(from: amount.first ?? 0)
            case .below:
                let amount = getSearchAmount(searchTextArray: searchTextArray)
                filterAboveAndBelow(to: amount.first ?? 0)
            case .and:
                self.searchedProducts = filterAnd(searchTextArray: searchTextArray, products: products)
            case .or:
                self.searchedProducts = filterOr(searchTextArray: searchTextArray, products: products)
            }
        } else {
            filterOnBasisOfTitle(searchTextArray: searchTextArray)
        }
    }
    
    private func filterAndOrInitial(searchTextArray: [String.SubSequence]) {
        guard let firstElement = searchTextArray.first, let lastElement = searchTextArray.last, firstElement != and, firstElement != or, lastElement != and, lastElement != or else {
            return
        }
        var isFirstOperator = true
        for (index, element) in searchTextArray.enumerated() {
            if isFirstOperator {
                if element.lowercased() == and {
                    isFirstOperator = false
                    self.searchedProducts = filterAnd(searchTextArray: [searchTextArray[index-1], searchTextArray[index+1]], products: products)
                } else if element.lowercased() == or {
                    isFirstOperator = false
                    self.searchedProducts = filterOr(searchTextArray: [searchTextArray[index-1], searchTextArray[index+1]], products: products)
                }
            } else {
                if (element.lowercased() == and) || (element.lowercased() == or) {
                    filterAndOr(element: searchTextArray[index+1], stringOperator: element)
                }
            }
        }
    }
    
    func filterAndOr(element: String.SubSequence, stringOperator: String.SubSequence) {
        if stringOperator.lowercased() == and {
            self.searchedProducts = filterAnd(searchTextArray: [element], products: self.searchedProducts)
        } else if stringOperator.lowercased() == or {
            let filteredElements = filterOr(searchTextArray: [element], products: self.products)
            self.searchedProducts.append(contentsOf: filteredElements)
            self.searchedProducts.sort {
                if let popularity1 = Int($0[self.popularity] ?? "0"), let popularity2 = Int($1[self.popularity] ?? "0") {
                    return popularity1 > popularity2
                }
                return false
            }
        }
    }
    
    private func filterOr(searchTextArray: [String.SubSequence], products: [[String : String]]) -> [[String : String]] {
        return products.filter { (product) -> Bool in
            if let title = product[title] {
                let titleArray = title.split(separator: " ")
                var isElementPresent = false
                titleArray.forEach({ (element) in
                    searchTextArray.forEach({ (searchElement) in
                        if searchElement.lowercased() == element.lowercased() {
                            isElementPresent = true
                        }
                    })
                })
                if isElementPresent {
                    return true
                }
            }
            return false
        }
    }
    
    private func filterAnd(searchTextArray: [String.SubSequence], products: [[String : String]]) -> [[String : String]] {
        var newSearchTextArray: [String.SubSequence] = searchTextArray
        var andIndex: Int?
        for (index, element) in searchTextArray.enumerated() {
            if element.lowercased() == and {
                andIndex = index
                break
            }
        }
        if let index = andIndex {
            newSearchTextArray.remove(at: index)
        }
        return products.filter { (product) -> Bool in
            if let title = product[title] {
                let titleArray = title.split(separator: " ")
                var count = 0
                titleArray.forEach({ (element) in
                    newSearchTextArray.forEach({ (searchElement) in
                        if searchElement.lowercased() == element.lowercased() {
                            count += 1
                        }
                    })
                })
                if count == newSearchTextArray.count {
                    return true
                }
            }
            return false
        }
    }
    
    private func getSearchAmount(searchTextArray: [String.SubSequence]) -> [Int] {
        var searchAmount: [Int] = []
        for element in searchTextArray {
            if let amount = Int(element) {
                searchAmount.append(amount)
            }
        }
        return searchAmount
    }
    
    private func filterAboveAndBelow(from belowAmount: Int = Int.min, to aboveAmount: Int = Int.max) {
        self.searchedProducts = products.filter({ (product) -> Bool in
            if let price = Int(product[price] ?? "0") {
                if (price > belowAmount) && (price < aboveAmount) {
                    return true
                }
            }
            return false
        })
    }
    
    private func getSearchType(searchTextArray: [String.SubSequence]) -> SearchType? {
        var isOr = false
        var isAnd = false
        var isBelow = false
        var isAbove = false
        searchTextArray.forEach { (element) in
            if element.lowercased() == or {
                isOr = true
            }
            if element.lowercased() == and {
                isAnd = true
            }
            if element.lowercased() == below {
                isBelow = true
            }
            if element.lowercased() == above {
                isAbove = true
            }
        }
        if isOr && isAnd {
            return SearchType.andOr
        } else if (isAbove && isBelow && isAnd) || (isAbove && isBelow) {
            return SearchType.aboveBelowAnd
        } else if isOr {
            return SearchType.or
        } else if isAnd {
            return SearchType.and
        } else if isBelow {
            return SearchType.below
        } else if isAbove {
            return SearchType.above
        }
        return nil
    }
    
    private func filterOnBasisOfTitle(searchTextArray: [String.SubSequence]) {
        self.searchedProducts = filterAnd(searchTextArray: searchTextArray, products: products)
        if self.searchedProducts.count == 0 {
            self.searchedProducts = filterOr(searchTextArray: searchTextArray, products: products)
        }
    }
}
