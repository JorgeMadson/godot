# Corre, o ônibus! — plano e passagem de trabalho

## Objetivo e prioridade

Criar um jogo 2D de plataforma lateral em Godot 4, em pixel art, sobre correr atrás de ônibus porque o personagem está atrasado para trabalho ou escola. Embarcar conclui a fase. A prioridade é a jogabilidade: movimento responsivo, obstáculos legíveis, tentativas rápidas e dificuldade justa.

O usuário quer jogar o protótipo hoje. A primeira fase completa está implementada; priorizar ajustes encontrados na partida manual antes de múltiplas fases, arte elaborada ou sistemas secundários.

## Estado confirmado em 2026-09-09

### Refatoração de manutenção

As configurações das cinco fases agora estão em recursos tipados `levels/*.tres`, preservando os percursos e tempos. `level.gd` monta o percurso; `game.gd` coordena a partida; `hud.tscn` permite editar a interface visualmente. O ônibus usa enum e sinaliza quando termina de sair da câmera. A derrota é imediata quando o impacto zera o cronômetro. Movimento usa ações próprias do Input Map. Menus e controles de toque continuam pendentes.

O teste `tests/flow_test.gd` substitui `tests/smoke_loss.gd`. Os itens históricos abaixo descrevem a evolução anterior; para localizar responsabilidades atuais, consultar o README.

- `project.godot` aponta para `res://scenes/main.tscn`.
- `scenes/main.tscn`: cena principal mínima que carrega `scripts/game.gd`.
- `scripts/game.gd`: constrói uma fase linear completa, câmera, HUD, cronômetro, pausa, resultado e reinício.
- `scenes/player.tscn` e `scripts/player.gd`: personagem com aceleração, frenagem, pulo variável, buffer, tolerância após borda, tropeço e proteção temporária.
- `scripts/scenery.gd`: cenário costeiro estilizado com mar, areia, prédios e coqueiros.
- `scripts/obstacle.gd`: cones, caixas e barreiras com colisão por Area2D.
- `scripts/threat.gd`: encontro fictício sinalizado antes de bloquear o caminho.
- `scripts/bus.gd`: ônibus desenhado em código com cores e grafismos das referências e área de embarque.
- O usuário abriu o projeto na Godot e confirmou que viu o boneco na pista.
- Vitória, derrota por tempo, pausa, reinício e progressão por cinco fases foram implementados. Enter avança após a vitória; depois da quinta fase, reinicia o ciclo.
- O ônibus passa pelo personagem no início, segue fora da câmera até a parada e só então libera o controle e o cronômetro.
- Após teste manual do usuário, as fases introdutórias foram encurtadas: fase 1 tem comprimento 2.800, três obstáculos e 19 segundos; fase 2 tem comprimento 4.000, mais obstáculos, o encontro fictício e 24 segundos. As fases 3–5 mantêm comprimento 5.700 e tempos de 34, 31 e 28 segundos.
- O encontro fictício exibe “Perdeu! Perdeu!” antes de avançar para bloquear o caminho.
- A fase foi carregada pela Godot 4.7.2 em modo headless e terminou com código 0, sem erros de script. Ainda depende de partida manual para avaliar dificuldade, enquadramento e sensação do controle.
- Executável localizado em `/home/instituto/Documentos/dev/Godot_v4.7.2-stable_linux.x86_64`; não está no PATH. Em ambiente isolado, usar `XDG_DATA_HOME` e `XDG_CONFIG_HOME` apontando para `/tmp`.
- Referências na raiz: `onibus-fortaleza.jpg`, `onibus-fortaleza-2.jpg`, `onibus-fortaleza-3.jpg`.
- `README.md` contém instruções básicas. Não há repositório Git detectado na raiz.

## Direção de Fortaleza

Criar uma Fortaleza estilizada, com percursos fictícios inspirados na cidade, sem prometer reprodução geográfica fiel.

- Primeira fase: calçada inspirada na Beira-Mar, mar ao fundo, coqueiros, quiosques e prédios. Usar contraste para separar fundo e obstáculos.
- Fase posterior: Centro, fachadas comerciais, praça e referências visuais ao Theatro José de Alencar.
- Fase posterior: entorno do Dragão do Mar, arquitetura e cores características.
- Ônibus: azul-claro, janelas escuras e grafismos vermelhos/azuis baseados nas fotos locais. Arte em baixa resolução, sem suavização.
- Antes de reproduzir monumentos, consultar referências visuais públicas. Os locais são inspiração visual; não associar criminalidade a bairros específicos.

## Obstáculos e encontros

- Cones/caixas: saltar; introduzir um por vez.
- Buracos: controlar distância e duração do salto; adicionar depois que a colisão básica estiver sólida.
- Obras com passagem baixa: deslizar; construir só depois de garantir retorno seguro à postura em pé.
- Pedestres: atravessam de forma previsível e não causam dano violento.
- Criminosos fictícios: encontros de tentativa de assalto, sem combate ou violência gráfica. Um personagem sinaliza a aproximação e avança brevemente para bloquear o caminho; o jogador desvia ou salta. Contato causa tropeço/perda de tempo, como os outros obstáculos, sem roubar itens persistentes.
- Identificar a ameaça pela ação, animação e aviso, sem usar cor de pele ou aparência social como indicador.
- Nunca fazer ameaça aparecer sem aviso dentro da distância de reação. Após contato, dar breve proteção contra impactos repetidos.

