require("firecast.lua");
require("utils.lua");
require("log.lua");
-- Módulo de lógica para o exportador de diretórios da biblioteca
local M = {}
-- Função recursiva para encontrar todos os personagens dentro de um diretório e seus subdiretórios
local function loadPersonagem(personagem)
    local promise = personagem:asyncOpenNDB();
    local ficha = await(promise);
    if ficha then
        local ps = NDB.getChildNodes(ficha.txt);
        local txt = "";
        for _, p in ipairs(ps) do
            local es = NDB.getChildNodes(p)
            for _, e in ipairs(es) do
                if e.text ~= nil then
                    txt = txt .. e.text;
                end
            end
            txt = txt .. "\n";
        end
        return "Log: " ..(personagem.name or "Desconhecido") .. "\n\n" .. txt.. "\n\n========================================\n\n";
    else
        return "!! ERRO AO CARREGAR A FICHA !!";
    end
end

local function encontrarPersonagensNoDiretorio(diretorio, personagensEncontrados)
    logs = diretorio.children;
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
    Log.i("a", "todosOsPersonagens".. #todosOsPersonagens);
    
    if #todosOsPersonagens == 0 then
        showMessage("Nenhum personagem encontrado no diretório '" .. nomeDiretorioEscolhido .. "'.");
        return;
    end

    local textoCompleto = "Exportação do diretório: " .. nomeDiretorioEscolhido .. "\n\n";
    

    -- 5 & 6. Carregar a ficha de cada personagem, ler o texto e armazenar.
    for _, personagem in ipairs(todosOsPersonagens) do
        local a = loadPersonagem(personagem);
        textoCompleto = textoCompleto ..a;
    end

    -- 7. Exportar o arquivo final.
    local stream = Utils.newMemoryStream();
    stream:writeBinary("utf8", textoCompleto);
    stream.position = 0;

    Dialogs.saveFile("Salvar Exportação do Diretório", stream, nomeDiretorioEscolhido .. ".txt", "text/plain");
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
