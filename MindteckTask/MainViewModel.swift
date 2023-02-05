//
//  MainViewModel.swift
//  MindteckTask
//
//  Created by Rajuabe on 05/02/23.
//

import Foundation
protocol MainViewModelDelegate: AnyObject {
    func reloadTableData()
}
class MainViewModel {
    weak var delegate:MainViewModelDelegate?
    var isSearchEnabled: Bool = false
    var imageUrls = [
        "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
        "https://thumbs.dreamstime.com/b/beautiful-rain-forest-ang-ka-nature-trail-doi-inthanon-national-park-thailand-36703721.jpg",
        "https://1.bp.blogspot.com/-kK7Fxm7U9o0/YN0bSIwSLvI/AAAAAAAACFk/aF4EI7XU_ashruTzTIpifBfNzb4thUivACLcBGAsYHQ/s1280/222.jpg"
    ]
    
    var list: [String] {
        var items:[String]  = []
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .spellOut
        for i in 0...51 {
            if let num = numFormatter.string(from: NSNumber(integerLiteral: i)) {
                items.append(num)
            }
        }
       return items
    }
    
    var searchList:[String] = [] {
        didSet {
            self.delegate?.reloadTableData()
        }
    }
    // MARK: - Tableview data source
    func tableViewDataSourceCount() -> Int {
        return self.isSearchEnabled ? self.searchList.count : self.list.count
    }
    func getTableViewItem(at index:Int) -> String {
        return self.isSearchEnabled ? self.searchList[index] : self.list[index]
    }
    // MARK: - Search
     func doSearch(txt: String) {
        self.isSearchEnabled = true
        print("Search txt -\(txt)")
        if txt.isEmpty {
            self.searchList = self.list
            return
        }
        self.searchList = self.list.filter { item in
            return item.contains(txt)
        }
    }
    // MARK: - API call for image urls
    func requestCustom(url: String, success:@escaping((_ data: Data)->Void), failure:@escaping((_ error: String) -> Void)) {

        guard let requestUrl = URL(string: url) else {
            failure("Invalid url string")
            return
        }
        let session = URLSession.shared

        let dataTask = session.dataTask(with: requestUrl) { (data, response, error) in
        
            if data != nil {
                success(data!)
            }
            else if let error = error {
                failure("Error occured - \(error.localizedDescription)")
            } else {
                failure("Error")
            }
        }
        dataTask.resume()
    }
}

