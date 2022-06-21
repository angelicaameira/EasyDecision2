//
//  CelulaAvaliacaoTableViewCell.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 12/05/22.
//

import UIKit
import FirebaseFirestore

class CelulaAvaliacaoTableViewCell: UITableViewCell {
    
    var firestore: Firestore!
    var atualizaDadosAvaliacao: (() -> ())?
    
    // MARK: - View code
    
    lazy var labelDescricao: UILabel = {
        let view = UILabel()
        view.contentMode = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var labelNota: UILabel = {
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
        labelNota.text = String(Int(sender.value))
        atualizaDadosAvaliacao?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "celulaAvaliacao")
        firestore = Firestore.firestore()
        
        self.contentView.addSubview(labelDescricao)
        self.contentView.addSubview(labelNota)
        self.contentView.addSubview(botaoStepper)
        
        labelDescricao.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        labelDescricao.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        labelDescricao.trailingAnchor.constraint(equalTo: self.labelNota.leadingAnchor, constant: -10).isActive = true
        labelNota.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        labelNota.widthAnchor.constraint(equalToConstant: 20).isActive = true
        labelNota.leadingAnchor.constraint(equalTo: self.labelDescricao.trailingAnchor, constant: 10).isActive = true
        labelNota.trailingAnchor.constraint(equalTo: self.botaoStepper.leadingAnchor, constant: -10).isActive = true
        botaoStepper.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        botaoStepper.leadingAnchor.constraint(equalTo: self.labelNota.trailingAnchor, constant: 10).isActive = true
        botaoStepper.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        
        let labelPeso = (labelNota.text ?? "1") as String
        botaoStepper.value = Double(labelPeso) ?? 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
