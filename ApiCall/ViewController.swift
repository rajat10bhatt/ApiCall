//
//  ViewController.swift
//  ApiCall
//
//  Created by Rajat Bhatt on 21/06/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel = VCViewModel(vMProtocol: self)
    var isSearchEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 163
        tableView.rowHeight = UITableView.automaticDimension
        viewModel.getProducts()
    }
    
    func addTapGesture() {
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchEnabled {
            return self.viewModel.searchedProducts.count
        }
        return self.viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductTableViewCell.self)) as! ProductTableViewCell
        if isSearchEnabled {
            cell.setData(data: self.viewModel.searchedProducts[indexPath.row])
        } else {
            cell.setData(data: self.viewModel.products[indexPath.row])
        }
        return cell
    }
}

extension ViewController: ViewModelProtocol {
    func gotProducts() {
        self.tableView.reloadData()
    }
    
    func gotError(error: String?) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let searchText = searchBar.text {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  {
                return false
            }
        }
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isSearchEnabled = false
            tableView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            isSearchEnabled = true
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.viewModel.filterProducts(searchText: searchText)
            }
            tableView.reloadData()
        }
    }
}
