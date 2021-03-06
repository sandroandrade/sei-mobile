#!/bin/bash

# Fill up sessionid.jar with a valid PHPIDSESSION

# SEI Login
curl -s -L -X POST 'https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA&sigla_sistema=SEI' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Connection: keep-alive' \
  -H 'Upgrade-Insecure-Requests: 1' \
  --compressed \
  --data "txtUsuario=$SEI_USER&pwdSenha=$SEI_PASSWORD&selOrgao=0&sbmLogin=Acessar&hdnIdSistema=100000100&hdnSiglaSistema=SEI&hdnModuloSistema=&hdnMenuSistema=&hdnSiglaOrgaoSistema=IFBA" \
  -b sessionid.jar | xidel - --extract //title

# ECDU.SSA
curl -s -L -X POST 'https://sei.ifba.edu.br/sei/inicializar.php' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Connection: keep-alive' \
  -H 'Upgrade-Insecure-Requests: 1' \
  --compressed \
  --data 'selInfraUnidades=110001340' \
  -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a' | wc -l

# PPGESP.SSA
curl -s -L -X POST 'https://sei.ifba.edu.br/sei/inicializar.php' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Connection: keep-alive' \
  -H 'Upgrade-Insecure-Requests: 1' \
  --compressed \
  --data 'selInfraUnidades=110001755' \
  -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a' | wc -l

# DACOMP.SSA
curl -s -L -X POST 'https://sei.ifba.edu.br/sei/inicializar.php' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Connection: keep-alive' \
  -H 'Upgrade-Insecure-Requests: 1' \
  --compressed \
  --data 'selInfraUnidades=110001297' \
  -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a' | wc -l

# Change mode to MyProcesses (DACOMP.SSA)
curl -s 'https://sei.ifba.edu.br/sei/controlador.php?acao=procedimento_controlar&acao_origem=procedimento_controlar&infra_sistema=100000100&infra_unidade_atual=110001297&infra_hash=afeca0c5b546d9b6a6027aeaaf41057ace8cfe92640f8f7ef2038dc65d84bf91' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' 'Upgrade-Insecure-Requests: 1' --data 'hdnMeusProcessos=M' \
 -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a'
 
# My process at ECDU.SSA
curl -s -L 'https://sei.ifba.edu.br/sei/inicializar.php?infra_sistema=100000100&infra_unidade_atual=110001297&infra_hash=76659a2a1356fcdd829a0c08f6990683a8c191b3711536bccebb365932fbe345bbaf56914b243a789cba84fef29db71d973fe696d58060ff22f96d6724e5dbc3f4a05117ecaaf580848518f239d24dfe58428dabeff6fbdeade7c1bf56ad976a' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data 'selInfraUnidades=110001340' \
 -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a'

# Move back to initial unity (DACOMP.SSA)
curl -s -L 'https://sei.ifba.edu.br/sei/inicializar.php?infra_sistema=100000100&infra_unidade_atual=110001340&infra_hash=a57281d01e42d183dd8a0fa896680f950c1a6494c2014df71213b3a042c797d6bbaf56914b243a789cba84fef29db71d973fe696d58060ff22f96d6724e5dbc3f4a05117ecaaf580848518f239d24dfe58428dabeff6fbdeade7c1bf56ad976a' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data 'selInfraUnidades=110001297' -b sessionid.jar -o /dev/null

# Change mode to AllProcesses (DACOMP.SSA)
curl -s 'https://sei.ifba.edu.br/sei/controlador.php?acao=procedimento_controlar&acao_origem=procedimento_controlar&infra_sistema=100000100&infra_unidade_atual=110001297&infra_hash=6296a378bf0a6402a138f1e3537e7bffb83265217e1d735762b0c057184eb799' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data 'hdnMeusProcessos=T' \
 -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a' | wc -l
 
 # All process at ECDU.SSA
curl -s -L 'https://sei.ifba.edu.br/sei/inicializar.php?infra_sistema=100000100&infra_unidade_atual=110001297&infra_hash=76659a2a1356fcdd829a0c08f6990683a8c191b3711536bccebb365932fbe345bbaf56914b243a789cba84fef29db71d973fe696d58060ff22f96d6724e5dbc3f4a05117ecaaf580848518f239d24dfe58428dabeff6fbdeade7c1bf56ad976a' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data 'selInfraUnidades=110001340' \
 -b sessionid.jar | xidel - --extract '//*[@id="tblProcessosRecebidos"]/tbody/tr/td[3]/a' | wc -l

# Move back to initial unity (DACOMP.SSA)
curl -s -L 'https://sei.ifba.edu.br/sei/inicializar.php?infra_sistema=100000100&infra_unidade_atual=110001340&infra_hash=a57281d01e42d183dd8a0fa896680f950c1a6494c2014df71213b3a042c797d6bbaf56914b243a789cba84fef29db71d973fe696d58060ff22f96d6724e5dbc3f4a05117ecaaf580848518f239d24dfe58428dabeff6fbdeade7c1bf56ad976a' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data 'selInfraUnidades=110001297' -b sessionid.jar -o /dev/null
