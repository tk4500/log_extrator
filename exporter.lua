require("firecast.lua");
require("utils.lua");
require("log.lua");
-- Módulo de lógica para o exportador de diretórios da biblioteca
local M = {}

local function getTextFromNode(ps)
    if not ps then
        return ""
    end
    local txt = ""
    for _, p in ipairs(ps) do
        local es = NDB.getChildNodes(p)
        for _, e in ipairs(es) do
            if e.text ~= nil then
                txt = txt .. e.text;
            end
        end
        txt = txt .. "\n";
    end
    if txt == "" then
        return nil
    end
    return txt;
end
-- Função recursiva para encontrar todos os personagens dentro de um diretório e seus subdiretórios
local function loadPersonagem(personagem)
    local promise = personagem:asyncOpenNDB();
    local node = await(promise);
    if node.abas then
        local abas = NDB.getChildNodes(node.abas);
        local final = ""
        for _, aba in ipairs(abas) do
            local nome = aba.nome_aba
            local ps = NDB.getChildNodes(aba.txt);
            local txt = getTextFromNode(ps);
            if txt and txt ~= "" then
                final = final .. "\n\n" .. nome .. ":\n" .. txt;
            end
        end
        return  final ;
    elseif node.txt then
        local ps = NDB.getChildNodes(node.txt);
        return getTextFromNode(ps);
    else
        return "Nenhum texto encontrado no personagem";
    end
end

local function encontrarPersonagensNoDiretorio(diretorio, personagensEncontrados)
    local logs = diretorio.children;
    for _, filho in ipairs(logs) do
        if filho.tipo == "personagem" then
            table.insert(personagensEncontrados, filho);
        end
        if filho.tipo == "diretorio" then
            encontrarPersonagensNoDiretorio(filho, personagensEncontrados);
        end
    end
    table.sort(personagensEncontrados, function(a, b)
        return a.name < b.name; -- Ordena os personagens pelo nome
    end)
end

local function diretoriosOfBiblioteca(itens, diretorios, nomesDiretorios)
    for _, item in ipairs(itens) do
        if item.tipo == "diretorio" then
            table.insert(diretorios, item);
            table.insert(nomesDiretorios, item.name or "Diretório sem nome");
        end
    end
end
local function getDirectoryFromName(nome, diretorios)
    for _, dir in ipairs(diretorios) do
        if dir.name == nome then
            return dir;
        end
    end
    return nil; -- Diretório não encontrado
end

local function selectDirectory(nomeDiretorioEscolhido, diretorios)
    if not nomeDiretorioEscolhido then
        return; -- Usuário cancelou
    end
    -- Encontrar o objeto BibliotecaItem correspondente ao nome escolhido
    local diretorioEscolhido = getDirectoryFromName(nomeDiretorioEscolhido, diretorios);
    if not diretorioEscolhido then
        showMessage("Erro: Diretório escolhido não foi encontrado.");
        return;
    end


    -- 4. Varrer o diretório selecionado em busca de todos os personagens.
    local todosOsPersonagens = {};
    encontrarPersonagensNoDiretorio(diretorioEscolhido, todosOsPersonagens);
    Log.i("a", "todosOsPersonagens" .. #todosOsPersonagens);

    if #todosOsPersonagens == 0 then
        showMessage("Nenhum personagem encontrado no diretório '" .. nomeDiretorioEscolhido .. "'.");
        return;
    end

    local textoCompleto = "Exportação do diretório: " .. nomeDiretorioEscolhido .. "\n\n";


    -- 5 & 6. Carregar a ficha de cada personagem, ler o texto e armazenar.
    for _, personagem in ipairs(todosOsPersonagens) do
        local a = (personagem.name or "Desconhecido") .. "\n\n" .. loadPersonagem(personagem).. "\n\n========================================\n\n";
        textoCompleto = textoCompleto .. a;
    end

    -- 7. Exportar o arquivo final.
    local stream = Utils.newMemoryStream();
    stream:writeBinary("utf8", textoCompleto);
    stream.position = 0;

    Dialogs.saveFile("Salvar Exportação do Diretório", stream, nomeDiretorioEscolhido .. ".txt", "text/plain");
end



local function criarNodos(node, biblioteca)
    local filhos = biblioteca.children or {};
    for _, filho in ipairs(filhos) do
        if filho.tipo == "diretorio" then
            local nodoFilho = NDB.createChildNode(node, "dir");
            nodoFilho.nome = filho.name or "Diretório sem nome";
            criarNodos(nodoFilho, filho);
        elseif filho.tipo == "personagem" then
            Log.i("Criando nodo para personagem: " .. (filho.name or "Desconhecido"));
            local nodoFilho = NDB.createChildNode(node, "file");
            nodoFilho.nome = filho.name or "Diretório sem nome";
            local filhopromise = filho:asyncOpenNDB();
            local sucesso, personagem = pawait(filhopromise);
            nodoFilho.ficha = personagem;
        end
    end
end

function M.exportarxml(mesa)
    local biblioteca = mesa.biblioteca;
    local bibliotecapromise = NDB.newMemNodeDatabase();
    local node = await(bibliotecapromise);
    if not biblioteca then
        showMessage("A biblioteca da mesa não foi encontrada.");
        return;
    end
    if not node then
        showMessage("Erro ao criar o banco de dados temporário.");
        return;
    end
    criarNodos(node, biblioteca);
    local xmlCompleto = NDB.exportXML(node);
    local stream = Utils.newMemoryStream();
    stream:writeBinary("utf8", xmlCompleto);
    stream.position = 0;
    Dialogs.saveFile("Salvar Personagem XML", stream, mesa.nome .. ".xml", "text/plain");
end

function M.iniciarExportacao(mesa)
    Async.execute(function()
        -- 1. Obter a mesa atual. A variável 'mesa' é uma global disponível em macros e forms da mesa.
        if not mesa then
            showMessage("Este plugin só pode ser executado a partir de uma mesa.");
            return;
        end


        -- 2. Acessar a biblioteca da mesa e listar os diretórios na raiz.
        local biblioteca = mesa.biblioteca;
        local itens = biblioteca.children or {};
        local diretorios = {};
        local nomesDiretorios = {};

        if biblioteca and itens then
            diretoriosOfBiblioteca(itens, diretorios, nomesDiretorios);
        end


        if #nomesDiretorios == 0 then
            showMessage("Nenhum diretório encontrado na biblioteca desta mesa.");
            return;
        end

        -- 3. Pedir ao usuário para selecionar um dos diretórios.
        -- A função 'choose' retorna o texto da opção selecionada.
        Dialogs.choose("Selecione o diretório para exportar", nomesDiretorios,
            function(selected, selectedIndex, selectedText)
                selectDirectory(selectedText, diretorios)
            end);
    end)
end

return M
