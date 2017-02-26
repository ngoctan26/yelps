//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/22/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController {
    // View references
    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar!
    var filterButton : UIBarButtonItem!
    
    // Properties
    var businesses = [Business]()
    var currentFilter: [String : Any] = [:]
    var currentPaging = 0
    var isMoreDataLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        filterContentForSearchText(searchText: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Init search bar
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // Init navigation bar item
        filterButton = navigationItem.rightBarButtonItem
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Business.search(with: searchText){(businesses: [Business]?, error: Error?) in
            if let businesses = businesses {
                self.businesses = businesses
            } else {
                print("Load data failed: \(error)")
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.reloadData()
        }
    }

    func filterContent(searchText: String, filters: [String:Any], offset: Int) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        var sortValue: YelpSortMode?
        if let sortMode = filters["sortMode"] {
            sortValue = sortMode as? YelpSortMode
        }
        var categoriesValue: [String]?
        if let catevalues = filters["category"] {
            categoriesValue = catevalues as? [String]
        }
        var isDealsValue: Bool?
        if let dealValue = filters["deals"] {
            isDealsValue = dealValue as? Bool
        }
        var radiusValue: Float?
        if let radius = filters["radius"] {
            radiusValue = Float(radius as! String)
        }
        Business.search(with: searchText, sort: sortValue, categories: categoriesValue, deals: isDealsValue, radius: radiusValue, offset: currentPaging) { (businesses: [Business]?, error: Error?) in
            if let businesses = businesses {
                self.businesses = self.businesses + businesses
                self.currentPaging = self.currentPaging + businesses.count
            } else {
                print("Load data failed: \(error)")
            }
            self.isMoreDataLoading = false
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.reloadData()
        }
    }
    
//    func setView(view: UIView, hidden: Bool) {
//        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
//            view.isHidden = hidden
//        }, completion: { _ in })
//    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desNavigationVC = segue.destination as! UINavigationController
        let desVC = desNavigationVC.topViewController as! FilterViewController
        desVC.filterDelegate = self
    }

}

extension BusinessesViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell") as! BusinessCell
        if businesses.count > 0 {
            cell.business = businesses[indexPath.row]
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                filterContent(searchText: searchBar.text!, filters: currentFilter, offset: currentPaging)
            }
        }
    }
}

extension BusinessesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        navigationItem.rightBarButtonItem = nil
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        navigationItem.rightBarButtonItem = filterButton
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        navigationItem.rightBarButtonItem = filterButton
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationItem.rightBarButtonItem = filterButton
        businesses.removeAll()
        currentPaging = 0
        filterContent(searchText: searchBar.text!, filters: currentFilter, offset: 0)
    }
}

extension BusinessesViewController: FilterViewControllerDelegate {
    func onFilterChanged(filterVC: FilterViewController, filterValue: [String : Any]) {
        // Start load from beginning
        businesses.removeAll()
        currentPaging = 0
        currentFilter = filterValue
        filterContent(searchText: searchBar.text!, filters: filterValue, offset: 0)
    }
}
