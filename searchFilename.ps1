# Versão 1
# Script desenvolvido para buscar palavras-chave na listagem de máquinas desejadas
# Ideal copiar os 3 arquivos onde será comandada a busca:
# searchFilename.ps1 -> script de execução da varredura
# computers.txt -> listagem de computadores onde deseja-se buscar as palavras-chave
# filenames.txt -> listagem de palavras que deseja-se buscar nos arquivos dos computadores

# Modo de uso:
# Copiar os 3 arquivos para um diretório da máquina que irá comandar a busca
# Executar um PowerShell como administrador (privilégios elevados)
# Inserir dentro do "computers.txt" a listagem dos computadores que deseja-se realizar a busca (quebrando linha para cada computador)
# Inserir dentro do "filenames.txt" a listagem das palavras-chave que deseja-se buscar (quebrando linha para cada palabra)
# Na janela do Powershell, mudar o diretório até chegar no diretório dos 3 arquivos
# Executar o script: > .\searchFilename.ps1
# A varredura será iniciada, alguns arquivos podem apresentar erro de acesso, pois estão abertos pelo sistema, podendo ser desconsiderado
# Será criado um arquivo CSV para cada máquina onde a varredura for executada, com a seguinte nomenclatura: "NOME_DA_MAQUINA-USUARIO_LOGADO-DATA_ATUAL.CSV"
# Os registros encontrados para a pesquisa estarão nos arquivos CSVs

# Listagem com os computadores que quer executar a auditoria
$computers= get-content .\computers.txt
# Listagem dos nomes de arquivo que busca
$filenames= get-content .\filenames.txt

# Nome do domínio para remover do nome do arquivo
$replaceDomain= ""

# Hora atual
$datetime = "{0:yyyyMMdd-HHmmss}" -f (get-date)

# Folder: diretório à partir do C: que será realizada a busca. Deixa em branco para todos
$folder = ""

# Passar pelo array
foreach ($filename in $filenames) {
foreach ($computer in $computers) {
	$username = Get-WmiObject –ComputerName $computer –Class Win32_ComputerSystem | Select-Object UserName
	$username = $username.UserName -replace "$replaceDomain", ""
	
	"\\$computer\C$\$folder"|`
Get-ChildItem -recurse -filter "*$filename*" | Select Name, `
  @{ n = 'Folder'; e = { Convert-Path $_.PSParentPath } }, `
  @{ n = 'Foldername'; e = { ($_.PSPath -split '[\\]')[-2] } } ,
  @{ n = 'Fullname'; e = { Convert-Path $_.PSPath } } | export-csv -Append -Path ".\$computer-$username-$datetime.csv"}
}
