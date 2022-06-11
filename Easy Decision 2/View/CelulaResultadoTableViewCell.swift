//
//  CelulaResultadoTableViewCell.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 18/05/22.
//

import UIKit

class CelulaResultadoTableViewCell: UITableViewCell {
    
    // MARK: - View code
    
    lazy var labelDescricao: UILabel = {
        let view = UILabel()
        view.contentMode = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var labelPercentual: UILabel = {
        let view = UILabel()
        view.contentMode = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "celulaResultado")
        self.contentView.addSubview(labelDescricao)
        self.contentView.addSubview(labelPercentual)
        
        labelDescricao.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        labelDescricao.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        labelDescricao.trailingAnchor.constraint(equalTo: self.labelPercentual.leadingAnchor, constant: -10).isActive = true
        labelDescricao.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
        labelPercentual.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        labelPercentual.leadingAnchor.constraint(equalTo: self.labelDescricao.trailingAnchor, constant: 10).isActive = true
        labelPercentual.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        labelPercentual.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
