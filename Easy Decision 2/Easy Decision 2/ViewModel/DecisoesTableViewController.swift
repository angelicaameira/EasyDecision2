//
//  DecisoesTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 21/03/22.
//

import UIKit
import FirebaseFirestore

class DecisoesTableViewController: UITableViewController {
    
    var listaDeDecisoes: [Decisao] = []
    var firestore: Firestore!
    var decisoesListener: ListenerRegistration!
    var decisaoSelecionada: Decisao?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListenerRecuperarDecisoes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        decisoesListener.remove()
    }
    
    func addListenerRecuperarDecisoes(){
        
        decisoesListener = firestore.collection("decisoes").addSnapshotListener({ querySnapshot, erro in
            
            if erro == nil {
                self.listaDeDecisoes.removeAll()
                
                if let snapshot = querySnapshot {
                    for document in snapshot.documents {
                        do {
                            let dictionary = document.data()
                            let decisao = try Decisao(id: document.documentID, dictionary: dictionary)
                            self.listaDeDecisoes.append(decisao)
                        } catch {
                          print("Error when trying to decode Decisão: \(error)")
                        }
                    }
                    self.tableView.reloadData()
                    self.decisaoSelecionada = nil
                }
            }
        })
    }
    
    func removerDecisao(indexPath: IndexPath){
        
        let decisao = self.listaDeDecisoes[indexPath.row]
        firestore.collection("decisoes").document(decisao.id!).delete()
        self.listaDeDecisoes.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeDecisoes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaDecisao", for: indexPath)
        
        let indice = indexPath.row
        let dadosDecisao = self.listaDeDecisoes[indice]
        
        celula.textLabel?.text = dadosDecisao.descricao
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self else { return }
                self.removerDecisao(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self else { return }
                let indice = indexPath.row
                self.decisaoSelecionada = self.listaDeDecisoes[indice]
                
                self.performSegue(withIdentifier: "adicionaDecisao", sender: self)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adicionaDecisao" {
            let navigationController = segue.destination as! UINavigationController
            let viewDestino = navigationController.viewControllers.first as! AdicionaDecisaoViewController
            viewDestino.decisao = self.decisaoSelecionada
        }
    }
    
}
