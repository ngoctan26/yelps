//
//  FilterViewController.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/25/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    @objc optional func onFilterChanged(filterVC: FilterViewController, filterValue: [String:Any])
}

class FilterViewController: UIViewController {
    // View references
    @IBOutlet weak var tableView: UITableView!
    
    // View actions
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: UIBarButtonItem) {			
        // Get current filter
        var saveFilter: [String:Any] = [:]
        var filter: [String:Any] = [:]
        filter["category"] = selectedCategories
        filter["radius"] = selectedDistance
        filter["deals"] = isDealEnable
        filter["sortMode"] = selectedSortMode
        
        // TODO: Save filter into NSUser
        saveFilter["radius"] = selectedDistance
        saveFilter["deals"] = isDealEnable
        saveFilter["sortMode"] = selectedSortMode.rawValue
        AppConfigUtil.saveSetting(configurations: saveFilter)
        
        // Update main page with filter
        filterDelegate.onFilterChanged!(filterVC: self, filterValue: filter) 
        dismiss(animated: true, completion: nil)
    }
    
    // Properties
    var filterDelegate: FilterViewControllerDelegate!
    var selectedCategories = [String]()
    var categoryState = [Int:Bool]()
    var distanceStates: [Bool] = [false, false, false, false]
    var distances: [String] = ["0.3", "1", "5", "20"]
    var selectedDistance: String = "Auto"
    var sortModes: [YelpSortMode] = [YelpSortMode.bestMatched, YelpSortMode.distance, YelpSortMode.highestRated]
    var sortModeStates: [Bool] = [true, false, false]
    var selectedSortMode: YelpSortMode = YelpSortMode.bestMatched
    var isDealEnable: Bool = false
    var sortHeaderSelected = false
    var distanceHeaderSelected = false
    var isShowCategoryMoreSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        loadSavedSetting()
        for (index, value) in distanceStates.enumerated() {
            if value {
                selectedDistance = distances[index]
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadSavedSetting() {
        if let savedRadius = AppConfigUtil.loadSetting(key: "radius", defaultValue: "Auto") as? String {
            for (index, value) in distances.enumerated() {
                if value == savedRadius {
                    distanceStates[index] = true
                    selectedDistance = value
                } else {
                    distanceStates[index] = false
                }
            }
        }
        if let isSavedDeal = AppConfigUtil.loadSetting(key: "deals", defaultValue: false) as? Bool {
            isDealEnable = isSavedDeal
        }
        if let sortSavedMode = AppConfigUtil.loadSetting(key: "sortMode", defaultValue: YelpSortMode.bestMatched.rawValue) as? Int {
            for (index, value) in sortModes.enumerated() {
                if sortSavedMode == value.rawValue {
                    sortModeStates[index] =  true
                    selectedSortMode = value
                } else {
                    sortModeStates[index] =  false
                }
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if sortHeaderSelected {
                return 4
            } else {
                return 1
            }
        case 2:
            if distanceHeaderSelected {
                return 5
            } else {
                return 1
            }
        case 3:
            if isShowCategoryMoreSelected {
                // all category and show less cell
                return FilterConstanst.CATEGORIES.count + 1
            } else {
                // 3 category and show more cell
                return 4
            }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Deal"
        case 1:
            return "Sort"
        case 2:
            return "Distance"
        case 3:
            return "Category"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let dealCell = tableView.dequeueReusableCell(withIdentifier: "dealCell", for: indexPath) as! DealFilterCell
            dealCell.dealSwBtn.isOn = isDealEnable
            dealCell.dealDelegate = self
            return dealCell
        case 1:
            if indexPath.row == 0 {
                let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
                headerCell.headerNameLabel.text = YelpService.shared().getYelpModeAsString(mode: selectedSortMode)
                return headerCell
            }
            let sortCell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath) as! SortFilterCell
            sortCell.selectedState = sortModeStates[indexPath.row - 1]
            let mode = sortModes[indexPath.row - 1]
            sortCell.sortNameLabel.text = YelpService._shared?.getYelpModeAsString(mode: mode)
            return sortCell
        case 2:
            if indexPath.row == 0 {
                let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
                headerCell.headerNameLabel.text = selectedDistance + " mil"
                return headerCell
            }
            let distanceCell = tableView.dequeueReusableCell(withIdentifier: "distanceCell", for: indexPath) as! DistanceFilterCell
            distanceCell.selectedState = distanceStates[indexPath.row - 1]
            distanceCell.distanceLabel.text = distances[indexPath.row - 1] + " mil"
            return distanceCell
        case 3:
            if isShowCategoryMoreSelected {
                if indexPath.row == FilterConstanst.CATEGORIES.count {
                    let showLessCell = tableView.dequeueReusableCell(withIdentifier: "cateShowCell", for: indexPath) as! ShowCategoryCell
                    showLessCell.showMoreLessLabel.text = "Show less"
                    return showLessCell
                }
            }
            if !isShowCategoryMoreSelected && indexPath.row == 3 {
                // Only show when show more is not selected
                let showMoreCell = tableView.dequeueReusableCell(withIdentifier: "cateShowCell", for: indexPath) as! ShowCategoryCell
                showMoreCell.showMoreLessLabel.text = "Show more"
                return showMoreCell
            }
            let cateCell = tableView.dequeueReusableCell(withIdentifier: "cateCell", for: indexPath) as! CategoryFilterCell
            cateCell.category = FilterConstanst.CATEGORIES[indexPath.row]
            if categoryState[indexPath.row] == nil {
                categoryState[indexPath.row] = false
            }
            cateCell.stateOfCate = categoryState[indexPath.row]
            cateCell.cateDelegate = self
            return cateCell
        default:
            return UITableViewCell()
        }
        
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                sortHeaderSelected = !sortHeaderSelected
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            } else {
                selectedSortMode = sortModes[indexPath.row - 1]
                for (index, _) in sortModeStates.enumerated() {
                    sortModeStates[index] = index == (indexPath.row - 1) ? true : false
                }
                let indexPath0 = IndexPath(item: 0, section: 1)
                let indexPath1 = IndexPath(item: 1, section: 1)
                let indexPath2 = IndexPath(item: 2, section: 1)
                let indexPath3 = IndexPath(item: 3, section: 1)
                tableView.reloadRows(at: [indexPath0, indexPath1, indexPath2, indexPath3], with: .automatic)
            }
            return
        case 2:
            if indexPath.row == 0 {
                distanceHeaderSelected = !distanceHeaderSelected
                tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            } else {
                selectedDistance = distances[indexPath.row - 1]
                for (index, _) in distanceStates.enumerated() {
                    distanceStates[index] = index == indexPath.row - 1 ? true : false
                }
                let indexPath0 = IndexPath(item: 0, section: 2)
                let indexPath1 = IndexPath(item: 1, section: 2)
                let indexPath2 = IndexPath(item: 2, section: 2)
                let indexPath3 = IndexPath(item: 3, section: 2)
                let indexPath4 = IndexPath(item: 4, section: 2)
                tableView.reloadRows(at: [indexPath0, indexPath1, indexPath2, indexPath3, indexPath4], with: .automatic)
            }
            return
        case 3:
            if (tableView.cellForRow(at: indexPath) as? ShowCategoryCell) != nil {
                isShowCategoryMoreSelected = !isShowCategoryMoreSelected
                tableView.reloadSections([3], with: .automatic)
            }
            return
        default:
            return
        }
    }
    
}

extension FilterViewController: CategoryFilterCellDelegate, DealFilterCellDelegate {
    func onCategorySwitchChanged(cell: CategoryFilterCell, cateCode: String, isEnable: Bool) {
        categoryState[(tableView.indexPath(for: cell)?.row)!] = isEnable
        if isEnable {
            selectedCategories.append(cateCode)
        } else {
            selectedCategories.removeObject(object: cateCode)
        }
    }
    
    func onDealFilterChanged(cell: DealFilterCell, isEnable: Bool) {
        isDealEnable = isEnable
    }
}

extension Array where Element: Equatable
{
    mutating func removeObject(object: Element) {
        
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
