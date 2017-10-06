#!/bin/bash

#verificando se existe os arquivos na pasta
#novosLinks -> ao requisitar no pastebin.com/archive , irá obter novos links e é adicionado no arquivo como um histórico
#linksAcessados -> ao acessar os links requisitados do arquivo novosLinks, é adicionado no arquivo linksAcessados como um historico
if ! [ -e "novosLinks" ] && ! [ -e "linksAcessados" ]; then touch novosLinks; touch linksAcessados; fi
#verifica e cria uma pasta com os arquivos baixados
if ! [ -e "download_files" ]; then mkdir download_files; fi


#rm novosLinks linksAcessados 2>/dev/null > /dev/null


#extrai os links do site do pastebin.com/archive
extrai(){
	LINKS="null"
	LINKS="$(curl -L -s "http://pastebin.com/archive" | grep "i_p0" | cut -d"=" -f5 | cut -d'"' -f2 | tr -d "/")"
	for l in $LINKS; do
		r=$(grep "$l" novosLinks)
		if [ "$r" == "" ]; then echo $l >> novosLinks; fi
	done
}

#acessa os links do pastebin.com/archive e filtra usando grep os arquivos que contem um determinado REGEX
acessa(){
	GET_CONTENT="null"; VERIFICA_REGEX="null"
	for r in $1; do
		echo "$r" >> linksAcessados
		GET_CONTENT="$(curl -L -s "http://pastebin.com/raw/$r")"
		VERIFICA_REGEX="$(echo $GET_CONTENT | grep "$2")"
		if [ "$VERIFICA_REGEX" != "" ]; then
			echo $GET_CONTENT | gzip > $r.gz; echo "$r";
			mv $r.gz "download_files" 
		fi;
		sleep 2
	done
}


REGEX='"(?@terra\.)"'

#verificando se foi passado algum parametro na chamada do script, se não, coloca como padrão o REGEX definido na variavel REGEX
if [ "$1" == "" ]; then
	echo "[+] Usando REGEX padrão: $REGEX"; 
	echo "Se quiser usar uma diferente, faça $0 \"string\" "; 
	set -- $REGEX; 
else
	echo "[+] Usando REGEX como: $1";
fi

echo 
echo "[+] Monitorando \"$1\" em pastebin"
echo
while :; do
	extrai
	LINKS="$(diff novosLinks linksAcessados | cut -d" " -f2 | grep -v ",")"
	acessa "$LINKS" "$1"
	sleep 3
done


