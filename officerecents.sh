#!/bin/bash

# LibreOffice Unity Recents Files
# Author: Thiago
# 
# Copyright (c) 2014 Thiago Santos <thiprogramador@hotmail.com>
#
# Esse script tem como finalidade criar um lancador do libreoffice
# no Unity que mostre, ao clicar com o botao direito do mouse, 
# os ultimos arquivos abertos fazendo com que sejam reabertos
# rapidamente
#

# Diretorio onde sera criado o .desktop
LOCAL_DIR="$HOME/.local/share/applications"

# A quantidade de arquivos recentes a ser listado no launcher
QTD_FILES=10

# O nome do arquivo que ira pro lancador
FILE_NAME="$LOCAL_DIR/office.desktop"

# Diretorio onde fica as configuracoes
# Se o seu libreoffice for a versao 3, mude o 4 por 3
CONFIG_FILE="$HOME/.config/libreoffice/4/user/registrymodifications.xcu"

# Acoes padrao
ACTIONS="Separator;Writer;Calc;Impress;Draw;Base;Math;"

# O comprimento padrao do separador
separator_length=20

# Array que guarda os arquivos recentes encontrados
array=()

# Variavel que guarda o xml versao modificada
tmp_file='/tmp/temp.xml'

# Verifica se o diretorio nao existe
if [ ! -d $LOCAL_DIR ]; then
    # Cria o diretorio recursivo
    mkdir -p $LOCAL_DIR
fi

# Verifica se o arquivo de perfil do libreoffice nao existe
if [ ! -e $CONFIG_FILE ]; then
    echo "Arquivo registrymodifications.xcu nao encontrado!"
    exit 1;
fi

# Funcao que verifica se o arquivo recente ainda esta no mesmo local no disco
exists_file()
{
    # Remove os caracteres URL encoding e o protocolo file://
    teste=$(perl -MURI::Escape -e 'print uri_unescape($ARGV[0]);' "$1" | sed -e 's/file:\/\///')

    # Verifica se o arquivo existe em disco
    if [ -e "$teste" ]; then
        return 1;
    fi

    return 0;
}

# Realizando umas modificacoes pessoais e jogando no temp.xml
sed -e "s/\/org\.openoffice\.Office\.Histories\/Histories\/org\.openoffice\.Office\.Histories\:HistoryInfo\['PickList'\]\/OrderList/OrderList/g" -e "s/\/org\.openoffice\.Office\.Histories\/Histories\/org\.openoffice\.Office\.Histories\:HistoryInfo\['PickList'\]\/ItemList/ItemList/g" $CONFIG_FILE > $tmp_file

# loop para pegar os arquivos mais recentes
i=0;
j=0;
while [ $i -lt $QTD_FILES ] 
do
    # Pegando do historico por ordem
    rec_file=$(exec xmlstarlet sel -t -v "//item[@oor:path='OrderList']/node[@oor:name=$j]" $tmp_file)
    
    # Verifica se achou o arquivo recente no historico
    if [ ${#rec_file} -gt 0 ]; then

        # Verifica a localizacao do arquivo no disco
        exists_file $rec_file

        # Verifica o retorno da funcao. 1 pra existe e 0 pra nao encontrado
        if [ $? -eq 1 ]; then

            # Armazena no array o arquivo
            array[$i]="$rec_file"

            # Incrementa o i
            i=$(( $i + 1));
        fi

        # Sempre incrementa o j, pois se nao achou o arquivo no disco, pega o proximo do historico
        j=$(( $j + 1));
    else
        # Termina o loop
        i=10
    fi
done

# Cria o .desktop com valores padrao
cat - > "$FILE_NAME" <<EOF

[Desktop Entry]
Version=1.0
Terminal=false
Icon=libreoffice-startcenter
Type=Application
Categories=Office;X-Red-Hat-Base;X-SuSE-Core-Office;X-MandrivaLinux-Office-Other;
Exec=sh -c "libreoffice %U ; officerecents.sh"
MimeType=application/vnd.openofficeorg.extension;
Name=LibreOffice Recents

EOF

# Verifica se existem arquivos recentes
if [ ${#array[@]} -gt 0 ]; then

    # Percorre o array pra criar as acoes em ordem crescente
    for ((i = $((${#array[@]} - 1)) ; i >= 0 ; i--)); do
        # Adicionando uma nova acao
        ACTIONS="acao${i};${ACTIONS}"
    done 

    # Escreve as acoes no arquivo .desktop
    echo "Actions=${ACTIONS}" >> $FILE_NAME

    # Percorre o array em busca dos nomes dos arquivos
    i=0
    while [ $i -lt ${#array[@]} ]; do

        # Obtem o titulo do arquivo
        title=$(exec xmlstarlet sel -t -v "//item[@oor:path='ItemList']/node[@oor:name='"${array[$i]}"']/prop[@oor:name='Title']/value" $tmp_file)

# Adiciona uma acao pro arquivo no .desktop
cat << EOF >> $FILE_NAME

[Desktop Action acao${i}]
Name=$title
Exec=sh -c "libreoffice -o '$(perl -MURI::Escape -e 'print uri_unescape($ARGV[0]);' "${array[$i]}")' ; officerecents.sh"
OnlyShowIn=Unity;

EOF

        # Verifica se o tamanho do titulo e maior que o tamanho do separador
        if [ ${#title} -gt $separator_length ]; then
            # Deixar o separador do tamanho do maior titulo
            separator_length=${#title}
        fi

        # Incrementa o i
        i=$(( $i + 1));
    done
else
    # Escreve as acoes padrao no arquivo .desktop
    echo "Actions=${ACTIONS}" >> $FILE_NAME
fi

# Cria o separador com base no tamanho definido
separador=$(perl -E "say '=' x $separator_length")

# Adiciona o separador e as acoes padrao no .desktop
cat << EOF >> $FILE_NAME

[Desktop Action Separator]
Name=$separador
OnlyShowIn=Unity;

[Desktop Action Writer]
Name=Writer
Exec=sh -c "libreoffice --writer ; officerecents.sh"
OnlyShowIn=Unity;

[Desktop Action Calc]
Name=Calc
Exec=sh -c "libreoffice --calc ; officerecents.sh"
OnlyShowIn=Unity;

[Desktop Action Impress]
Name=Impress
Exec=sh -c "libreoffice --impress ; officerecents.sh"
OnlyShowIn=Unity;

[Desktop Action Draw]
Name=Drawing
Exec=sh -c "libreoffice --draw ; officerecents.sh"
OnlyShowIn=Unity;

[Desktop Action Base]
Name=Database
Exec=sh -c "libreoffice --base ; officerecents.sh"
OnlyShowIn=Unity;

[Desktop Action Math]
Name=Math
Exec=sh -c "libreoffice --math ; officerecents.sh"
OnlyShowIn=Unity;

EOF

# Deixar-me acessivel, ou seja, chamar-me como qualquer outro programa
if [ $(grep 'officerecents.sh' $HOME/.profile | wc -l) -lt 1 ]; then
    echo "" >> $HOME/.profile
    echo 'export PATH=$PATH:'$(pwd) >> $HOME/.profile
    echo "" >> $HOME/.profile
    echo '#Executar apos o login' >> $HOME/.profile
    echo '[ $(which officerecents.sh) ] && officerecents.sh' >> $HOME/.profile
    echo ""
    echo "Acesse a pasta $HOME/.local/share/applications e arraste o office.desktop para o Unity dash"
    echo ""
    echo "Agora, faça logout para deixar tudo no automático!"
fi