## Escopo para jogar hoje

Uma fase de aproximadamente 45–90 segundos, com reinício imediato e chegada funcional ao ônibus.

1. Movimento e câmera: aceleração curta, frenagem, pulo variável, buffer de pulo e tolerância após bordas. Remover o limite de X da tela quando implementar o percurso maior. Garantir área de antecipação na câmera.
2. Percurso manual: trecho seguro inicial, cones e caixas espaçados, um encontro fictício com aviso, trecho final livre e parada. Sem geração procedural.
3. Ônibus e objetivo: ônibus parado aguardando, porta claramente marcada e Area2D para embarque. Cronômetro expressa o tempo até a partida. Ao acabar, fechar embarque e mostrar derrota; ao entrar a tempo, mostrar vitória.
4. Consequência de erro: tropeço, perda de velocidade e breve proteção. Evitar vidas e checkpoints nesta primeira fase: o custo principal é o tempo, e o reinício deve ser rápido.
5. Interface: controles sempre consultáveis, tempo restante, resultado, reiniciar e pausa. Parar o cronômetro durante pausa e após resultado. Priorizar teclado.
6. Arte mínima: ônibus reconhecível das referências, cenário costeiro estilizado e silhuetas distintas. Sons simples de pulo, impacto e chegada se houver tempo após validar o ciclo.
7. Validar o percurso completo e entregar instruções de execução no README.

## Depois da primeira fase funcionar

- Deslize e obstáculos altos; testar se levantar sob teto não prende o personagem.
- Criar variação visual própria para cada uma das cinco fases atuais.
- Salvar desbloqueios em `user://`; por enquanto a progressão vive durante a execução e F5 começa na fase 1.
- Cenários de Centro e Dragão do Mar; novas composições de obstáculos.
- Animações, áudio e ajustes de dificuldade baseados em partidas reais.
- Exportação executável quando o alvo e os templates estiverem disponíveis.
- Não incluir loja, moedas, árvore de habilidades ou geração procedural neste escopo.

## Organização e trabalho paralelizável

Usar cenas editáveis na Godot. Preservar a base funcional a cada integração. Não construir uma arquitetura genérica para um único nível.

| Frente | Arquivos sugeridos / responsabilidade | Pode começar quando |
|---|---|---|
| Movimento | `scripts/player.gd`, `scenes/player.tscn`; movimento e feedback de tropeço | Imediatamente |
| Arte e cenário | `assets/`, cena de fundo independente; ônibus visual sem lógica de vitória | Imediatamente, com fotos existentes |
| Obstáculos | Cenas próprias em `scenes/obstacles/` e scripts correspondentes; colisão e aviso | Após combinar interface de impacto com movimento |
| Integração | `scenes/main.tscn`, controlador da partida, câmera, HUD, cronômetro e embarque | Pode preparar ciclo enquanto outras frentes trabalham |
| Verificação | Teste de controles, percurso, derrota, vitória e reinício | Depois da primeira integração |

Contrato mínimo sugerido: origem do personagem nos pés; método `stumble()` encapsula impacto e proteção; controlador de partida habilita/desabilita controle; obstáculos solicitam tropeço; ônibus emite sinal de embarque; controlador decide vitória/derrota e impede resultados duplicados. Confirmar nomes antes de delegar; não adicionar sistema de eventos genérico.

Evitar edição simultânea de `main.tscn`, `project.godot` e `player.gd`. Um integrador cuida desses pontos. Trabalho em arte e cenas independentes é o melhor candidato a paralelismo. Definir responsáveis por arquivos antes de iniciar agentes. Este plano identifica oportunidades; nenhum agente foi iniciado só para redigir este documento.

## Critérios de aceite do protótipo

- F5 abre a fase sem seleção manual de cena e sem erros de script.
- Jogador anda, pula, aterrissa e percorre o mapa sem sair do chão ou ficar preso.
- Obstáculos são visíveis antes da decisão e impacto não gera punição repetida a cada frame.
- Há tempo para vencer após alguns erros; percurso perfeito também é testado.
- Chegar à porta antes da partida dá vitória uma única vez.
- Esgotar o tempo dá derrota e impede embarque tardio.
- Reiniciar restaura posição, tempo, obstáculos e controles.
- Pausa congela partida e cronômetro.
- Cenário evoca Fortaleza e ônibus segue as referências.
- Registrar o que foi executado de verdade. Não declarar validação na engine apenas por inspeção textual.

## Referência técnica

Documentação oficial indicada pelo usuário: https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html

Consultar as páginas necessárias conforme a implementação. O pedido atual é salvar e atualizar o plano; a implementação restante ainda está pendente.
