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
    var fetchingMore = false
    var comments: [Comment] = []

    var lowerBound = 0
    var upperBound = 0

    // MARK: -IBOutlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewConfiguration()
        self.setInitialItems()
    }

    func tableViewConfiguration() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.reloadData()
    }

    func setInitialItems() {
        for number in self.lowerBound..<self.lowerBound+10 {
            if self.lowerBound > self.upperBound {
                break
            }
            parseJson(commentId: number) { [weak self] comment in
//                self?.comments.append(comment)
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
    func parseJson(commentId: Int, completion: @escaping (Comment) -> (Void)) {
        let jsonURL = "https://jsonplaceholder.typicode.com/comments/\(commentId)"

        guard let url = URL(string: jsonURL) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }

            do {
                let comment: Comment = try JSONDecoder().decode(Comment.self, from: data)
                print("Comment - \(commentId)")
                completion(comment)
//                print("Number - \(self.comments.count)")
            } catch let err {
                print("Something failed: \(err)")
            }
        }
        task.resume()
    }

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
}

extension ScrollViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return comments.count
        } else if section == 1 && fetchingMore {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            cell.textLabel?.text = "\(self.comments[indexPath.row].id) - \(self.comments[indexPath.row].name)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 4 {
            if !fetchingMore {
                beginBatchFetch()
            }

        }
    }

    func beginBatchFetch() {
        fetchingMore = true
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            for number in self.lowerBound+1...self.lowerBound+10 {
                if self.lowerBound > self.upperBound {
                    break
                }
                self.lowerBound += 1
                self.parseJson(commentId: number) {[weak self] comment in
//                    self?.comments.append(comment)
                    self?.findPosition(comment: comment)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
            self.fetchingMore = false
            self.tableView.reloadData()
        })
    }
}
