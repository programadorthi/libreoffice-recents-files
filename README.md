LibreOffice Unity Recents Files
=========================

Finalidade
-------------------------

Adicione os últimos arquivos abertos no LibreOffice no Ubuntu 14.04 ao launcher do Unity tendo assim um acesso rápido aos arquivos mais recentes

Como funciona
-------------------------

O script cria um arquivo chamado `office.desktop` na pasta `$HOME/.local/share/applications` e atualiza o mesmo a medida do necessário deixando os arquivos mais recentes na lista

Testes realizados
-------------------------

Os testes principais foram realizados no Ubuntu 14.04 com LibreOffice 4.2 pré-instalado onde ocorre tudo como o esperado. 

O outro foi no Ubuntu 12.04 com LibreOffice 3.5 pré-instalado onde a maioria das coisas funcionam. Exceto que pra atualizar a listagem no launcher é necessário realizar logout.

Requisitos pra rodar o script
-------------------------

1. O script faz leitura de arquivos xml e para isso foi utilizado o programa [XMLStarlet](http://xmlstar.sourceforge.net/). 
   Usuários Debian:

   ```bash
   sudo apt-get install xmlstarlet
   ```
2. O script precisa decodificar URL encoding de alguns caminhos. Pra esse caso foi utilizado a função `uri_unescape()` do módulo [URI::Escape](http://search.cpan.org/dist/URI/URI/Escape.pm) do Perl
   Usuários Debian:

   ```bash
   sudo perl -MCPAN -e shell
   ```
3. No shell do cpan `cpan>` digite:

   ```bash
    install URI::Escape
   ```
4. Demais configurações são feitas no próprio arquivo, caso você esteja usando a versão 3 do LibreOffice ou OpenOffice.

Passo a Passo
-------------------------

1. Baixe o arquivo e coloque ele no seu $HOME diretório ou coloque em um diretório específico pois ele será executado pelo sistema todas vez que você fizer login
2. Abra o terminal e execute o arquivo:

   ```bash
   ./officerecents.sh
   ```
3. Acesse o diretório:

   ```bash
   cd $HOME/.local/share/applications
   ```
4. Arraste o arquivo `office.desktop` para dash do Unity e pronto. Clique com o botão direito do mouse no ícone que apareceu e você verá os arquivos recentes e as opções padrão pra iniciar uma suite específica.

Observações e Limitações
-------------------------

- Uma vez executado `./officerecents.sh` o script será adicionado ao PATH do sistema. Agora basta digitar: `officerecents.sh` e dar enter;
- O Ubuntu 14.04 foi o alvo da criação desse script. Então, tenha em mente que, caso seja utilizado em outra versão, precisa realizar algumas alterações de configuração no script;
- Enquanto a utilização do LibreOffice for realizada utilizando o lançador personalizado criado, o mesmo sempre estará atualizado após o encerramento das atividades realizadas;
- A atualização da lista de arquivos recentes no lançador também é realizada ao fazer login em ambas as versões. Essa é a única forma encontrada de atualizar a listagem no Ubuntu 12.04 o que possivelmente seja um bug do Unity na versão;
- Caso realize alguma atividade no LibreOffice que não tenha sido iniciada pelo lançador personalizado, como clicar em um arquivo e pedir pra abrir, a mesma não aparecerá na listagem de recentes até que faça logout e depois login (pra ambas as versões) ou execute no terminal `officerecents.sh` (pra versão 14.04).

Dúvidas ou Recomendações
-------------------------

Se você tem alguma dúvida ou recomendação envie-me um email: `thiprogramador@hotmail.com` e coloque como assunto LibreOffice Unity Recents Files
