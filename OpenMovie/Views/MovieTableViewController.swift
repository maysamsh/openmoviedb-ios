//
//  MovieTableViewController.swift
//  OpenMovie
//
//  Created by Maysam Shahsavari on 9/18/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit

class MovieTableViewController: UITableViewController {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var imdbRateScore: UILabel!
    @IBOutlet var metascoreLabel: UILabel!
    @IBOutlet var directorCell: UITableViewCell!
    @IBOutlet var writerCell: UITableViewCell!
    @IBOutlet var plotCell: UITableViewCell!
    @IBOutlet var genreCell: UITableViewCell!
    
    private let networkService = NetworkService.shared()
    private var numberOfSections = 1
    
    var imdbID: String? {
        didSet{
            if let id = imdbID {
                loadMovie(withID: id)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Internal Functions
    
    func showHelpLabel(withText text: String) {
        DispatchQueue.main.async {
            let helpLabel = UILabel()
            helpLabel.frame.size = CGSize.zero
            helpLabel.font = UIFont.preferredFont(forTextStyle: .callout)
            helpLabel.textColor = UIColor.lightGray
            helpLabel.textAlignment = .center
            helpLabel.text = text
            helpLabel.numberOfLines = 0
            helpLabel.lineBreakMode = .byWordWrapping
            helpLabel.sizeToFit()
            self.tableView.backgroundView = helpLabel
        }
    }
    
    func configureUI(){
        tableView.tableFooterView = UIView()
        navigationItem.title = "Movie Details"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        for item in [plotCell, writerCell, genreCell, directorCell] {
            item?.textLabel?.numberOfLines = 0
            item?.textLabel?.lineBreakMode = .byWordWrapping
        }
        
        infoLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        infoLabel.minimumScaleFactor = 0.6
        infoLabel.adjustsFontSizeToFitWidth = true
        
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.font = UIFont.preferredBoldFont(forTextStyle: .body)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        yearLabel.textColor = UIColor.gray
        yearLabel.numberOfLines = 1
        yearLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    func loadMovie(withID id: String){
        networkService.getMovie(with: id) { [weak self] (movieObject, error) in
            if let movie = movieObject, error == nil {
                if movie.response.lowercased() ==  "true" {
                    self?.numberOfSections = 1
                    self?.setMovieInfo(with: movie)
                }else{
                    self?.numberOfSections = 0
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    self?.showHelpLabel(withText: "Seems the movie does not exist!")
                }
                
            }else{
                self?.numberOfSections = 0
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                self?.showHelpLabel(withText: error?.localizedDescription ?? "Error")
                print(error?.localizedDescription ?? "Error")
            }
        }
    }
    
    func setMovieInfo(with movie: JSON.Movie){
        DispatchQueue.main.async {
            let activityView = UIActivityIndicatorView()
            activityView.style = .gray
            self.tableView.backgroundView = UIView()
            
            self.posterImageView.image = UIImage()
            self.posterImageView.clipsToBounds = true
            self.posterImageView.addSubview(activityView)
            activityView.center = self.posterImageView.center
            activityView.startAnimating()
            
            self.networkService.getImage(url: movie.poster, handler: { [weak self] (data, error) in
                if let _data = data {
                    DispatchQueue.main.async {
                        activityView.stopAnimating()
                        activityView.removeFromSuperview()
                        self?.posterImageView.image = UIImage(data: _data)
                        self?.posterImageView.contentMode = .scaleAspectFill
                    }
                }
            })
            
            self.nameLabel.text = movie.title
            
            self.yearLabel.text = movie.year
            
            for label in [self.imdbRateScore, self.metascoreLabel] {
                label?.textAlignment = .center
                label?.numberOfLines = 2
            }
            
            let defaultCalloutFont = UIFont.preferredFont(forTextStyle: .callout)
            
            var _title = NSAttributedString(string: "IMDB\n",
                                            attributes: [NSAttributedString.Key.font: UIFont.preferredBoldFont(forTextStyle: .callout) ?? defaultCalloutFont])
            var _value = NSAttributedString(string: movie.imdbRating,
                                            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout) , NSAttributedString.Key.foregroundColor: UIColor.gray])
            self.imdbRateScore.attributedText = self.attributedString(from: [_title, _value])
            
            _title = NSAttributedString(string: "Metascore\n",
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredBoldFont(forTextStyle: .callout) ?? defaultCalloutFont ])
            _value = NSAttributedString(string: movie.metascore,
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout), NSAttributedString.Key.foregroundColor: UIColor.gray])
            self.metascoreLabel.attributedText = self.attributedString(from: [_title, _value])
            
            self.infoLabel.text = "\(movie.language) | \(movie.runtime)"
            
            
            _title = NSAttributedString(string: "Director: ",
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredBoldFont(forTextStyle: .callout) ?? defaultCalloutFont ])
            _value = NSAttributedString(string: movie.director,
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout), NSAttributedString.Key.foregroundColor: UIColor.gray])
            self.directorCell.textLabel?.attributedText = self.attributedString(from: [_title, _value])
            
            _title = NSAttributedString(string: "Writer(s): ",
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredBoldFont(forTextStyle: .callout) ?? defaultCalloutFont ])
            _value = NSAttributedString(string: movie.writer,
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout), NSAttributedString.Key.foregroundColor: UIColor.gray])
            self.writerCell.textLabel?.attributedText = self.attributedString(from: [_title, _value])
            
            _title = NSAttributedString(string: "Genre: ",
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredBoldFont(forTextStyle: .callout) ?? defaultCalloutFont ])
            _value = NSAttributedString(string: movie.genre,
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout), NSAttributedString.Key.foregroundColor: UIColor.gray])
            self.genreCell.textLabel?.attributedText = self.attributedString(from: [_title, _value])
            
            _title = NSAttributedString(string: "Plot: ",
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredBoldFont(forTextStyle: .callout) ?? defaultCalloutFont ])
            _value = NSAttributedString(string: movie.plot,
                                        attributes: [NSAttributedString.Key.font: UIFont.preferredItalicFont(forTextStyle: .callout) ?? defaultCalloutFont, NSAttributedString.Key.foregroundColor: UIColor.gray])
            self.plotCell.textLabel?.attributedText = self.attributedString(from: [_title, _value])
            self.tableView.reloadData()
        }
    }
    
    func attributedString(from items: [NSAttributedString]) -> NSMutableAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        for item in items {
            mutableAttributedString.append(item)
        }
        
        return mutableAttributedString
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 90
        case 2:
            return 55
        default:
            return UITableView.automaticDimension
        }
    }

}
