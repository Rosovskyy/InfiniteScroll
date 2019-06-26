//
//  LoadingCell.swift
//  InfineScroll
//
//  Created by Serhiy Rosovskyy on 6/26/19.
//  Copyright © 2019 Serhiy Rosovskyy. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    // MARK: -IBOutlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: -Init
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: -State
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
