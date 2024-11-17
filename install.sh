#!/bin/bash

# Estilização do terminal com cores ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
NC='\033[0m' # Sem cor

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para entrada obrigatória do usuário
get_input() {
    local prompt=$1
    local input=""
    while [[ -z "$input" ]]; do
        read -p "$(echo -e "${YELLOW}$prompt${NC}: ")" input
        if [[ -z "$input" ]]; then
            echo -e "${RED}Esse campo é obrigatório. Por favor, preencha.${NC}"
        fi
    done
    echo "$input"
}

# Cabeçalho do instalador
show_header() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${CYAN}                ${WHITE}WebTech Installer${CYAN}                 ${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# Exibe uma seção com título
show_section() {
    clear
    show_header
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

# Início da instalação
show_section "Início da Configuração"

# Atualizar sistema e instalar dependências básicas
show_section "Atualizando sistema e instalando dependências"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl wget build-essential git

# Verificar e instalar Node.js e npm
show_section "Instalando Node.js e npm"
if ! command_exists node; then
    sudo apt install -y nodejs npm
else
    echo -e "${GREEN}Node.js já está instalado.${NC}"
fi

# Verificar e instalar PM2
show_section "Instalando PM2"
if ! command_exists pm2; then
    sudo npm install -g pm2
else
    echo -e "${GREEN}PM2 já está instalado.${NC}"
fi

# Verificar e instalar Go
show_section "Instalando Go"
if ! command_exists go; then
    GO_VERSION="1.23.3"
    wget -q https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
    rm go$GO_VERSION.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin

    if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
    fi
    source ~/.bashrc
else
    echo -e "${GREEN}Go já está instalado.${NC}"
fi

# Verificar e instalar PostgreSQL
show_section "Instalando PostgreSQL"
if ! command_exists psql; then
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
else
    echo -e "${GREEN}PostgreSQL já está instalado.${NC}"
fi

# Configurar PostgreSQL
show_section "Configurando PostgreSQL"
DB_USER=$(get_input "Digite o nome do usuário do banco de dados (exemplo: wuzapi)")
DB_PASSWORD=$(get_input "Digite a senha para o usuário do banco de dados (exemplo: senha123)")
DB_NAME=$(get_input "Digite o nome do banco de dados (exemplo: wuzapidb)")

sudo -u postgres psql <<EOF
DO
\$do\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
      CREATE ROLE "$DB_USER" LOGIN PASSWORD '$DB_PASSWORD';
   END IF;
END
\$do\$;

CREATE DATABASE "$DB_NAME" OWNER "$DB_USER";
EOF

# Perguntar ao usuário pela porta da aplicação
APP_PORT=$(get_input "Escolha a porta para a aplicação (exemplo: 8080)")

# Perguntar ao usuário pelo nome do processo no PM2
PM2_NAME=$(get_input "Escolha o nome para o processo no PM2 (exemplo: wuzapi)")

# Gerar o token de administrador
WUZAPI_ADMIN_TOKEN=$(get_input "Digite o token de administrador para o WUZAPI (exemplo: ABCD1234)")

# Clonar o repositório
show_section "Clonando o repositório"
mkdir -p $DB_USER
cd $DB_USER
if [ ! -d "./wuzapi" ]; then
    git clone https://github.com/guilhermejansen/wuzapi.git
else
    echo -e "${GREEN}Repositório já clonado. Atualizando...${NC}"
    cd wuzapi
    git pull
    cd ..
fi

# Entrar no diretório do repositório
cd wuzapi || exit

# Configurar o arquivo .env
show_section "Configurando arquivo .env"
cat > .env <<EOL
WUZAPI_ADMIN_TOKEN=$WUZAPI_ADMIN_TOKEN
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
DB_HOST=localhost
DB_PORT=5432
PORT=$APP_PORT
EOL

echo -e "${GREEN}Arquivo .env criado com sucesso:${NC}"
cat .env

# Compilar a aplicação
show_section "Compilando a aplicação"
go build .

# Configurar PM2
show_section "Configurando PM2"
pm2 start "./wuzapi -port $APP_PORT" --name "$PM2_NAME"

# Garantir que o PM2 reinicie no boot
show_section "Configurando PM2 para reiniciar no boot"
pm2 startup
pm2 save

# Finalização
show_section "Instalação concluída!"
echo -e "${GREEN}Use 'pm2 list' para verificar o status da aplicação.${NC}"
echo -e "${GREEN}A aplicação está rodando na porta ${CYAN}$APP_PORT${NC} com o nome '${CYAN}$PM2_NAME${NC}' no PM2.${NC}"
echo -e "${CYAN}Token de administrador:${NC} ${GREEN}$WUZAPI_ADMIN_TOKEN${NC}"