#!/bin/bash
set -e

: ${DB_SERVIDOR:=$POSTGRES_PORT_5432_TCP_ADDR}
: ${DB_USUARIO:=${POSTGRES_ENV_POSTGRES_USER:-ecidade}}
: ${DB_SENHA:=${POSTGRES_ENV_POSTGRES_PASSWORD:-}}
: ${DB_PORTA:=${POSTGRES_PORT_5432_TCP_PORT:-5432}}
: ${DB_BASE:=${POSTGRES_ENV_POSTGRES_DB:=e-cidade}}

if [ -z "$DB_SERVIDOR" ]; then
  echo >&2 'erro: é necessário linkar um container de banco de dados postgresql ou setar a variável DB_SERVIDOR'
  exit 1
fi

echo 'Iniciando configuração do e-cidade'

echo 'Configurando apache.conf'
sed -i '67s/.*/Timeout 300/' /etc/apache2/apache2.conf

if [ "$(sed -n '238p' /etc/apache2/apache2.conf)" != "# linhas adicionadas para o e-cidade" ]; then
  echo '# linhas adicionadas para o e-cidade' >> /etc/apache2/apache2.conf
  echo 'LimitRequestLine       16382' >> /etc/apache2/apache2.conf
  echo 'LimitRequestFieldSize  16382' >> /etc/apache2/apache2.conf
  echo 'AddDefaultCharset ISO-8859-1' >> /etc/apache2/apache2.conf
fi

echo 'Configurando login.defs'
sed -i '151s/.*/UMASK		002/' /etc/login.defs

echo 'Configurando php.ini'
sed -i '704s/.*/register_globals = On/' /etc/php5/apache2/php.ini
sed -i '714s/.*/register_long_arrays = On/' /etc/php5/apache2/php.ini
sed -i '729s/.*/register_argc_argv = On/' /etc/php5/apache2/php.ini
sed -i '741s/.*/post_max_size = 64M/' /etc/php5/apache2/php.ini
sed -i '757s/.*/magic_quotes_gpc = On/' /etc/php5/apache2/php.ini
sed -i '892s/.*/upload_max_filesize = 64M/' /etc/php5/apache2/php.ini
sed -i '920s/.*/default_socket_timeout = 60000/' /etc/php5/apache2/php.ini
sed -i '444s/.*/max_execution_time = 60000/' /etc/php5/apache2/php.ini
sed -i '454s/.*/max_input_time = 60000/' /etc/php5/apache2/php.ini
sed -i '465s/.*/memory_limit = 512M/' /etc/php5/apache2/php.ini
sed -i '334s/.*/allow_call_time_pass_reference = On/' /etc/php5/apache2/php.ini
sed -i '538s/.*/display_errors = Off/' /etc/php5/apache2/php.ini
sed -i '559s/.*/log_errors = On/' /etc/php5/apache2/php.ini
sed -i '646s/.*/error_log = \/var\/www\/log\/php-scripts.log/' /etc/php5/apache2/php.ini
sed -i '1516s/.*/session.gc_maxlifetime = 7200/' /etc/php5/apache2/php.ini

# echo 'Configurando db_conn.php'
# sed -i "9s/.*/\$DB_USUARIO = \"$DB_USUARIO\";/" /var/www/e-cidade/libs/db_conn.php
# sed -i "10s/.*/\$DB_SENHA = \"$DB_SENHA\";/" /var/www/e-cidade/libs/db_conn.php
# sed -i "11s/.*/\$DB_SERVIDOR = \"$DB_SERVIDOR\";/" /var/www/e-cidade/libs/db_conn.php
# sed -i "12s/.*/\$DB_PORTA = \"$DB_PORTA\";/" /var/www/e-cidade/libs/db_conn.php
# sed -i "13s/.*/\$DB_PORTA_ALT = \"$DB_PORTA\";/" /var/www/e-cidade/libs/db_conn.php
# sed -i "14s/.*/\$DB_BASE = \"$DB_BASE\";/" /var/www/e-cidade/libs/db_conn.php

# echo 'Configurando plugins.json'
# if ! [ -e /var/www/e-cidade/config/plugins.json ]; then
#   mv /var/www/e-cidade/config/plugins.json.dist /var/www/e-cidade/config/plugins.json
# fi
   
# sed -i '4s/.*/"senha" : "plugin"/' /var/www/e-cidade/config/plugins.json

# echo 'Configurando require_extensions.xml'
# sed -i "62s/.*/<browser name='firefox' versao='44.*.*'><\/browser>/" /var/www/e-cidade/config/require_extensions.xml
# sed -i "63s/.*/<browser name='firefox' versao='45.*.*'><\/browser>/" /var/www/e-cidade/config/require_extensions.xml
# sed -i "64s/.*/<browser name='firefox' versao='46.*.*'><\/browser>/" /var/www/e-cidade/config/require_extensions.xml
# sed -i "65s/.*/<browser name='firefox' versao='47.*.*'><\/browser>/" /var/www/e-cidade/config/require_extensions.xml

echo 'Iniciando apache2'
source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
