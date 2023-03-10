# Script para BLOQUEAR usuarios em massa com base em EMAIL
# A lista de usuarios a bloquear deve ser fornecida via arquivo .csv
# O arquivo .csv deve conter uma coluna intitulada EMAIL (nome EMAIL no cabeçalho)
# Como output do script, gera-se um arquivo de log com lista de Emails e CPFs dos usuarios bloqueados

# Inicializa a lista de emails a buscar no AD (vazia)
$emails = New-Object System.Collections.Generic.List[System.Object]

# Muda o diretorio atual de trabalho
# Aqui deve ser fornecido o path onde está o .csv com a lista de usuarios
# Neste mesmo diretorio, sera salvo o arquivo de log
Set-Location -Path "C:\Users\gsuiteuser\Desktop\BloqueiaUsuarios"

# Importa os dados do csv para uma variavel
$csv = Import-Csv ".\users_to_block_emails.csv"

# Itera sobre as linhas do csv, adicionando o valor da coluna EMAIL na lista vazia gerada
$csv | ForEach-Object {
    $emails.Add($_.EMAIL)
}

# Forca a geracao de uma lista de strings com os emails, caso o PowerShell interprete os emails como objetos genericos
$emailStrings = $emails | ForEach-Object {"$($_)"}


# Path dos locais do AD onde serao buscados usuarios para se bloquear
$domain = "OU=ID,DC=ufpe,DC=br"
$legados = "OU=LEGADO,DC=ufpe,DC=br"

# Busca os usuarios por email no 1o local especificado em $domain
# A variavel gerada armazena os usuarios AD como objetos PowerShell
$usersToBlock = (Get-ADUser -SearchBase $domain -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $emails -or $_.mail -in $emailStrings})

# Gera o nome do arquivo de log, com base na hora atual
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_disabledUsers.log"
$path_logfile = ".\$name_logfile"
Write-Host $path_logfile

# Itera sobre oa usuarios encontrados e armazenados na variavel
foreach ($user in $usersToBlock) {

    # Bloqueia cada usuario
    Disable-ADAccount -Identity $user -Confirm:$false
    

    # As etapas a seguir tornam o script mais lento, por repetirem buscas por usuarios
    # Sao necessarias apenas caso se deseje bloquear tambem as contas do tipo LEGADO
    # (Alguns usuarios possuem contas tanto em ID.UFPE.BR quanto em LEGADO.UFPE.BR)
    # Caso o bloqueio de contas do tipo UFPE ID seja suficiente, comentar as linhas a seguir
    $mail = $user.mail
    Get-ADUser -SearchBase $legados -Filter * -Properties mail | Where-Object {$_.mail -eq $mail} | Disable-ADAccount
    $cpf = $user.sAMAccountName
    Get-ADUser -SearchBase $legados -Filter * -Properties mail | Where-Object {$_.sAMAccountName -eq $cpf} | Disable-ADAccount
}

# Adiciona o email e o CPF dos usuarios bloqueados no arquivo de log, apos a conclusao do bloqueio
$usersToBlock | Select-Object mail, sAMAccountName | Out-File -FilePath $path_logfile -Append