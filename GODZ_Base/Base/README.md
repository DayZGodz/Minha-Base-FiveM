# GODZ Project

## 🏎️ GODZ Tuning (Customização de Alta Performance)

Recurso avançado de customização veicular integrado ao ecossistema GODZ.

### Funcionalidades
- **Interface Glassmorphism**: UI moderna e imersiva.
- **Sistema de Níveis**: Peças de alta performance (Turbo, Motor Pro) exigem nível alto de mecânico.
- **Persistência**: Modificações salvas automaticamente no banco de dados.
- **Integração Econômica**: Preços sincronizados via `GODZ_MASTER_CONFIG.json`.
- **Otimização**: Baixo uso de Resmon (0.01ms ocioso).

### Configuração
Os preços das peças podem ser ajustados no arquivo `GODZ_MASTER_CONFIG.json`:
```json
"tuning_prices": {
    "engine_base": 5000,
    "turbo_base": 15000,
    "brakes_base": 2000,
    ...
}
```

### Comandos
- Aproxime-se da bancada de tuning ou do marker na oficina e pressione `E`.
