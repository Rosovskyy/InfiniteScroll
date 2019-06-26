//
//  ScrollViewController.swift
//  InfineScroll
//
//  Created by Serhiy Rosovskyy on 6/26/19.
//  Copyright © 2019 Serhiy Rosovskyy. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    // MARK: -Properties
    var loadMore = false
    var comments: [Comment] = []

    var lowerBound = 0
    var upperBound = 0

    // MARK: -IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    // MARK: -Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.backgroundColor = .white
        self.tableViewConfiguration()
        self.setInitialItems()
    }

    // MARK: -Configuration
    /**
        The configuration of the table view.
        And adding to it two types of cells: the first one stores the data,
        the second one - shows the activity indicator.
    */
    func tableViewConfiguration() {
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.reloadData()
    }

    /**
        Get 10 first comments using requests and add comments to the array.
    */
    func setInitialItems() {
        for number in self.lowerBound..<self.lowerBound+10 {
            if self.lowerBound > self.upperBound {
                break
            }
            parseJson(commentId: number) { [weak self] comment in
                if self?.comments.count == 0 {
                    self?.comments.append(comment)
                } else {
                    self?.findPosition(comment: comment)
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            self.lowerBound += 1
        }
    }

    // MARK: -Functions
    /**
        The function sends the http request and get the comment in the JSON view.
        Then JSONDecoder puts all the data out of the json to the struct.
    */
    func parseJson(commentId: Int, completion: @escaping (Comment) -> (Void)) {
        let jsonURL = "https://jsonplaceholder.typicode.com/comments/\(commentId)"

        guard let url = URL(string: jsonURL) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }

            do {
                let comment: Comment = try JSONDecoder().decode(Comment.self, from: data)
                completion(comment)
            } catch let err {
                print("Something failed: \(err)")
            }
        }
        task.resume()
    }

    /**
        The function finds where to put the comment in the
        comments array. It compares the id and if the id
        is equal - insert in that position and shift another
        elements to the right.
    */
    func findPosition(comment: Comment) {
        var put = false
        for index in 0..<self.comments.count {
            if self.comments.contains(obj: comment) {
                continue
            }
            if self.comments[index].id >= comment.id {
                self.comments.insert(comment, at: index)
                put = true
            }
        }
        if !put {
            self.comments.append(comment)
        }
    }

    // MARK: -Actions
    /**
        When the 'back' button tapped, it moves to the first
        view controller.
    */
    @IBAction func backTapped(_ sender: Any) {
        performSegue(withIdentifier: "backDummy", sender: self)
    }

    @IBAction func refreshTapped(_ sender: Any) {
        self.tableView.reloadData()
    }

}


extension ScrollViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: -DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return comments.count
        } else if section == 1 && loadMore {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
            cell.titleLabel.text = self.comments[indexPath.row].name
            cell.subTitleLabel.text = self.comments[indexPath.row].body
            cell.idLabel.text = String(self.comments[indexPath.row].id)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }

    // MARK: -ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 4 {
            if !loadMore {
                loadMoreData()
            }

        }
    }

    /**
        If we scroll down - new data load and appears in the
        table.
    */
    func loadMoreData() {
        loadMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            for number in self.lowerBound+1..<self.lowerBound+11 {
                if self.lowerBound >= self.upperBound {
                    break
                }
                self.lowerBound += 1
                self.parseJson(commentId: number) {[weak self] comment in
                    self?.findPosition(comment: comment)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
            self.loadMore = false
        })
    }
}
