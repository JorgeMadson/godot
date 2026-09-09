# Corre, o ônibus!

Protótipo jogável em Godot 4 com cinco fases. Veja o ônibus passar, corra pela orla inspirada em Fortaleza e alcance a parada antes que ele parta.

## Como abrir e jogar

1. Importe `project.godot` no gerenciador de projetos da Godot.
2. No painel **Sistema de arquivos**, abra `scenes/main.tscn`.
3. Aperte **F5** para executar o projeto. **F6** executa a cena que estiver aberta; use com `main.tscn` aberta.
4. Use **← →** para correr e **Espaço** para pular. Um toque produz um salto curto; segurar produz um salto alto.
5. Use **P** para pausar, **R** para reiniciar a fase e **Enter** para avançar depois de embarcar.
6. Aperte **F8** para parar e voltar ao editor.

## Como funciona

No começo de cada fase, o ônibus passa pelo personagem e segue até a parada. Quando ele chega, o controle e o cronômetro são liberados. Cada colisão tira dois segundos e empurra o personagem, com proteção temporária contra impactos repetidos. O encontro fictício grita “Perdeu! Perdeu!” antes de bloquear o caminho.

Entrar pela porta aberta conclui a fase. As fases 1 e 2 são tutoriais mais curtos: a primeira tem 2.800 px e 19 segundos; a segunda tem 4.000 px e 24 segundos. As fases 3–5 usam o percurso completo, com mais obstáculos e 34, 31 e 28 segundos. Se o cronômetro chegar a zero, a câmera mostra a parada, a porta fecha e o ônibus parte antes da tela de derrota.

## Onde mexer

- `scenes/main.tscn`: ponto de entrada da fase.
- `scenes/player.tscn`: personagem reutilizável, desenho provisório e colisão.
- `scripts/game.gd`: percurso, câmera, cronômetro, HUD, vitória, derrota e reinício.
- `scripts/player.gd`: aceleração, salto responsivo, tolerância de borda e tropeço.
- `scripts/scenery.gd`: cenário costeiro estilizado de Fortaleza.
- `scripts/obstacle.gd`: cones, caixas e barreiras.
- `scripts/threat.gd`: encontro fictício com aviso antes de bloquear o caminho.
- `scripts/bus.gd`: ônibus inspirado nas referências e área de embarque.

O ponto de origem do personagem fica nos pés. O chão fica em Y = 424. A câmera mostra uma área de 960 × 540 e acompanha a corrida. As fotos de referência permanecem na raiz.

O plano de continuação e a passagem de trabalho para outra IA estão em `PLANO_DO_JOGO.md`.
