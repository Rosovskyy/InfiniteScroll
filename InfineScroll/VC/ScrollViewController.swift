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
    var comments: [Comment] = [Comment(postId: 1, id: 1, name: "Serhii", email: "rosovskyy@ucu.edu.ua", body: "Hello world")]
//    var items: [Int] = []

    var lowerBound = 0
    var upperBound = 0

    // MARK: -IBOutlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialItems()
        self.tableViewConfiguration()
    }

    func tableViewConfiguration() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self

//        self.tableView.rowHeight = UIScreen.main.bounds.height / 11

        self.tableView.reloadData()
    }

    func setInitialItems() {
        for number in self.lowerBound..<self.lowerBound+10 {
            if self.lowerBound > self.upperBound {
                break
            }
            parseJson(commentId: number)
//            items.append(number)
            print(self.comments.count)
            self.lowerBound += 1
        }
    }

    // MARK: -Functions
    func parseJson(commentId: Int) {
        let jsonURL = "https://jsonplaceholder.typicode.com/comments/\(commentId)"

        guard let url = URL(string: jsonURL) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }

            do {
                let comment: Comment = try JSONDecoder().decode(Comment.self, from: data)
                self.comments.append(comment)
                print(self.comments.count)
            } catch let err {
                print("Something failed: \(err)")
            }
        }
        task.resume()
    }
}

extension ScrollViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
//            return items.count
            return comments.count
        } else if section == 1 && fetchingMore {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            cell.textLabel?.text = "\(self.comments[indexPath.row].name)"
//            cell.textLabel?.text = "Item \(items[indexPath.row])"
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
                if number > self.upperBound {
                    break
                }
//                self.items.append(number)
                self.lowerBound += 1
                self.parseJson(commentId: number)
            }
//            let newItems = (self.items.count+1...self.items.count + 10).map { index in index }
//            self.items.append(contentsOf: newItems)
            self.fetchingMore = false
            self.tableView.reloadData()
        })
    }
}
