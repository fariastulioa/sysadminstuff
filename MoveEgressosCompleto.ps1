# A primeira parte desse Script busca usuarios no AD por seus CPFs
# A busca e feita por email
# Os emails devem ser fornecidos em um arquivo .csv
# O arquivo .csv deve conter os emails em uma coluna chamada primaryEmail
# Os CPFs dos usuarios sao exportados para um arquivo .csv


# Importa os emails dos egressos de um .csv para uma lista de objetos PS
$lista_emails = Import-Csv ".\emails_egressos.csv"
$emails = $lista_emails.primaryEmail

# Converte a lista de objetos PS em lista de strings (para caso a comparacao com objetos nao funcione)
$emailstrings = $lista_emails | ForEach-Object {"$($_.primaryEmail)"} # converte cada email em string

# Especifica em qual path sera feita a busca por egressos
# O path deve ser fornecido no formato usual do AD
# Da OU mais especifica ate a mais geral
# A busca sera feita em todo o dominio especificado
$pathDominio = "OU=ID,DC=ufpe-teste,DC=br"

# Procura no path fornecido por objetos AD
# nos quais o atributo mail
# esta na lista de emails importada do .csv
Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail, sAMAccountName  | Where-Object {$_.mail -in $emails -or $_.mail -in $emailstrings} | Select-Object mail, sAMAccountName | Export-Csv ".\egressos_com_cpf.csv" -NoTypeInformation
# Seleciona apenas o email e o cpf de cada objeto
# exporta para um novo arquivo csv



# SEGUNDA PARTE: MOVENDO USUARIOS

# Esse script move usuarios para a OU Egressos
# O script busca usuarios por CPF para move-los
# Os CPFs devem ser fornecidos em um arquivo .csv (cpfs.csv) na pasta onde será executado o script
# O arquivo .csv deve ter uma coluna nomeada sAMAccountName
# A coluna sAMAccountName deve conter os CPFs dos usuarios a mover


# Cria um objeto lista PowerShell com os CPFs
$cpflista = Import-Csv ".\cpfs.csv"
$CPFs = $cpflista.sAMAccountName

# Cria uma lista de strings com os CPFs, para o caso de a comparacao via objeto nao funcionar
$CPFstrings = $CPFs | ForEach-Object {"$($_.sAMAccountName)"}

# Deve-se se indicar a OU de destino na variavel $pathDestino
$pathDestino = "OU=EGRESSOS,OU=CENTRO,OU=ID,DC=ufpe-teste,DC=br" # aqui deve ser inserido o PATH (padrao AD) da OU de destino


# Armazena os usuarios AD que tiverem seus CPFs contidos na lista fornecida em um objeto PowerShell
$usuariosAD = (Get-ADUser -SearchBase $pathDominio -Filter * -Properties mail | Where-Object {$_.sAMAccountName -in $CPFs -or $_.sAMAccountName -in $CPFstrings})


# Gera nome e path para arquivo de log com base na data/hora autal
$agora = Get-Date -Format "yyyy-MM-dd-hh-mm"
$name_logfile = $agora+"_logSuspenso.log"
Write-Host $name_logfile
$path_logfile = ".\$name_logfile"
Write-Host $path_logfile


# Inicializa variavel que conta quantos usuarios foram movidos
$nMovidos = 0
# Itera sobre cada usuario encontrado
foreach ($usuario in $usuariosAD) {
    # Move o usuario no AD para o destino especificado
    Move-ADObject $usuario -TargetPath $pathDestino # move o usuario para a OU de destino especificada
    $nMovidos += 1 # registra usuario movido para contagem
    $usuario | Out-File -FilePath $path_logfile -Append # registra o usuario movido no log
}


$msg_final = "Mudanca completa. $nMovidos contas movidas para a OU $pathDestino"
# Ao finalizar a mudanca, exibe quantos usuarios foram movidos com sucesso e registra no log
Write-Host $msg_final
$msg_final | Out-File -FilePath $path_logfile -Append