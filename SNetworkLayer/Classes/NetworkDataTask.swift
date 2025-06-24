//
//  NetworkDataTask.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 07/04/25.
//

import Foundation

/// wrapper seguro em torno de `URLSessionDataTask`, fornecendo uma interface controlada para operações comuns
/// `iniciar`, `pausar` e `cancelar` a task
/// exemplo pratico
///
/// ```
/// let task = fetch(.targetExample) { result, _ in
///                 completion(result)
///            }
/// task?.suspend()
/// ```
///
public class NetworkDataTask {
    private let task: URLSessionDataTask?
    
    init(task: URLSessionDataTask?) {
        self.task = task
    }
    
    /// cancela a execução da requisição de rede.
    /// útil para evitar processamento desnecessário (por exemplo, ao sair de uma tela)
    public func cancel() {
        task?.cancel()
    }
    
    /// suspende temporariamente a execução da task.
    /// pode ser usada, por exemplo, quando há perda de conectividade temporária e você deseja retomar depois.
    public func suspend() {
        task?.suspend()
    }
    
    /// inicia ou retoma a execução da task.
    public func resume() {
        task?.resume()
    }
    
    /// retorna o estado atual da task: `.running`, `.suspended`, `.canceling` ou `.completed`.
    /// pode ser usado para lógica condicional, como impedir chamadas múltiplas simultâneas. (sem o uso de um async/await)
    public var state: URLSessionTask.State? {
        return task?.state
    }
}
