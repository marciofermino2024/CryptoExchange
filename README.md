# CryptoExchange iOS App

App iOS SwiftUI para consultar exchanges e pares de mercado via CoinMarketCap API PRO.

---

## Requisitos

| Item | Versão mínima |
|------|---------------|
| Xcode | 15.0+ |
| iOS | 17.0+ |
| Swift | 5.9+ |

---

## Como configurar a API Key

A API key da CoinMarketCap **não está hardcoded**. Ela é injetada via `.xcconfig`.

### Passo a passo

1. Na raiz do projeto, copie o arquivo de exemplo:
   ```bash
   cp Secrets.xcconfig.example Secrets.xcconfig
   ```

2. Abra `Secrets.xcconfig` e preencha sua chave:
   ```
   CMC_API_KEY = SUA_CHAVE_AQUI
   ```

3. **Nunca commite** `Secrets.xcconfig`. Ele está no `.gitignore`.

4. Abra `CryptoExchange.xcodeproj` no Xcode e compile normalmente.

> ⚠️ Se a key estiver ausente ou vazia, o app vai encerrar com uma mensagem clara no console explicando o problema.

---

## Como rodar os testes

### Unit Tests
```
Cmd + U  (no Xcode)
```
Ou via CLI:
```bash
xcodebuild test \
  -project CryptoExchange.xcodeproj \
  -scheme CryptoExchange \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
Os UI Tests estão no target `CryptoExchangeUITests`. Rodar com:
```bash
xcodebuild test \
  -project CryptoExchange.xcodeproj \
  -scheme CryptoExchangeUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

> ⚠️ Os UI tests são resilientes: se a rede não estiver disponível (sem API key válida), validam apenas que o estado de erro é mostrado com o botão "Tentar novamente".

---

## Arquitetura

O projeto segue **MVVM + Clean Architecture** com separação em 3 camadas:

### Domain
- **Entities**: `Exchange`, `ExchangeMarketPair`, `MarketCurrency` — modelos limpos, sem dependência de framework
- **UseCases**: `GetExchangeListUseCase`, `GetExchangeDetailUseCase`, `GetExchangeMarketPairsUseCase`
- **Repository Protocol**: `ExchangeRepositoryProtocol`

### Data
- **DTOs**: mapeiam exatamente o JSON da API (snake_case via CodingKeys)
- **Mappers**: `ExchangeMapper`, `MarketPairMapper` — convertem DTOs em domain entities
- **Network**: `APIClient` (URLSession + async/await), `MultiIDAPIClient` (suporte a múltiplos IDs na mesma chamada), `Endpoint` (enum type-safe)
- **Repository Implementation**: `ExchangeRepository` com cache in-memory via `NSCache`

### UI
- **ViewModels**: `ExchangeListViewModel`, `ExchangeDetailViewModel` com `@MainActor` + `@Published`
- **UiState**: enum genérico `idle | loading | success(T) | empty | error(AppError)`
- **Screens**: `ExchangeListScreen`, `ExchangeDetailScreen`
- **Components**: `ExchangeRowView`, `MarketPairRowView`, `LoadingView`, `ErrorView`, `EmptyStateView`

---

## Decisões técnicas

### Endpoints utilizados (reais, documentados)

| Feature | Endpoint |
|---------|----------|
| Listagem paginada | `GET /v1/exchange/map` (retorna IDs ordenados por volume) |
| Detalhes + logo + fees | `GET /v1/exchange/info?id=...` (suporta IDs separados por vírgula) |
| Pares de mercado | `GET /v1/exchange/market-pairs/latest?id=...` |

> `GET /v1/exchange/info` **não lista exchanges sozinho** — exige IDs. Por isso a listagem usa `/v1/exchange/map` primeiro para obter os IDs, depois busca infos em batch via `/v1/exchange/info`.

### Cache
- `NSCache` in-memory com limite de 50 entradas
- Chave por página (ex: `list_1_20`) e por detalhe (ex: `detail_270`)
- Pull-to-refresh invalida e recarrega

### Paginação
- Lazy load: ao exibir os 3 últimos itens da lista, carrega a próxima página
- Tamanho de página: 20 itens

### Localização
- Todos os textos da UI estão em `Resources/Localizable.strings`
- Nenhum texto hardcoded na UI

---

## Estrutura de pastas

```
CryptoExchange/
├── CryptoExchange.xcodeproj/
│   └── project.pbxproj
├── Secrets.xcconfig          ← criar manualmente (não committar)
├── Secrets.xcconfig.example  ← modelo
├── .gitignore
├── README.md
└── CryptoExchange/
    ├── CryptoExchangeApp.swift
    ├── DependencyContainer.swift
    ├── Domain/
    │   ├── Entities/
    │   │   ├── Exchange.swift
    │   │   └── ExchangeMarketPair.swift
    │   ├── Repository/
    │   │   └── ExchangeRepositoryProtocol.swift
    │   └── UseCases/
    │       ├── GetExchangeListUseCase.swift
    │       ├── GetExchangeDetailUseCase.swift
    │       └── GetExchangeMarketPairsUseCase.swift
    ├── Data/
    │   ├── Network/
    │   │   ├── AppConfiguration.swift
    │   │   ├── AppError.swift
    │   │   ├── APIClient.swift
    │   │   ├── MultiIDAPIClient.swift
    │   │   └── Endpoint.swift
    │   ├── DTOs/
    │   │   ├── ExchangeMapDTO.swift
    │   │   ├── ExchangeInfoDTO.swift
    │   │   └── ExchangeMarketPairsDTO.swift
    │   ├── Mappers/
    │   │   └── ExchangeMapper.swift
    │   └── Repository/
    │       └── ExchangeRepository.swift
    ├── UI/
    │   ├── ViewModels/
    │   │   ├── UiState.swift
    │   │   ├── ExchangeListViewModel.swift
    │   │   └── ExchangeDetailViewModel.swift
    │   ├── Screens/
    │   │   ├── ExchangeList/
    │   │   │   └── ExchangeListScreen.swift
    │   │   └── ExchangeDetail/
    │   │       └── ExchangeDetailScreen.swift
    │   └── Components/
    │       ├── LoadingView.swift
    │       ├── ErrorView.swift
    │       ├── EmptyStateView.swift
    │       ├── ExchangeRowView.swift
    │       └── MarketPairRowView.swift
    └── Resources/
        ├── Info.plist
        ├── Localizable.strings
        └── Assets.xcassets/
            ├── AppIcon.appiconset/
            ├── AccentColor.colorset/
            └── Contents.json
```
