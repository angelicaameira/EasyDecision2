//
//  ResultadoTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 01/04/22.
//

import UIKit
import FirebaseFirestore

class ResultadoTableViewController: UITableViewController {
    
    var firestore: Firestore!
    var decisao: Decisao?
    var listaDeOpcoes: [Opcao]? = []
    var listaDeAvaliacoes: [Avaliacao]? = []
    var listaDeCriterios: [Criterio]? = []
    var listaDeResultados: [Resultado]? = []
    var resultadoListener: ListenerRegistration!
    
    // MARK: - View code
    
    private lazy var botaoConcluir: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Concluir"
        view.target = self
        view.action = #selector(concluir)
        return view
    }()
    
    @objc func concluir() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Resultado"
        self.navigationItem.rightBarButtonItems = [botaoConcluir]
        firestore = Firestore.firestore()
        addListenerRecuperarResultados()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(CelulaResultadoTableViewCell.self, forCellReuseIdentifier: "celulaResultado")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if listaDeResultados?.count == 0 {
            criaResultado()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resultadoListener.remove()
    }
    
    func addListenerRecuperarResultados() {
        guard
            self.decisao != nil,
            let idDecisao = self.decisao?.id
        else { return }
        
        resultadoListener = firestore.collection("resultado").whereField("idDecisao", isEqualTo: idDecisao).addSnapshotListener { [self] querySnapshot, erro in
            if erro == nil {
                self.listaDeResultados?.removeAll()
                guard let snapshot = querySnapshot
                else { return }
                for document in snapshot.documents {
                    do {
                        let dictionary = document.data()
                        let resultado = try Resultado(id: document.documentID, idDecisao: idDecisao, dictionary: dictionary)
                        self.listaDeResultados?.append(resultado)
                    } catch {
                        print("Error when trying to decode Resultado: \(error)")
                    }
                }
                self.tableView.reloadData()
            } else {
                return
            }
        }
    }
    
    func criaResultado() {
        guard
            let decisao = self.decisao,
            let idDecisao = decisao.id,
            let listaDeAvaliacoes = listaDeAvaliacoes,
            let listaDeCriterios = listaDeCriterios,
            let listaDeOpcoes = listaDeOpcoes
        else { return }
        
        for dadosOpcao in listaDeOpcoes {
            
            let avaliacoesDaOpcao = listaDeAvaliacoes.filter({ avaliacao in
                return avaliacao.idOpcao == dadosOpcao.id
            })
            
            var dividendo = 0.0
            var divisor = 0.0
            
            for dadosCriterio in listaDeCriterios {
                
                for dadosAvaliacao in avaliacoesDaOpcao {
                    
                    if dadosCriterio.id == dadosAvaliacao.idCriterio {
                        
                        guard
                            let valorAvaliacao = Int(dadosAvaliacao.valor),
                            let pesoCriterio = Int(dadosCriterio.peso)
                        else { return }
                        
                        dividendo = dividendo + Double((valorAvaliacao * pesoCriterio))
                        divisor = divisor + Double((5 * pesoCriterio))
                    }
                } //  if dadosCriterio.id == dadosAvaliacao.idCriterio && dadosOpcao.id == dadosAvaliacao.idOpcao && dadosAvaliacao.idDecisao == idDecisao
            }
            
            let percentualDaOpcao = (dividendo/divisor) * 100
            
            firestore.collection("resultado").document().setData([
                "idDecisao" : idDecisao as Any,
                "idOpcao" : dadosOpcao.id as Any,
                "percentual" : "\(percentualDaOpcao)%"
            ])
        }
        
       
        
        //var percentualDaOpcao = (avaliação1.nota * critério1.peso + avaliaçãoN.nota * critérioN.peso) / (5 * critério1.peso + 5 * critérioN.peso)
        
        
//        guard let comparacao = listaDeResultados?.contains(where: { resultado in
//            return resultado.idOpcao == resultado.idOpcao
//        }) else { return }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaDeOpcoes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celula = tableView.dequeueReusableCell(withIdentifier: "celulaResultado", for: indexPath) as? CelulaResultadoTableViewCell,
              self.decisao != nil
        else { return UITableViewCell() }
        let indice = indexPath.row
        let dadosResultado = self.listaDeResultados?[indice]
        let dadosOpcao = self.listaDeOpcoes?[indice]
        
        celula.labelDescricao.text = dadosOpcao?.descricao
        celula.labelPercentual.text = dadosResultado?.percentual
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
