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
    /**
        These variables are needed to extract data from
        the text fields and put them into these
        variables.
    */
    var lowerBound = 0
    var upperBound = 0

    // MARK: -IBOutlets
    /**
        Initialization of the text fields.
    */
    @IBOutlet weak var lowerBoundTextField: UITextField!
    @IBOutlet weak var upperBoundTextField: UITextField!

    // MARK: -Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldConfiguration()
    }

    // MARK: -Configuration
    /**
        Set the delegation for text fields.
    */
    func textFieldConfiguration() {
        self.lowerBoundTextField.delegate = self
        self.upperBoundTextField.delegate = self
    }

    // MARK: -Actions
    /**
        When the button is clicked, we get the data from the text fields
        and assign them to variables lowerBound and upperBound. And move
        to the other view controller.
        If it is no value in one of the text fields - alert appeared.
    */
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

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedNumbers = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedNumbers.isSuperset(of: characterSet)
    }
}
