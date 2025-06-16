import xml.etree.ElementTree as ET
import os
import sys
import re

# --- NOVA FUNÇÃO DE SANITIZAÇÃO ---
def sanitizar_nome_arquivo(nome):
    """
    Remove caracteres inválidos de um nome de arquivo/pasta.
    Substitui caracteres como / \ : * ? " < > | e ... por um hífen.
    Remove espaços no início e final do nome.
    Remove pontos no início do nome.
    Garante que não termine com espaços.
    """
    if not nome:
        return ""

    # Lista de caracteres inválidos em nomes de arquivo para Windows/Linux
    caracteres_invalidos = r'<>:"/\|?*'
    
    # 1. Substitui caracteres inválidos por hífens
    nome_sanitizado = nome
    for char in caracteres_invalidos:
        nome_sanitizado = nome_sanitizado.replace(char, '-')
    
    # 2. Substitui sequências de três ou mais pontos por hífens
    nome_sanitizado = re.sub(r'\.{3,}', '-', nome_sanitizado)

    # 3. Remove espaços no início e final do nome
    nome_sanitizado = nome_sanitizado.strip()
    
    # 4. Garante que não comece com ponto
    while nome_sanitizado.startswith('.'):
        nome_sanitizado = nome_sanitizado[1:]
    
    # 5. Garante que não termine com espaços ou pontos
    nome_sanitizado = nome_sanitizado.rstrip(' .')
    
    # 6. Substitui múltiplos espaços por um único hífen
    nome_sanitizado = re.sub(r'\s+', '-', nome_sanitizado)
    
    return nome_sanitizado

# --- FUNÇÕES AUXILIARES (sem mudanças) ---

def extrair_conteudo_texto(txt_element):
    if txt_element is None:
        return ""
    paragrafos = []
    for p_tag in txt_element.findall('p'):
        partes_linha = []
        for e_tag in p_tag.findall('e'):
            texto = e_tag.get('text', '')
            if texto:
                partes_linha.append(texto)
        linha_completa = "".join(partes_linha)
        paragrafos.append(linha_completa)
    return "\n".join(paragrafos)

# --- FUNÇÕES ATUALIZADAS PARA USAR A SANITIZAÇÃO ---

def criar_arquivo_de_texto(file_element, caminho_atual):
    nome_base_arquivo_original = file_element.get('nome')
    if not nome_base_arquivo_original:
        print(f"Aviso: Tag <file> encontrada sem o atributo 'nome' em {caminho_atual}. Pulando.")
        return
    
    # Sanitiza o nome do arquivo base
    nome_base_sanitizado = sanitizar_nome_arquivo(nome_base_arquivo_original)

    ficha_element = file_element.find('ficha')
    if ficha_element is None:
        print(f"Aviso: Tag <file nome='{nome_base_arquivo_original}'> não contém <ficha>. Pulando.")
        return

    abas_element = ficha_element.find('abas')

    if abas_element is not None:
        nome_pasta_com_prefixo = f"Multiabas - {nome_base_sanitizado}"
        pasta_do_arquivo = os.path.join(caminho_atual, nome_pasta_com_prefixo)
        os.makedirs(pasta_do_arquivo, exist_ok=True)
        print(f"  > Criando pasta para abas: '{pasta_do_arquivo}'")

        for item_element in abas_element.findall('item'):
            nome_aba_original = item_element.get('nome_aba')
            if not nome_aba_original:
                continue
            
            # Sanitiza o nome da aba
            nome_aba_sanitizado = sanitizar_nome_arquivo(nome_aba_original)
            
            caminho_completo_aba = os.path.join(pasta_do_arquivo, f"{nome_aba_sanitizado}.txt")
            txt_element = item_element.find('txt')
            conteudo = extrair_conteudo_texto(txt_element)
            
            with open(caminho_completo_aba, 'w', encoding='utf-8') as f:
                f.write(conteudo)
            print(f"    - Escrevendo arquivo de aba: '{caminho_completo_aba}'")
    else:
        caminho_completo_arquivo = os.path.join(caminho_atual, f"{nome_base_sanitizado}.txt")
        txt_element = ficha_element.find('txt')
        conteudo = extrair_conteudo_texto(txt_element)
        
        with open(caminho_completo_arquivo, 'w', encoding='utf-8') as f:
            f.write(conteudo)
        print(f"  > Escrevendo arquivo: '{caminho_completo_arquivo}'")

def processar_elementos(elemento_xml, caminho_pai):
    for filho in elemento_xml:
        if filho.tag == 'dir':
            nome_pasta_original = filho.get('nome')
            if nome_pasta_original:
                # Sanitiza o nome da pasta
                nome_pasta_sanitizado = sanitizar_nome_arquivo(nome_pasta_original)
                novo_caminho = os.path.join(caminho_pai, nome_pasta_sanitizado)
                os.makedirs(novo_caminho, exist_ok=True)
                print(f"Criando pasta: '{novo_caminho}'")
                processar_elementos(filho, novo_caminho)
        
        elif filho.tag == 'file':
            criar_arquivo_de_texto(filho, caminho_pai)

# --- SCRIPT PRINCIPAL (sem mudanças) ---
def main():
    if len(sys.argv) < 2:
        print("Erro: Nenhum arquivo XML foi fornecido.")
        print(f"Uso: python {sys.argv[0]} <nome_do_arquivo.xml>")
        sys.exit(1)

    arquivo_xml = sys.argv[1]

    if not os.path.exists(arquivo_xml):
        print(f"Erro: O arquivo '{arquivo_xml}' não foi encontrado.")
        sys.exit(1)

    pasta_saida = os.path.splitext(os.path.basename(arquivo_xml))[0]

    os.makedirs(pasta_saida, exist_ok=True)
    print(f"Iniciando processamento de '{arquivo_xml}'.")
    print(f"A saída será gerada na pasta: '{pasta_saida}'")

    try:
        arvore = ET.parse(arquivo_xml)
        raiz = arvore.getroot()
        processar_elementos(raiz, pasta_saida)
        print("\nProcessamento concluído com sucesso!")
    except ET.ParseError as e:
        print(f"Erro ao interpretar o arquivo XML: {e}")
    except Exception as e:
        print(f"Ocorreu um erro inesperado: {e}")

if __name__ == "__main__":
    main()