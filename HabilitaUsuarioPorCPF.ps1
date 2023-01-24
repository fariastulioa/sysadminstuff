# Aqui deve ser inserido o path do dominio, checar se esta 'ufpe-teste' ou 'ufpe'
# Como o script visa reabilitar usuarios, basta buscar dentre os usuarios suspensos
$pathDominio = "OU=SUSPENSO,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br"

# O Powershell vai ler o CPF do usuario a suspender
$cpfSuspenso = Read-Host - Prompt 'Digite o CPF do suspenso/desabilitado para restaura-lo/habilita-lo: '
Write-Host "Exemplo de path de OU 'OU=CA,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br'"
$pathDestino = Read-Host - Prompt 'Digite o path da OU de destino para o usuario: '
# Exemplo de OU Destino: "OU=CA,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br"

# Cria uma string com o CPF, para o caso de a comparacao via objeto nao funcionar
$cpfString = {"$($cpfsuspenso)"}


# Armazena os usuarios AD com CPF correspondente
$usuariosAD = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties sAMAccountName | Where-Object {$_.sAMAccountName -eq $cpfString -or $_.sAMAccountName -in $cpfSuspenso})

# Inicializa variavel que conta quantos usuarios foram movidos
$nMovidos = 0


# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_logReabilitado.log"
Write-Host $name_logfile
$path_logfile = "C:\Users\Administrador\Desktop\teste de suspensos\$name_logfile"
Write-Host $path_logfile

# Itera sobre cada usuario encontrado
foreach ($usuario in $usuariosAD) {

    # Habilita a conta de usuario no Active Directory
    $usuario | Enable-ADAccount -Confirm
    Write-Host "Conta de usuario reabilitada"

    # Move o usuario no AD para o destino especificado
    Move-ADObject -Identity $usuario.distinguishedName -TargetPath $pathDestino
    $nMovidos += 1 # registra usuario movido para contagem
    Write-Host "Usuario $($usuario.displayName) movido para a $pathDestino"
    "Usuario $($usuario.displayName) movido para a $pathDestino" | Out-File -FilePath $path_logfile -Append
    # Registra o usuario no arquivo de log, na pasta atual
    $usuario | Out-File -FilePath $path_logfile -Append
}

$msg_final = "Mudanca completa. $nMovidos conta(s) movida(s) e reabilitada(s)."
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append