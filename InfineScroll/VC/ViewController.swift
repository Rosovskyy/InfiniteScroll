//
//  ViewController.swift
//  InfineScroll
//
//  Created by Serhiy Rosovskyy on 6/26/19.
//  Copyright © 2019 Serhiy Rosovskyy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: -Properties
    var lowerBound = 0
    var upperBound = 0

    // MARK: -IBOutlets
    @IBOutlet weak var lowerBoundTextField: UITextField!
    @IBOutlet weak var upperBoundTextField: UITextField!

    // MARK: -Init
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: -Actions

    @IBAction func getCommentsTapped(_ sender: Any) {
        if let lowerBound = Int(self.lowerBoundTextField.text!), let upperBound = Int(self.upperBoundTextField.text!) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
            performSegue(withIdentifier: "getCommentsDummy", sender: self)
        } else {
            let alert = UIAlertController(title: "Wrong Input", message: "Enter two numbers", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Wrong!", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let scrollVC = segue.destination as! ScrollViewController
        scrollVC.lowerBound = self.lowerBound
        scrollVC.upperBound = self.upperBound
    }

}

