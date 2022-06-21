//
//  CelulaCriterioTableViewCell.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 27/03/22.
//

import UIKit
import FirebaseFirestore

class CelulaCriterioTableViewCell: UITableViewCell {
    
    var firestore: Firestore!
    var atualizaDadosCriterio: (() -> ())?
    
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
        view.text = String(Int(botaoStepper.value))
        return view
    }()
    
    lazy var botaoStepper: UIStepper = {
        let view = UIStepper()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumValue = 1
        view.maximumValue = 5
        view.addTarget(self, action: #selector(didTouchStepper), for: .valueChanged)
        return view
    }()
    
    @objc func didTouchStepper(sender: UIStepper) {
        labelPeso.text = String(Int(sender.value))
        atualizaDadosCriterio?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "celulaCriterio")
        firestore = Firestore.firestore()
        
        self.contentView.addSubview(labelDescricao)
        self.contentView.addSubview(labelPeso)
        self.contentView.addSubview(botaoStepper)
        
        labelDescricao.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        labelDescricao.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        labelDescricao.trailingAnchor.constraint(equalTo: self.labelPeso.leadingAnchor, constant: -10).isActive = true
        labelPeso.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        labelPeso.widthAnchor.constraint(equalToConstant: 20).isActive = true
        labelPeso.leadingAnchor.constraint(equalTo: self.labelDescricao.trailingAnchor, constant: 10).isActive = true
        labelPeso.trailingAnchor.constraint(equalTo: self.botaoStepper.leadingAnchor, constant: -10).isActive = true
        botaoStepper.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        botaoStepper.leadingAnchor.constraint(equalTo: self.labelPeso.trailingAnchor, constant: 10).isActive = true
        botaoStepper.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        
        let labelPeso = (labelPeso.text ?? "1") as String
        botaoStepper.value = Double(labelPeso) ?? 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
