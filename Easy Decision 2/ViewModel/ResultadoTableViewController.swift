//
//  ResultadoTableViewController.swift
//  Easy Decision 2
//
//  Created by Angélica Andrade de Meira on 01/04/22.
//

import UIKit
import FirebaseFirestore
import Foundation

class ResultadoTableViewController: UITableViewController {
    
    var decisao: Decisao?
    var listaDeOpcoes: [Opcao]? = []
    var listaDeAvaliacoes: [Avaliacao]? = []
    var listaDeCriterios: [Criterio]? = []
    var listaDeResultados: [Resultado]? = []
    var alertaRecuperarResultado = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao recuperar a lista de resultado", preferredStyle: .alert)
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(CelulaResultadoTableViewCell.self, forCellReuseIdentifier: "celulaResultado")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if listaDeResultados?.count == 0 {
            criaResultado()
        }
        ordenaListaDeResultadosPorPercentual()
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
                }
            }
            
            let percentualDaOpcao = NumberFormatter.localizedString(from: NSNumber(value: (dividendo/divisor)), number: .percent)
            guard let idOpcao = dadosOpcao.id
            else { return }
            
            do {
                let resultado = try Resultado(idDecisao: idDecisao, idOpcao: idOpcao, percentual: "\(percentualDaOpcao)")
                self.listaDeResultados?.append(resultado)
            } catch let erro {
                self.alertaRecuperarResultado.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                print("Error when trying to decode Resultado:" + erro.localizedDescription)
            }
        }
    }
    
    func ordenaListaDeResultadosPorPercentual() {
        listaDeResultados?.sort(by: { resultadoEsquerda, resultadoDireita in
            return resultadoEsquerda.percentual > resultadoDireita.percentual
        })
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
