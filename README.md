# WebTech Installer

Este projeto contém um script automatizado para configurar o ambiente necessário para rodar aplicações WebTech. Ele instala dependências essenciais como Node.js, PM2, Go, PostgreSQL, entre outras, e automatiza a configuração do sistema.

---

## 📋 Pré-requisitos

Certifique-se de que o sistema atende aos seguintes requisitos antes de executar o instalador:

- **Sistema Operacional**: Ubuntu 18.04 ou superior.
- **Permissões**: Acesso de superusuário (sudo).
- **Conexão com a Internet**: Necessária para baixar pacotes e dependências.

---

## 📦 Ferramentas Instaladas

O instalador automatiza a instalação das seguintes ferramentas:

- **Node.js e npm**: Plataforma e gerenciador de pacotes JavaScript.
- **PM2**: Gerenciador de processos para aplicações Node.js.
- **Go**: Linguagem de programação para construir aplicações robustas.
- **PostgreSQL**: Banco de dados relacional.

---

## 🛠️ Configurações Automáticas

O script realiza as seguintes configurações automaticamente:

- Criação de um banco de dados PostgreSQL com:
  - Usuário e senha fornecidos pelo usuário.
  - Banco de dados nomeado pelo usuário.
- Geração de um arquivo `.env` com variáveis de ambiente necessárias.
- Configuração do **PM2** para gerenciar o processo da aplicação.
- Compilação automática da aplicação escrita em Go.
- Configuração para reinício automático da aplicação no boot do sistema.

---

## 🚀 Como Usar

1. Clone o Repositório

```bash
git clone https://github.com/rafaWPP/install-wuzapi.git
```

```bash
cd install-wuzapi
```

2. Torne o Script Executável
```bash
chmod +x install.sh
```

3. Execute o Instalador
```bash
./install.sh
```

## 📝 Exemplos de Entrada

Durante a execução do script, você será solicitado a fornecer algumas informações. Aqui estão exemplos do que você pode fornecer:  

Usuário do Banco de Dados: wuzapi  
Senha do Banco de Dados: senha123  
Nome do Banco de Dados: wuzapidb  
Porta da Aplicação: 8080  
Nome do Processo no PM2: wuzapi  
Token de Administrador: ABCD1234  

---

## 🎯 Resultado Esperado

Após a conclusão do instalador:  

- O banco de dados PostgreSQL será configurado.  
- O repositório será clonado na pasta definida pelo usuário.  
- Um arquivo `.env` será gerado no diretório do repositório.  
- A aplicação será compilada.  
- O PM2 será configurado para gerenciar a execução da aplicação.  

---

## 📂 Estrutura do Repositório

```plaintext
install-wuzapi/
├── install.sh         # Script principal do instalador
├── README.md          # Documentação do instalador

