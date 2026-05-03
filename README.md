# StudioBox Music Importer

StudioBox Music Importer e um app auxiliar para preparar musicas .mp4 para o Karaoke StudioBox.

Padrao final esperado:

`Autor - Musica - 00000.mp4`

## Padrao oficial de nomes

Formato esperado: `Autor - Musica - 00000.mp4`.

O codigo deve ter exatamente 5 digitos.

O separador oficial desta ferramenta e ` - `, o que evita ambiguidades com artistas como `A-ha`.

## Indexacao da biblioteca base

A biblioteca base e formada por arquivos que ja seguem o padrao oficial.

Nesta fase, o app calcula codigos usados, maior codigo, buracos disponiveis, duplicidades de codigo e artistas conhecidos.

Ainda nao ha selecao real de pasta nesta fase.

## Estrategias de codigo

O app permitira continuar apos o maior codigo existente ou preencher buracos disponiveis primeiro.

Em qualquer estrategia, codigos repetidos sao proibidos.

O limite natural dos codigos e 99999 e o codigo 00000 nunca sera usado.

O app sera desenvolvido em fases.

O MVP inicial sera para Windows.

Android sera considerado depois.

Esta fase ainda nao implementa renomeio real.
