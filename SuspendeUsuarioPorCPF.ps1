# Este script habilita UM (1) unico usuario por execucao
# A cada execucao, ele recebe como input no proprio console um dado identificador do usuario a ser reabilitado
# Esse dado pode ser CPF ou EMAIL
# Uma vez informado o usuario, o script desbloqueia todas as contas associadas ao cpf/email informado
# e move as contas da OU "SUSPENSO" para uma OU de destino especificada tambem no console

# Aqui deve ser inserido o path do dominio, checar se esta 'ufpe-teste' ou 'ufpe'
$pathDominio = "OU=ID,DC=ufpe-teste,DC=br"

$tipoDado = Read-Host - Prompt 'Digite 1 para informar CPF ou 2 para informar EMAIL de usuario para reabilitar'


if ($tipoDado -eq 1) {
    # Selecionar um CPF

    # O Powershell vai ler o CPF do usuario a suspender
    $cpfSuspenso = Read-Host - Prompt 'Digite o CPF do suspenso/desabilitado para restaura-lo/habilita-lo: '

    # Cria uma string com o CPF, para o caso de a comparacao via objeto nao funcionar
    $cpfString = {"$($cpfsuspenso)"}

    # Armazena os usuarios AD com cpf correspondente
    $usuariosAD = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties sAMAccountName | Where-Object {$_.sAMAccountName -eq $cpfString -or $_.sAMAccountName -in $cpfSuspenso})

} elseif ($tipoDado -eq 2) {
    # Selecionar um EMAIL

    # O Powershell vai ler o EMAIL do usuario a suspender
    $emailSuspenso = Read-Host - Prompt 'Digite o CPF do suspenso/desabilitado para restaura-lo/habilita-lo: '
    
    # Cria uma string com o EMAIL, para o caso de a comparacao via objeto nao funcionar
    $emailString = {"$($emailSuspenso)"}

    # Armazena os usuarios AD com email correspondente
    $usuariosAD = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties sAMAccountName | Where-Object {$_.sAMAccountName -eq $emailString -or $_.sAMAccountName -in $emailSuspenso})
    }
else {
    Write-Host "Escolha invalida"
    Exit
}

# Define o path de destino, uma OU especifica para usuarios suspensos
$pathSuspensos = "OU=SUSPENSO,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br" 


# Inicializa variavel que conta quantos usuarios foram movidos
$nMovidos = 0


# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_logReabilitado.log"
Write-Host $name_logfile
# O path para salvar o arquivo de log pode ser ajustado aqui:
$path_logfile = "C:\Users\Administrador\Desktop\teste de suspensos\$name_logfile"
Write-Host $path_logfile

# Itera sobre cada usuario encontrado
foreach ($usuario in $usuariosAD) {

    # Habilita a conta de usuario no Active Directory
    $usuario | Disable-ADAccount -Confirm
    Write-Host "Conta de usuario desabilitada"

    # Move o usuario no AD para o destino especificado
    Move-ADObject -Identity $usuario.distinguishedName -TargetPath $pathSuspensos
    $nMovidos += 1 # registra usuario movido para contagem

    "Usuario $($usuario.displayName) movido para a OU de suspensos" | Out-File -FilePath $path_logfile -Append
    # Registra o usuario no arquivo de log, na pasta atual
    $usuario | Out-File -FilePath $path_logfile -Append
}

$msg_final = "Mudanca completa. $nMovidos conta(s) movida(s) e desabilitada(s)."
# Ao finalizar a mudanca, exibe quantas contas AD foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append