$usersTecnicosAdm = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $tecnicosadm -or $_.mail -in $tecnicosadmStrings} | Select-Object mail, sAMAccountName)
$usersResidentes = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $residentestemp -or $_.mail -in $residentestempStrings} | Select-Object mail, sAMAccountName)

# Para fins de debug, exibe no console quantos elementos ha em cada conjunto:
Write-Host $usersDiscentes.Count
Write-Host $usersEgressos.Count
Write-Host $usersDocentes.Count
Write-Host $usersTecnicosAdm.Count
Write-Host $usersResidentes.Count
Write-Host $usersPosLato.Count


# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_MudaGrupos.log"
Write-Host $name_logfile
$path_logfile = ".\$name_logfile"
Write-Host $path_logfile


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersDiscentes) {
    
    # Adiciona a membership correta ao usuario
    Add-ADGroupMember -Identity $pathDiscentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false

    # Remove as memberships indevidas ou desatualizadas do usuaio
    Remove-ADGroupMember -Identity $pathDocentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathEgressos -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathTecnicosAdm -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathResidentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathPosLato -Members $usuario.sAMAccountName -Verbose -Confirm:$false


    $nAjustados += 1 # registra usuario movido para contagem
    $msg_ajuste = "$usuario movido para o GRUPO: DISCENTES, removido dos demais grupos de vinculo"
    $msg_ajuste | Write-Host 
    $msg_ajuste | Out-File -FilePath $path_logfile -Append # registra pra qual grupo o usuario foi movido
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: $pathDiscentes"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append



# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersDocentes) {

    Add-ADGroupMember -Identity $pathDocentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false

    
    Remove-ADGroupMember -Identity $pathDiscentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathEgressos -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathTecnicosAdm -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathResidentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathPosLato -Members $usuario.sAMAccountName -Verbose -Confirm:$false


    $nAjustados += 1 # registra usuario movido para contagem
    $msg_ajuste = "$usuario movido para o GRUPO: DOCENTES, removido dos demais grupos de vinculo"
    $msg_ajuste | Write-Host 
    $msg_ajuste | Out-File -FilePath $path_logfile -Append # registra pra qual grupo o usuario foi movido
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: $pathDocentes"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersEgressos) {

    Add-ADGroupMember -Identity $pathEgressos -Members $usuario.sAMAccountName -Verbose -Confirm:$false


    Remove-ADGroupMember -Identity $pathDocentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathDiscentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathTecnicosAdm -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathResidentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathPosLato -Members $usuario.sAMAccountName -Verbose -Confirm:$false


    $nAjustados += 1 # registra usuario movido para contagem
    $msg_ajuste = "$usuario movido para o GRUPO: EGRESSOS, removido dos demais grupos de vinculo"
    $msg_ajuste | Write-Host 
    $msg_ajuste | Out-File -FilePath $path_logfile -Append # registra pra qual grupo o usuario foi movido
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: $pathEgressos"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersTecnicosAdm) {

    Add-ADGroupMember -Identity $pathTecnicosAdm -Members.sAMAccountName $usuario -Verbose -Confirm:$false


    Remove-ADGroupMember -Identity $pathDocentes -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathEgressos -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathDiscentes -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathResidentes -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathPosLato -Members.sAMAccountName $usuario -Verbose -Confirm:$false


    $nAjustados += 1 # registra usuario movido para contagem
    $msg_ajuste = "$usuario movido para o GRUPO: TECNICOS, removido dos demais grupos de vinculo"
    $msg_ajuste | Write-Host 
    $msg_ajuste | Out-File -FilePath $path_logfile -Append # registra pra qual grupo o usuario foi movido
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: $pathTecnicosAdm"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append


# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersResidentes) {

    Add-ADGroupMember -Identity $pathResidentes -Members.sAMAccountName $usuario -Verbose -Confirm:$false


    Remove-ADGroupMember -Identity $pathDocentes -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathEgressos -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathTecnicosAdm -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathDiscentes -Members.sAMAccountName $usuario -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathPosLato -Members.sAMAccountName $usuario -Verbose -Confirm:$false


    $nAjustados += 1 # registra usuario movido para contagem
    $msg_ajuste = "$usuario movido para o GRUPO: RESIDENTES, removido dos demais grupos de vinculo"
    $msg_ajuste | Write-Host 
    $msg_ajuste | Out-File -FilePath $path_logfile -Append # registra pra qual grupo o usuario foi movido
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: $pathResidentes"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append



# Inicializa variavel que conta quantos usuarios foram ajustados
$nAjustados = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usersPosLato) {

    Add-ADGroupMember -Identity $pathPosLato -Members $usuario.sAMAccountName -Verbose -Confirm:$false


    Remove-ADGroupMember -Identity $pathDocentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathEgressos -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathTecnicosAdm -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathResidentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false
    Remove-ADGroupMember -Identity $pathDiscentes -Members $usuario.sAMAccountName -Verbose -Confirm:$false


    $nAjustados += 1 # registra usuario movido para contagem
    $msg_ajuste = "$usuario movido para o GRUPO: POS-LATO, removido dos demais grupos de vinculo"
    $msg_ajuste | Write-Host 
    $msg_ajuste | Out-File -FilePath $path_logfile -Append # registra pra qual grupo o usuario foi movido
}

$msg_final = "Ajuste Realizado. $nAjustados contas movidas para o grupo: $pathPosLato"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append