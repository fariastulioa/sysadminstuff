# Muda o diretorio atual de trabalho para a pasta com os CSV, e onde serao salvos os arquivos de LOG
Set-Location -Path "C:\Users\gsuiteuser\Desktop\AjusteGrupos"

$dc = 'petinho.ufpe.br'

# Importa os emails dos egressos de um .csv para uma lista de objetos PS
$csv = Import-Csv ".\DriverConsumers.csv"

# Categorias da coluna ORGUNITPATH do arquivo .csv:
# array(['/Discentes', '/Egressos', '/Docentes', '/TecnicosAdm', '/PosLato', '/ResidentesTemp'], dtype=object)

# Inicializa listas de email (vazias) para cada categoria:
$discentes = New-Object System.Collections.Generic.List[System.Object]
$docentes = New-Object System.Collections.Generic.List[System.Object]
$egressos = New-Object System.Collections.Generic.List[System.Object]
$tecnicosadm = New-Object System.Collections.Generic.List[System.Object]
$poslato = New-Object System.Collections.Generic.List[System.Object]
$residentestemp = New-Object System.Collections.Generic.List[System.Object]


# Encaminha o CSV para um loop que itera sobre suas linhas
$csv | ForEach-Object {
    if ($_.ORGUNITPATH -eq "/Egressos") {
        # coloca o email na lista de egressos
        $egressos.Add($_.EMAIL)
    }
    elseif ($_.ORGUNITPATH -eq "/Discentes") {
        # coloca o email na lista de discentes
        $discentes.Add($_.EMAIL)
    }
    elseif ($_.ORGUNITPATH -eq "/Docentes") {
        # coloca o email na lista de docentes
        $docentes.Add($_.EMAIL)
    }
    elseif ($_.ORGUNITPATH -eq "/TecnicosAdm") {
        # coloca o email na lista de tecnicos
        $tecnicosadm.Add($_.EMAIL)
    }
    elseif ($_.ORGUNITPATH -eq "/PosLato") {
        # coloca o email na lista de tecnicos
        $poslato.Add($_.EMAIL)
    }
    elseif ($_.ORGUNITPATH -eq "/ResidentesTemp") {
        # coloca o email na lista de tecnicos
        $residentestemp.Add($_.EMAIL)
    }
}


# Para fins de debug, exibe no console quantos elementos tem cada lista
# Write-Host $discentes.Count
# Write-Host $egressos.Count
# Write-Host $tecnicosadm.Count
# Write-Host $residentestemp.Count
# Write-Host $docentes.Count
#$poslato



# Caso o PowerShell nao reconheca automaticamente os objetos EMAIL como string, fazer a conversao abaixo para todas as listas de email:
# $poslatoStrings = $poslato | ForEachObject {"$($_)"}
# Adicionar, tambem, ao Where-Object:
#  -or $_.mail -in $emailstrings

$poslatoStrings = $poslato | ForEach-Object {"$($_)"}
$discentesStrings = $discentes | ForEach-Object {"$($_)"}
$egressosStrings = $egressos | ForEach-Object {"$($_)"}
$docentesStrings = $docentes | ForEach-Object {"$($_)"}
$tecnicosadmStrings = $tecnicosadm | ForEach-Object {"$($_)"}
$residentestempStrings = $residentestemp | ForEach-Object {"$($_)"}

# Para fins de debug, exibe no console quantas strings de cada lista de strings
# Write-Host $discentesStrings.Count
# Write-Host $egressosStrings.Count
# Write-Host $tecnicosadmStrings.Count
# Write-Host $residentestempStrings.Count
# Write-Host $docentesStrings.Count
# $poslatoStrings

# Especifica em qual path sera feita a busca por usuarios
# O path deve ser fornecido no formato usual do AD
# Da OU mais especifica ate a mais geral
# A busca sera feita em todo o dominio especificado, nesse caso:
$pathDominio = "DC=ufpe,DC=br"

# Usa as listas de email geradas para buscar usuarios no AD
# Armazena o conjunto de usuarios de cada categoria em uma variavel
$usersDiscentes = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $discentes -or $_.mail -in $discentesStrings} | Select-Object mail, sAMAccountName)
$usersDocentes = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $docentes -or $_.mail -in $docentesStrings} | Select-Object mail, sAMAccountName)
$usersEgressos = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $egressos -or $_.mail -in $egressosStrings} | Select-Object mail, sAMAccountName)
$usersPosLato = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $poslato -or $_.mail -in $poslatoStrings} | Select-Object mail, sAMAccountName)
$usersTecnicosAdm = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $tecnicosadm -or $_.mail -in $tecnicosadmStrings} | Select-Object mail, sAMAccountName)
$usersResidentes = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $residentestemp -or $_.mail -in $residentestempStrings} | Select-Object mail, sAMAccountName)

