# Vers�o 1
# Script desenvolvido para buscar palavras-chave na listagem de m�quinas desejadas
# Ideal copiar os 3 arquivos onde ser� comandada a busca:
# searchFilename.ps1 -> script de execu��o da varredura
# computers.txt -> listagem de computadores onde deseja-se buscar as palavras-chave
# filenames.txt -> listagem de palavras que deseja-se buscar nos arquivos dos computadores

# Modo de uso:
# Copiar os 3 arquivos para um diret�rio da m�quina que ir� comandar a busca
# Executar um PowerShell como administrador (privil�gios elevados)
# Inserir dentro do "computers.txt" a listagem dos computadores que deseja-se realizar a busca (quebrando linha para cada computador)
# Inserir dentro do "filenames.txt" a listagem das palavras-chave que deseja-se buscar (quebrando linha para cada palabra)
# Na janela do Powershell, mudar o diret�rio at� chegar no diret�rio dos 3 arquivos
# Executar o script: > .\searchFilename.ps1
# A varredura ser� iniciada, alguns arquivos podem apresentar erro de acesso, pois est�o abertos pelo sistema, podendo ser desconsiderado
# Ser� criado um arquivo CSV para cada m�quina onde a varredura for executada, com a seguinte nomenclatura: "NOME_DA_MAQUINA-USUARIO_LOGADO-DATA_ATUAL.CSV"
# Os registros encontrados para a pesquisa estar�o nos arquivos CSVs

# Listagem com os computadores que quer executar a auditoria
$computers= get-content .\computers.txt
# Listagem dos nomes de arquivo que busca
$filenames= get-content .\filenames.txt

# Nome do dom�nio para remover do nome do arquivo
$replaceDomain= ""

# Hora atual
$datetime = "{0:yyyyMMdd-HHmmss}" -f (get-date)

# Folder: diret�rio � partir do C: que ser� realizada a busca. Deixa em branco para todos
$folder = ""

# Passar pelo array
foreach ($filename in $filenames) {
foreach ($computer in $computers) {
	$username = Get-WmiObject �ComputerName $computer �Class Win32_ComputerSystem | Select-Object UserName
	$username = $username.UserName -replace "$replaceDomain", ""
	
	"\\$computer\C$\$folder"|`
Get-ChildItem -recurse -filter "*$filename*" | Select Name, `
  @{ n = 'Folder'; e = { Convert-Path $_.PSParentPath } }, `
  @{ n = 'Foldername'; e = { ($_.PSPath -split '[\\]')[-2] } } ,
  @{ n = 'Fullname'; e = { Convert-Path $_.PSPath } } | export-csv -Append -Path ".\$computer-$username-$datetime.csv"}
}
