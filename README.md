# SNetworkLayer
[![Language: Swift 5](https://img.shields.io/badge/language-swift5-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 13+](https://img.shields.io/badge/platform-iOS%2013%2B-blue.svg?style=flat)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/ws/blob/master/LICENSE)
[![Build Status](https://app.bitrise.io/app/a6d157138f9ee86d/status.svg?token=W7-x9K5U976xiFrI8XqcJw&branch=master)](https://app.bitrise.io/app/a6d157138f9ee86d)
[![codebeat badge](https://codebeat.co/badges/ae5feb24-529d-49fe-9e28-75dfa9e3c35d)](https://codebeat.co/projects/github-com-freshos-networking-master)
![Release version](https://img.shields.io/github/release/freshOS/Networking.svg)

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



# SNetworkLayer

[![CI Status](https://img.shields.io/travis/lucdiasdev/SNetworkLayer.svg?style=flat)](https://travis-ci.org/lucdiasdev/SNetworkLayer)
[![Version](https://img.shields.io/cocoapods/v/SNetworkLayer.svg?style=flat)](https://cocoapods.org/pods/SNetworkLayer)
[![License](https://img.shields.io/cocoapods/l/SNetworkLayer.svg?style=flat)](https://cocoapods.org/pods/SNetworkLayer)
[![Platform](https://img.shields.io/cocoapods/p/SNetworkLayer.svg?style=flat)](https://cocoapods.org/pods/SNetworkLayer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SNetworkLayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SNetworkLayer'
```

## Author

lucdiasdev, lucrodrigs@gmail.com

## License

SNetworkLayer is available under the MIT license. See the LICENSE file for more info.
