# Exportador de Logs e Biblioteca para Firecast (log_extrator)

![Firecast](https://img.shields.io/badge/Plataforma-RRPG%20Firecast-orange) ![Linguagem](https://img.shields.io/badge/Linguagem-LUA-blue) ![Ferramenta](https://img.shields.io/badge/Ferramenta-Python-yellow)

Este é um conjunto de ferramentas para a plataforma **RRPG Firecast**, projetado para ajudar mestres a exportar e fazer backup dos dados de suas mesas de jogo. O projeto é composto por duas partes principais:

1.  Um **Plugin Firecast** que exporta os dados da sua mesa em dois formatos distintos.
2.  Um **Script em Python** que converte o backup XML de volta para uma estrutura de pastas e arquivos no seu computador.

## Funcionalidades Principais

*   **Exportar Diretório para .TXT**: Escaneia um diretório escolhido por você (incluindo subdiretórios) e consolida todo o conteúdo textual das fichas de personagem em um único arquivo `.txt`, ordenado alfabeticamente. Perfeito para compilar logs de sessões e criar uma narrativa contínua.

*   **Exportar Biblioteca para .XML**: Cria um backup completo e estruturado de **toda** a biblioteca da sua mesa (pastas, fichas e seus dados) em um único arquivo `.xml`. Ideal para segurança e portabilidade.

*   **Converter .XML para Diretórios (Via Python)**: Utiliza o script `converter.py` para ler o arquivo `.xml` gerado pelo plugin e recriar toda a estrutura de pastas e arquivos de texto no seu computador, permitindo o acesso e a manipulação dos dados fora do Firecast.

## Instalação do Plugin

1.  Vá para a página de [**Releases**](https://github.com/tk4500/log_extrator/releases) deste repositório.
2.  Baixe o arquivo `log_extrator.rpk` da versão mais recente.
3.  No RRPG Firecast, vá até o menu **Plugins**.
4.  Clique em **Instalar** e selecione o arquivo `.rpk` que você acabou de baixar.
5.  O plugin adicionará uma janela acoplável chamada **"Exportador de Pastas"** à sua mesa.

## Como Usar o Plugin

### Exportando Logs para .TXT

1.  Na janela do plugin, clique no botão **"Selecionar Pasta e Exportar"**.
2.  Uma janela de diálogo listará os diretórios na raiz da biblioteca da sua mesa. Escolha qual deles você deseja exportar.
3.  O plugin irá varrer todos os personagens dentro da pasta selecionada (e subpastas), compilar seus textos e pedir para você salvar o resultado em um arquivo `.txt`.

### Fazendo Backup da Biblioteca para .XML

1.  Na janela do plugin, clique no botão **"Exportar XML"**.
2.  O plugin irá ler toda a estrutura da sua biblioteca e gerar um arquivo `.xml`.
3.  Uma janela para "Salvar Arquivo" será exibida para que você possa guardar seu backup.

## Restaurando a Estrutura com o Conversor Python

Depois de gerar um arquivo `.xml` com o backup da sua biblioteca, você pode usar o script `converter.py` para recriar a estrutura de pastas e arquivos no seu computador.

#### Pré-requisitos
*   Ter o [Python 3](https://www.python.org/downloads/) instalado no seu sistema.

#### Como Usar

1.  Faça o download ou clone o [repositório do GitHub](https://github.com/tk4500/log_extrator/) para ter acesso ao script `converter.py`.
2.  Coloque o seu arquivo `.xml` exportado (ex: `MinhaMesa.xml`) na mesma pasta onde está o script `converter.py`.
3.  Abra um terminal ou prompt de comando nessa pasta.
4.  Execute o seguinte comando, substituindo `MinhaMesa.xml` pelo nome do seu arquivo:
    ```bash
    python converter.py MinhaMesa.xml
    ```
5.  O script irá criar uma nova pasta chamada `MinhaMesa` e, dentro dela, recriará toda a estrutura de diretórios e arquivos `.txt` contidos no seu backup, exatamente como estava na sua biblioteca do Firecast.

## Para Desenvolvedores

*   **`log_extrator.lfm`**: Define a interface do usuário do plugin, com os dois botões que acionam as funções principais.
*   **`exporter.lua`**: Contém toda a lógica de exportação, usando as APIs do Firecast de forma assíncrona (`async`/`await`) para não travar a interface durante o processamento.
*   **`converter.py`**: Script independente que usa a biblioteca `xml.etree.ElementTree` do Python para parsear o XML e `os` para criar a estrutura de arquivos e diretórios. Inclui uma função para sanitizar nomes de arquivos, garantindo a compatibilidade entre sistemas operacionais.
