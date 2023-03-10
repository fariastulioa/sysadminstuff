# Armazena o path da pasta atual (onde se localiza o script)
$path_pasta = Get-Location

# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_logReabilitados.log"
$path_logfile = "$path_pasta\$name_logfile"

# Cria variaveis para armazenar os CPF como objeto e como string
$conteudo_csv = Import-Csv "$path_pasta\cpfs_reabilitar.csv"
$lista_cpfs = $conteudo_csv.CPF
$cpf_strings = $lista_cpfs | ForEach-Object {"$($_.CPF)"}


# Armazena o path do dominio, onde sera feita a busca por usuarios
$domain_path = "OU=SUSPENSO,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br"
# Como o script visa reabilitar usuarios, basta buscar dentre os usuarios suspensos

# Busca os usuarios cujo CPF corresponda a algum da lista e armazena-os em variavel
$usuarios_AD = (Get-ADUser -SearchBase $domain_path -Filter * -Properties mail, sAMAccountName, displayName | Where-Object {$_.sAMAccountName -in $lista_CPFs -or $_.sAMAccountName -in $cpf_strings})

# Armazena o path da OU onde seram postos os usuarios reabilitados
Write-Host "Exemplo de path de OU 'OU=CA,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br'"
$pathDestino = Read-Host - Prompt 'Digite o path da OU de destino para os usuarios: '
# Exemplo de OU Destino: "OU=CA,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br"


# Inicializa variavel que conta quantos usuarios foram movidos
$nMovidos = 0



# Itera sobre cada usuario encontrado
foreach ($usuario in $usuarios_AD) {

    # Registra o usuario no arquivo de log, na pasta atual
    $usuario | Out-File -FilePath $path_logfile -Append

    # Desabilita a conta de usuario no Active Directory
    $usuario | Disable-ADAccount
    $userCPF = $usuario.sAMAccountName
    # Registra a desabilitacao no log
    $msg_disable = "Usuario $userCPF desabilitado"
    $msg_disable | Out-File -FilePath $path_logfile -Append


    # Move o usuario no AD para o destino especificado
    $usuario | Move-ADObject -TargetPath $pathDestino
    $nMovidos += 1 # registra usuario movido para contagem
    # Registra a mudanca de OU para suspensos no log
    $msg_move = "Usuario $userCPF movido para a OU $pathDestino"
    $msg_move | Out-File -FilePath $path_logfile -Append
}

$msg_final = "Mudanca completa. $nMovidos contas movidas e resabilitadas."
# Ao finalizar a mudanca, exibe no console quantos usuarios foram reabilitados com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append
