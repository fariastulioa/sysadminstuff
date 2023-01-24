# Aqui deve ser insreido o path do dominio, checar se esta 'ufpe-teste' ou 'ufpe'
$pathDominio = "OU=ID,DC=ufpe-teste,DC=br"

# O Powershell vai ler o CPF do usuario a suspender
$cpfSuspenso = Read-Host - Prompt 'Digite o CPF do usuario a suspenser e desabilitar: '

# Cria uma string com o CPF, para o caso de a comparacao via objeto nao funcionar
$cpfString = {"$($cpfsuspenso)"}

# Aqui deve ser inserido o PATH de destino, atentar para o dominio DC=ufpe,DC=br ou DC=ufpe-teste,DC=br
$pathSuspensos = "OU=SUSPENSO,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br" 


# Armazena as contas AD com CPF correspondente
$usuariosAD = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties sAMAccountName | Where-Object {$_.sAMAccountName -eq $cpfString -or $_.sAMAccountName -in $cpfSuspenso})

# Inicializa variavel que conta quantos usuarios foram movidos
$nMovidos = 0

# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_logSuspenso.log"
Write-Host $name_logfile
$path_logfile = ".\$name_logfile"
Write-Host $path_logfile

# Itera sobre cada usuario encontrado
foreach ($usuario in $usuariosAD) {

    # Desabilita a conta de usuario no Active Directory
    $usuario | Disable-ADAccount
    Write-Host "Conta de usuario desabilitada"
    
    # Move o usuario no AD para o destino especificado
    $usuario | Move-ADObject -TargetPath $pathSuspensos
    $nMovidos += 1 # registra usuario movido para contagem
    Write-Host "Usuario $($usuario.displayName) movido a OU Suspensos"
    
    # Registra o usuario no arquivo de log, na pasta atual
    $usuario | Out-File -FilePath $path_logfile -Append
}

$msg_final = "Mudanca completa. $nMovidos contas movidas e desabilitadas."
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append