# Para fins de debug, exibe no console quantos elementos ha em cada conjunto:
# Write-Host $usersDiscentes.Count
# Write-Host $usersEgressos.Count
# Write-Host $usersDocentes.Count
# Write-Host $usersTecnicosAdm.Count
# Write-Host $usersResidentes.Count
# Write-Host $usersPosLato.Count


# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_MudaGrupos.log"
$path_logfile = ".\$name_logfile"
Write-Host $path_logfile

$name_csv = $agora+"_movidos.csv"
$path_csv = ".\$name_csv"
Write-Host $path_csv
$header = "EMAIL,CPF,GRUPO"
$header | Out-File -FilePath $path_csv -Append

# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersDiscentes) {
    
    # Adiciona a membership correta ao usuario
    Add-ADGroupMember -Members $usuario.sAMAccountName -Identity ALUNO -Confirm:$false -Server $dc

    # Remove as memberships indevidas ou desatualizadas do usuaio
    Remove-ADGroupMember -Identity DOCENTE -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity EGRESSO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity TECNICO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity Residentes -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity POS-LATO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc

    $cpf = $usuario.sAMAccountName
    $email = $usuario.mail
    $grupo = "ALUNO"
    $linha_csv = "$cpf,$email,$grupo"
    $linha_csv | Out-File -FilePath $path_csv -Append

    $nAjustados += 1 # registra usuario movido para contagem
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: ALUNO"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append



# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersDocentes) {

    Add-ADGroupMember -Members $usuario.sAMAccountName -Identity DOCENTE -Confirm:$false -Server $dc

    
    Remove-ADGroupMember -Identity ALUNO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity EGRESSO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity TECNICO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity Residentes -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity POS-LATO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc


    $cpf = $usuario.sAMAccountName
    $email = $usuario.mail
    $grupo = "DOCENTE"
    $linha_csv = "$cpf,$email,$grupo"
    $linha_csv | Out-File -FilePath $path_csv -Append

    $nAjustados += 1 # registra usuario movido para contagem
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: DOCENTE"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersEgressos) {

    Add-ADGroupMember -Members $usuario.sAMAccountName -Identity EGRESSO -Confirm:$false -Server $dc


    Remove-ADGroupMember -Identity DOCENTE -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity ALUNO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity TECNICO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity Residentes -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity POS-LATO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc


    $cpf = $usuario.sAMAccountName
    $email = $usuario.mail
    $grupo = "EGRESSO"
    $linha_csv = "$cpf,$email,$grupo"
    $linha_csv | Out-File -FilePath $path_csv -Append

    $nAjustados += 1 # registra usuario movido para contagem
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: EGRESSO"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersTecnicosAdm) {

    Add-ADGroupMember -Members $usuario.sAMAccountName -Identity TECNICO -Confirm:$false -Server $dc


    Remove-ADGroupMember -Identity DOCENTE -Members $usuario.sAMAccountNam -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity EGRESSO -Members $usuario.sAMAccountNam -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity ALUNO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity Residentes -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity POS-LATO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc


    $cpf = $usuario.sAMAccountName
    $email = $usuario.mail
    $grupo = "TECNICO"
    $linha_csv = "$cpf,$email,$grupo"
    $linha_csv | Out-File -FilePath $path_csv -Append

    $nAjustados += 1 # registra usuario movido para contagem
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: TECNICO"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersResidentes) {

    Add-ADGroupMember -Members $usuario.sAMAccountName -Identity Residentes -Confirm:$false -Server $dc


    Remove-ADGroupMember -Identity DOCENTE -Members $usuario.sAMAccountNam -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity EGRESSO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity TECNICO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity ALUNO -Members $usuario.sAMAccountNam -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity POS-LATO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc


    $cpf = $usuario.sAMAccountName
    $email = $usuario.mail
    $grupo = "Residentes"
    $linha_csv = "$cpf,$email,$grupo"
    $linha_csv | Out-File -FilePath $path_csv -Append

    $nAjustados += 1 # registra usuario movido para contagem
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: Residentes"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append



# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersPosLato) {

    Add-ADGroupMember -Members $usuario.sAMAccountName -Identity POS-LATO -Confirm:$false -Server $dc


    Remove-ADGroupMember -Identity DOCENTE -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity EGRESSO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity TECNICO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity Residentes -Members $usuario.sAMAccountName -Confirm:$false -Server $dc
    Remove-ADGroupMember -Identity ALUNO -Members $usuario.sAMAccountName -Confirm:$false -Server $dc

    
    $cpf = $usuario.sAMAccountName
    $email = $usuario.mail
    $grupo = "POS-LATO"
    $linha_csv = "$cpf,$email,$grupo"
    $linha_csv | Out-File -FilePath $path_csv -Append

    $nAjustados += 1 # registra usuario movido para contagem
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: POS-LATO"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append

$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$script_end = "O Script terminou de executar em " + $agora
Write-Host $script_end
$script_end | Out-File -FilePath $path_logfile -Append