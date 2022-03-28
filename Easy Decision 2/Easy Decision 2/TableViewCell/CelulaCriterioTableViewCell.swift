//
//  CelulaCriterioTableViewCell.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 27/03/22.
//

import UIKit

class CelulaCriterioTableViewCell: UITableViewCell {
    
    // MARK: - View code
    
    lazy var labelDescricao: UILabel = {
        let view = UILabel()
        view.contentMode = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
      }()
    
    lazy var labelPeso: UILabel = {
        let view = UILabel()
        view.contentMode = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
      }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(labelDescricao)
        self.contentView.addSubview(labelPeso)
        
        labelDescricao.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        
        labelDescricao.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        
        labelPeso.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        
        labelPeso.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        
        labelPeso.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
