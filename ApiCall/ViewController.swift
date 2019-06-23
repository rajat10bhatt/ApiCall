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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 163
        tableView.rowHeight = UITableView.automaticDimension
        viewModel.getProducts()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductTableViewCell.self)) as! ProductTableViewCell
        cell.setData(data: self.viewModel.products[indexPath.row])
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
