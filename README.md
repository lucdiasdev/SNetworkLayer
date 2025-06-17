# SNetworkLayer
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
2.  No campo de URL do repositório, insira `https://github.com/lucdiasdev/SNetworkLayer.git`
3.  Clique em  **Next**.
4.  Em  **Dependency Rule**, selecione: **“Up to Next Major”**  e defina a versão mínima desejada (ex:  1.0.1).
5.  Após o carregamento, selecione o pacote  SNetworkLayer  e adicione-o ao target desejado do seu projeto.

#### Cocoapods
Adicione ao seu `Podfile`:
```swift
pod 'SNetworkLayer'
```
Em seguida, execute `pod install`

Em qualquer arquivo em que você queira usar o SNetworkLayer, não se esqueça de importar o framework com `import SNetworkLayer`

## ⌨️ Exemplos de implementação

teste

## Author

lucdiasdev, lucrodrigs@gmail.com

## License

SNetworkLayer is available under the MIT license. See the LICENSE file for more info.
