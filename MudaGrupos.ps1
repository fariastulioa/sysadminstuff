# Script to disable users

$emails = New-Object System.Collections.Generic.List[System.Object]

Set-Location -Path "C:\Users\gsuiteuser\Desktop\BloqueiaUsuarios"

$csv = Import-Csv ".\users_to_block_emails.csv"

$csv | ForEach-Object {
    $emails.Add($_.EMAIL)
}

$emailStrings = $emails | ForEach-Object {"$($_)"}

$domain = "OU=ID,DC=ufpe,DC=br"
$legados = "OU=LEGADO,DC=ufpe,DC=br"

$usersToBlock = (Get-ADUser -SearchBase $domain -Filter * -Properties mail, sAMAccountName | Where-Object {$_.mail -in $emails -or $_.mail -in $emailStrings})


$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_disabledUsers.log"
$path_logfile = ".\$name_logfile"
Write-Host $path_logfile


foreach ($user in $usersToBlock) {
    Disable-ADAccount -Identity $user -Confirm:$false
    $mail = $user.mail
    Get-ADUser -SearchBase $legados -Filter * -Properties mail | Where-Object {$_.mail -eq $mail} | Disable-ADAccount
    $cpf = $user.sAMAccountName
    Get-ADUser -SearchBase $legados -Filter * -Properties mail | Where-Object {$_.sAMAccountName -eq $cpf} | Disable-ADAccount
}

$usersToBlock | Select-Object mail, sAMAccountName | Out-File -FilePath $path_logfile -Append

