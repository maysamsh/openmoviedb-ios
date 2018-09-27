//
//  MainTableViewController.swift
//  OpenMovie
//
//  Created by Maysam Shahsavari on 9/17/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    private let networkService = NetworkService.shared()
    private var movies = [JSON.Search.Movie]()
    private var searchParameters = (nextPage: 1,  batchCount: 0,  totalResults: 0)
    private let searchController = UISearchController(searchResultsController: nil)
    private var loadMoreIsCalled = false
    fileprivate var isLoading = false
    fileprivate var scrollDirection = ScrollDirection.up
    fileprivate var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Internal Functions
    
    func configureUI(){
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 128
        tableView.rowHeight = UITableView.automaticDimension
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Open Movie DB"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        showHelpLabel(withText: "Type a movie name, such as love")
    }
    
    func showHelpLabel(withText text: String) {
        let helpLabel = UILabel()
        helpLabel.frame.size = CGSize.zero
        helpLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        helpLabel.textColor = UIColor.lightGray
        helpLabel.textAlignment = .center
        helpLabel.text = text
        helpLabel.sizeToFit()
        tableView.backgroundView = helpLabel
    }
    
    func search(for movieName: String, page: Int, handler: @escaping ((Bool, Error?) -> Void)) {
        networkService.search(for: movieName, page: page) { (searchObject, error) in
            if let search = searchObject, error == nil {
                if let searchReasults = searchObject?.results {
                    self.searchParameters.batchCount = searchReasults.count
                    self.searchParameters.nextPage = page + 1
                    self.searchParameters.totalResults = Int(search.totalResults ?? "0") ?? 0
                    self.movies = searchReasults
                    DispatchQueue.main.async {
                        self.tableView.backgroundView = UIView()
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.movies.removeAll()
                        self.showHelpLabel(withText: "Could not finc anything!")
                        self.tableView.reloadData()
                    }
                }
                handler(true, nil)
            }else{
                print(error?.localizedDescription ?? "Error")
                self.showAlert(title: "Search failed!", message: error?.localizedDescription ?? "Error")
                handler(false, error)
            }
        }
    }
    
    func loadMore(for movieName: String, page: Int) {
        loadMoreIsCalled = true
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        
        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = false
        
        networkService.search(for: movieName, page: page) { [weak self] (searchObject, error) in
            DispatchQueue.main.async {
                self?.tableView.tableFooterView?.isHidden = true
                spinner.stopAnimating()
            }
            
            if let search = searchObject, error == nil {
                if let searchReasults = searchObject?.results {
                    self?.searchParameters.batchCount = searchReasults.count
                    self?.searchParameters.nextPage = page + 1
                    self?.searchParameters.totalResults = Int(search.totalResults ?? "0") ?? 0
                    self?.movies.append(contentsOf: searchReasults)
                    self?.isLoading = false
                    self?.loadMoreIsCalled = false
                    DispatchQueue.main.async {
                        let offset = self?.tableView.contentOffset
                        
                        self?.tableView.reloadData()
                        
                        if let _offset = offset {
                            self?.tableView.setContentOffset(_offset, animated: false)
                        }
                    }
                }
            }else{
                print(error?.localizedDescription ?? "Error")
                self?.showAlert(title: "Search failed!", message: error?.localizedDescription ?? "Error")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SearchTableViewCell{
            cell.configureCell(with: movies[indexPath.row])
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Movie", sender: movies[indexPath.row].imdbID)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        guard movies.count < searchParameters.totalResults else {return}
        
        if let visibleRow = self.tableView.visibleCells.last {
            guard self.loadMoreIsCalled == false else {return}
            if let lastVisibleRow = tableView.indexPath(for: visibleRow)?.row {
                if lastVisibleRow == self.movies.count - 2 {
                    if scrollDirection == .down {
                        if !isLoading {
                            self.loadMoreIsCalled = true
                            if let _searchText = self.searchText {
                                self.loadMore(for: _searchText, page: searchParameters.nextPage)
                            }
                        }
                    }
                }
            }
            
            
        }
        
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Movie" {
            if let viewController = segue.destination as? MovieTableViewController, let movieID = sender as? String {
                viewController.imdbID = movieID
            }
        }
    }
    
}

// MARK: - UIScrollView

extension MainTableViewController {
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y >= 0 {
            scrollDirection = .down
        }else{
            scrollDirection = .up
        }
        
    }
}

// MARK: - UISearchResultsUpdating

extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            guard searchTerm.count > 2 else {return}
            self.searchText = searchTerm
            searchController.searchBar.isLoading = true
            search(for: searchTerm, page: 1) {[weak self] (done, error) in
                DispatchQueue.main.async {
                    self?.searchController.searchBar.isLoading = false
                }
                if !done {
                    print(error?.localizedDescription ?? "Error")
                    self?.showAlert(title: "Search failed!", message: error?.localizedDescription ?? "Error")
                }
            }
        }
    }
}

