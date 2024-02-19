//
//  TableViewCell.swift
//  SectionTable
//
//  Created by Dao Van Nha on 17/02/2024.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func update(title: String) {
        self.titleLabel.text = title
    }
    
}
