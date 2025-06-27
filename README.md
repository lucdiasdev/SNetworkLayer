![SNetworkLayer: HTTP Networking Library](https://raw.githubusercontent.com/lucdiasdev/SNetworkLayer/master/SNetworkLayer/Assets/SNetworkLayerL.png)

[![Language: Swift 5](https://img.shields.io/badge/language-swift5-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/SNetworkLayer.svg?style=flat)](https://cocoapods.org/pods/SNetworkLayer)
![Platform: iOS 14+](https://img.shields.io/badge/platform-iOS%2014%2B-blue.svg?style=flat)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Version](https://img.shields.io/cocoapods/v/SNetworkLayer.svg?style=flat)](https://cocoapods.org/pods/SNetworkLayer)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![License](https://img.shields.io/cocoapods/l/SNetworkLayer.svg?style=flat)](https://cocoapods.org/pods/SNetworkLayer)
[![Build Status](https://img.shields.io/github/actions/workflow/status/lucdiasdev/SNetworkLayer/ci.yml?branch=master&style=flat)](https://github.com/lucdiasdev/SNetworkLayer/actions/workflows/ci.yml)

**`SNetworkLayer`** é um framework modular para chamadas de rede em Swift, com foco em extensibilidade, tratamento robusto de erros e suporte a múltiplos modelos de API. Ele permite ao desenvolvedor configurar requisições de forma clara e padronizada, com tratamento de erros customizável/nativo e suporte a cancelamento, pause e retomada de tarefas.

### Principais Recursos

- **Decodificação genérica** para modelos de sucesso e erro.
- **Tratamento centralizado de erros**, com fallback para erros nativos do Swift.
- **Controle de tarefas**: cancelar, pausar e retomar.
- **Log de requisições e respostas**, com informações úteis para debugging.
- **Testes unitários** com cobertura das principais operações do framework.
- **Compatível com CocoaPods e SPM**.

## ⚙️ Instalação

Atualmente, o `SNetworkLayer` é distribuído via CocoaPods e SPM

#### Swift Package Manager (requires xcode 11)

1.  No Xcode, vá até o menu: **File > Add Packages…**
2.  Insira a URL do repositório: `https://github.com/lucdiasdev/SNetworkLayer.git`
3.  Clique em  **Next**.
4.  Em  **Dependency Rule**, escolha **“Up to Next Major”** e defina a versão mínima desejada (ex:  1.0.1).
5.  Selecione o pacote SNetworkLayer e adicione ao target desejado.

#### Cocoapods
Adicione ao seu `Podfile`:
```swift
pod 'SNetworkLayer'
```
Em seguida, execute `pod install`

Importe o módulo onde for necessário:
```swift
import SNetworkLayer
```

## ⌨️ Guia Rápido de Uso

1. Crie sua API com conformidade ao protocolo Target:

```swift
enum MyApi {
    case getExample
}

extension MyApi: Target {
    var baseURL: URL {
        guard let url = URL(string: "https://my-api.com/") else {
            assertionFailure("Invalid static URL")
            return URL(fileURLWithPath: "")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getExample:
            return "api/myendpoint"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getExample:
            return .get
        }
    }
    
    var headerParamaters: [String : String]? {
        switch self {
        case .getExample:
            return ["Authorization": "token"]
        }
    }
    
    var task: Task {
        switch self {
        case .getExample:
            return .requestDefault
        }
    }
}
```
- Pontos adicionais sobre o protoclo `Target`:
O objeto httpMethod existem os tipos de métodos para requisições `.get`, `.post`, `.put`, `.delete` e `.path`.

O objeto task existem os modelos para requisições, em alguns casos precisa ser definido o `EncodeParameters` que recebe `.query` para parametros de URL e `.http` que defini uma requisição como `x-www-form-urlencoded`, assim segue os modelos existentes para task:

**.requestDefault** monta uma requisição simples sem dados adicionais.

**requestBodyEncodable(Encodable)** monta uma requisição com um ​​corpo `body` de solicitação definido com o tipo `Encodable`.

**requestParameters(parameters: [String: Any], encodeParameters: EncodeParameters)** monta uma requisição com parametros de URL como `query string` utilizando `.query` para **EncodeParameters** ou defini uma requisição como `x-www-form-urlencoded` utilizando `.http`.

**requestBodyEncodableWithParameters(Encodable, queryParameters: [String: Any])** monta uma requisição com um corpo `body` de solicitação definido com o tipo `Encodable` e tambem permite passar parâmetros de URL como `query string` em forma de um dict ao mesmo tempo.

**requestBodyAndQueryParameters(bodyParameters: [String: Any], queryParameters: [String: Any]?)** monta uma requisição com um conjunto de corpos do tipo dicionário permitindo passar parâmetros como corpo `body` da requisição e tambem parâmetros de URL como `query string` ao mesmo tempo

2. Faça a requisição usando sua Service (Utilize conforme a necessidade de uso com sua resposta de chamada, tanto para sucesso quanto para falha):

- fetch que recebe um Data e um Error
```swift
class ExampleService: SNetworkLayer<MyApi> {
    func fetchGetExample(completion: @escaping (Result<Data, Error>) -> Void) {
        fetch(.getExample) { result, _ in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
```

- fetch que recebe um sucesso decodificável e um erro decodificável
```swift
class ExampleService: SNetworkLayer<MyApi> {
    func fetchGetExample(completion: @escaping (FlowResult<MyData, MyBackendError>) -> Void) {
        fetch(.getExample, dataType: MyData.self, errorType: MyBackendError.self) { result, _ in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
```

- fetch que recebe um Data e um erro decodificável
```swift
class ExampleService: SNetworkLayer<MyApi> { 
    func fetchGetExample(completion: @escaping (FlowResult<Data, MyBackendError>) -> Void) {
        fetch(.getExample, errorType: MyBackendError.self) { result, _ in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
```
- fetch que recebe um sucesso decodificável e um Erro
```swift
class ExampleService: SNetworkLayer<MyApi> {
    func fetchGetExample(completion: @escaping (Result<MyData, Error>) -> Void) {
        fetch(.getExample, dataType: MyData.self) { result, _ in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
```

## ▶️ Guia de Configurações Adicionais (Opcionais)

1. Defina sua baseURL (opcional, mas recomendado). Como boa prática, defina sua baseURL em um único ponto do projeto — especialmente se ela for fixa. Isso evita repetição e torna a configuração de novas APIs mais simples e consistente:

```swift
extension Target {
    var baseURL: URL {
        guard let url = URL(string: "https://my-api.com/") else {
            assertionFailure("Invalid static URL")
            return URL(fileURLWithPath: "")
        }
        return url
    }
}
```

2. O protocolo `SNetworkLayerErrorNetworkConfigProvider` é de extrema importancia se você gostaria de fornecer mensagens customizadas para erros genericos de `rede` ou de `decodificação`, lembrando que o seu modelo de error definido por você deve se conformar com o protocolo `Erro` do Swift, exemplo abaixo:

```swift
struct MyBackendError: Error, Codable {
    var error: String
    var code: Int
}
```

pode ser configurado uma única vez, idealmente no início do ciclo de vida da aplicação, no AppDelegate/SceneDelegate `SNetworkLayerErrorConfiguration.provider = MyConfigProviderError.self` sendo assim segue um exemplo abaixo de como implementar:
inicialmente crie sua estrutura com suas mensagens de acordo com sua necessidade:

```swift
struct MyConfigProviderError: SNetworkLayerErrorNetworkConfigProvider {
    static var decodableErrorMapper: ((DecodingError) -> (any Error & Codable)?)? = { decodingError in
        switch decodingError {
        case .keyNotFound(let key, let context):
            return MyBackendError(error: "Chave não encontrada: \(key.stringValue). \nContexto: \(context.debugDescription)", code: -11)
        case .typeMismatch(let type, let context):
            return MyBackendError(error: "Tipo incompatível: \(type). \nContexto: \(context.debugDescription)", code: -22)
        case .valueNotFound(let type, let context):
            return MyBackendError(error: "Valor não encontrado para tipo: \(type). \nContexto: \(context.debugDescription)", code: -33)
        case .dataCorrupted(let context):
            return MyBackendError(error: "Dados corrompidos. \nContexto: \(context.debugDescription)", code: -44)
        default:
            return MyBackendError(error: "Erro de decoding desconhecido: \(decodingError)", code: -55)
        }
    }
            
        
    static var networkErrorMapper: ((NetworkError) -> (any Error & Codable)?)? = { error in
        switch error {
        case .unknown:
            return MyBackendError(error: "Ocorreu um erro desconhecido de rede.", code: -1)
        case .timeOut:
            return MyBackendError(error: "A conexão está lenta. Tente novamente mais tarde.", code: -2)
        case .notConnectedNetwork:
            return MyBackendError(error: "Você está offline. Verifique sua conexão com a internet.", code: -3)
        case .lostConnectedNetwork:
            return MyBackendError(error: "A conexão com o servidor foi perdida.", code: -4)
        case .cancelConnectedNetwork:
            return MyBackendError(error: "A operação foi cancelada.", code: -5)
        }
    }
}
```

e apos implemente seu `MyConfigProviderError` para o provider
```swift
SNetworkLayerErrorConfiguration.provider = MyConfigProviderError.self
```

**Lembrando sempre neste caso utilizar o fetch com Erro Customizado**

## 🙎🏻‍♂️ Author

Lucas Rodrigues Dias, lucrodrigs@gmail.com

[![LinkedIn](https://custom-icon-badges.demolab.com/badge/LinkedIn-0A66C2?logo=linkedin-white&logoColor=fff)](https://www.linkedin.com/in/lucdiasdev/)

## 📚 License

SNetworkLayer is available under the MIT license. See the LICENSE file for more info.
