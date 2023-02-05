//
//  MainViewController.swift
//  MindteckTask
//
//  Created by Rajuabe on 05/02/23.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imgsPagger: UIPageControl!
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var searchY:CGFloat = 0
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        //self.configurePageControl()
        self.imagesScrollView.delegate = self
        self.imagesScrollView.isPagingEnabled = true
        self.searchY = self.searchContainerView.frame.origin.y
        self.configView()
        self.tableViewHeight.constant = 44*50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: - Config View
    private func configView() {
        self.imgsPagger.numberOfPages = self.viewModel.imageUrls.count
        
        for index in 0..<self.viewModel.imageUrls.count {
            let imgPath = self.viewModel.imageUrls[index]
            self.viewModel.requestCustom(url: imgPath) {[weak self] data in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    let bannerView = UIImageView()
                    bannerView.frame = self.topContainerView.frame
                    bannerView.frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
                    bannerView.isUserInteractionEnabled = true
                    bannerView.image = UIImage(data:data)
                    self.imagesScrollView.addSubview(bannerView)
                }
            } failure: { error in
                print("It is failed")
            }
        }
        self.imagesScrollView.contentSize = CGSize(width:self.imagesScrollView.frame.size.width * CGFloat(viewModel.imageUrls.count),height: self.imagesScrollView.frame.size.height)
        self.imgsPagger.addTarget(self, action: #selector(self.changePage(sender:)), for: .valueChanged)
    }
    // MARK: - Actions
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(imgsPagger.currentPage) * imagesScrollView.frame.size.width
        imagesScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    @IBAction func searchCloseDidTapped(_ sender: UIButton) {
        self.searchTxtField.text = ""
        self.searchTxtField.resignFirstResponder()
        self.isEditing = false
        self.viewModel.isSearchEnabled = false
        self.tableView.reloadData()
    }
    //MARK: - TextField delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string)
            self.viewModel.doSearch(txt: updatedText)
        }
        return true
    }
    
    
    
}
//MARK: - Scrollview delegate
extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != imagesScrollView && scrollView.contentOffset.y >= (self.searchY-10) {
            searchContainerView.frame.origin.y = max(0, scrollView.contentOffset.y)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        imgsPagger.currentPage = Int(pageNumber)
    }
}
// MARK: - TableView delegate and datasource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableViewDataSourceCount()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text =  self.viewModel.getTableViewItem(at: indexPath.row)
        return cell
    }
}
// MARK: - ViewModel delegate
extension MainViewController: MainViewModelDelegate {
    func reloadTableData() {
        self.tableView.reloadData()
    }
}
