$user = $env:UserName
$dotnetVersion = 3.1.410
$netcoreapp = "netcoreapp3.1" # "net5.0"
Write-Host "Hello $user!"

Write-Host " ====================== Init creation of projects and folders ====================== " -ForegroundColor "Green"
$userAppName = Read-Host "What is application name? "

if ([string]::IsNullOrEmpty($userAppName)) {
    Write-Host "Name not valid!" -ForegroundColor "Red"
}
else {
    # capitalize the first character of a string
    $UpperAppName = (Get-Culture).TextInfo.ToTitleCase("$userAppName")
    # name without white spaces
    $appName = $UpperAppName.replace(' ','')

    Write-Host "Selected name is $appName!" -ForegroundColor "Green"

    # create directory for application
    mkdir $appName
    cd $appName

    # add global.json file
    echo global.json
    Add-Content -Path global.json -Value "{"  
    Add-Content -Path global.json -Value "  ""sdk"": { "  
    Add-Content -Path global.json -Value "    ""version"": ""$dotnetVersion"""  
    Add-Content -Path global.json -Value "  }"  
    Add-Content -Path global.json -Value "}"  

    # create solution
    dotnet new sln -n $appName

    # ============================ Presentation layer ============================
    # create presentation project
    dotnet new webapi -n "$appName.Application" -o "$appName.Application" --no-https -f $netcoreapp

    # add solution
    dotnet sln add .\"$appName.Application"\

    # ============================ Domain layer ============================
    # create domain layer
    dotnet new classlib -n "$appName.Domain" -o "$appName.Domain" -f $netcoreapp

    # add domain in solution
    dotnet sln add .\"$appName.Domain"\

    mkdir -p "$appName.Domain\DTOs"
    mkdir -p "$appName.Domain\Entities"
    mkdir -p "$appName.Domain\Interfaces"
    mkdir -p "$appName.Domain\Interfaces\Repository"
    mkdir -p "$appName.Domain\Interfaces\Services"

    # ============================ CROSS CUTTING ============================
    # create CrossCutting layer
    dotnet new classlib -n "$appName.Infra.CrossCutting" -o "$appName.Infra.CrossCutting" -f $netcoreapp

    # add cross cutting in solution
    dotnet sln add .\"$appName.Infra.CrossCutting"\

    mkdir -p "$appName.Infra.CrossCutting\DependencyInjection"
    mkdir -p "$appName.Infra.CrossCutting\Mappings"

    # ============================ DATA ============================
    # create Data project
    dotnet new classlib -n "$appName.Infra.Data" -o "$appName.Infra.Data" -f $netcoreapp

    # add project in solution
    dotnet sln add .\"$appName.Infra.Data"\

    mkdir -p "$appName.Infra.Data\Context"
    mkdir -p "$appName.Infra.Data\Implementation"
    mkdir -p "$appName.Infra.Data\Mappings"
    mkdir -p "$appName.Infra.Data\Factory"
    mkdir -p "$appName.Infra.Data\Repository"

    # ============================ SERVICE ============================
    # create service layer
    dotnet new classlib -n "$appName.Service" -o "$appName.Service" -f $netcoreapp

    # add project in solution
    dotnet sln add .\"$appName.Service"\

    mkdir -p "$appName.Service\Services"

    # ============================ Add references on projects ============================
    # data 
    dotnet add .\"$appName.Infra.Data"\ reference .\"$appName.Domain"\

    # service
    dotnet add .\"$appName.Service"\ reference .\"$appName.Domain"\
    dotnet add .\"$appName.Service"\ reference .\"$appName.Infra.Data"\

    # application
    dotnet add .\"$appName.Application"\ reference .\"$appName.Domain"\
    dotnet add .\"$appName.Application"\ reference .\"$appName.Service"\
    dotnet add .\"$appName.Application"\ reference .\"$appName.Infra.CrossCutting"\

    # cross cutting
    dotnet add .\"$appName.Infra.CrossCutting"\ reference .\"$appName.Domain"\
    dotnet add .\"$appName.Infra.CrossCutting"\ reference .\"$appName.Service"\
    dotnet add .\"$appName.Infra.CrossCutting"\ reference .\"$appName.Infra.Data"\

    # ============================ Remove classes Unnecessary ============================
    # init remotion of classes Class1.cs of projects

    $classFileName = "Class1.cs"
    $classAppName = "WeatherForecast.cs"

    $location = Get-Location

    cd .\"$appName.Service"\
    if ($NULL -ne "$location\$appName.Service\$classFileName") {
        Remove-Item "$location\$appName.Service\$classFileName" | out-null
    }
    cd ..

    cd .\"$appName.Domain"\
    if ($NULL -ne "$location\$appName.Domain\$classFileName") {
        Remove-Item "$location\$appName.Domain\$classFileName" | out-null
    }
    cd ..

    cd .\"$appName.Infra.Data"\
    if ($NULL -ne "$location\$appName.Infra.Data\$classFileName") {
        Remove-Item "$location\$appName.Infra.Data\$classFileName" | out-null
    }
    cd ..

    cd .\"$appName.Infra.CrossCutting"\
    if ($NULL -ne "$location\$appName.Infra.CrossCutting\$classFileName") {
        Remove-Item "$location\$appName.Infra.CrossCutting\$classFileName" | out-null
    }
    cd ..

    cd .\"$appName.Application"\
    if ($NULL -ne "$location\$appName.Application\$classAppName") {
        Remove-Item "$location\$appName.Application\$classAppName" | out-null
    }
    cd .\Controllers\
    if ($NULL -ne "$location\$appName.Application\WeatherForecastController.cs") {
        Remove-Item "$location\$appName.Application\Controllers\WeatherForecastController.cs" | out-null
    }
    cd ..
    cd ..

    # ============================ Add dependencies on projects ============================
    cd .\"$appName.Infra.Data"\

    dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 3.1.6
    dotnet add package Microsoft.EntityFrameworkCore.Tools --version 3.1.6
    dotnet add package Microsoft.EntityFrameworkCore.Design --version 3.1.6
    dotnet add package AutoMapper --version 10.1.1

    cd ..

    cd .\"$appName.Infra.CrossCutting"\

    dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection --version 8.1.0

    cd ..

    cd .\"$appName.Service"\

    dotnet add package AutoMapper --version 10.1.1

    cd ..

    dotnet restore
	dotnet build

    # ============================ Add .gitattributes ============================
    # add .gitignore
    dotnet new gitignore

    # add .gitattributes
    echo .gitattributes
    Add-Content -Path .gitattributes "# Set default behavior to automatically normalize line endings. > .gitattributes"          
    Add-Content -Path .gitattributes "* text=auto"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "*.doc  diff=astextplain"
    Add-Content -Path .gitattributes "*.DOC	 diff=astextplain"
    Add-Content -Path .gitattributes "*.docx diff=astextplain"
    Add-Content -Path .gitattributes "*.DOCX diff=astextplain"
    Add-Content -Path .gitattributes "*.dot	 diff=astextplain"
    Add-Content -Path .gitattributes "*.DOT	 diff=astextplain"
    Add-Content -Path .gitattributes "*.pdf	 diff=astextplain"
    Add-Content -Path .gitattributes "*.PDF	 diff=astextplain"
    Add-Content -Path .gitattributes "*.rtf	 diff=astextplain"
    Add-Content -Path .gitattributes "*.RTF	 diff=astextplain"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "*.jpg  binary"
    Add-Content -Path .gitattributes "*.png  binary"
    Add-Content -Path .gitattributes "*.gif  binary"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "# Force bash scripts to always use lf line endings so that if a repo is accessed"
    Add-Content -Path .gitattributes "# in Unix via a file share from Windows, the scripts will work."
    Add-Content -Path .gitattributes "*.in text eol=lf"
    Add-Content -Path .gitattributes "*.sh text eol=lf"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "Likewise, force cmd and batch scripts to always use crlf"
    Add-Content -Path .gitattributes "*.cmd text eol=crlf"
    Add-Content -Path .gitattributes "*.bat text eol=crlf"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "*.cs text=auto diff=csharp"
    Add-Content -Path .gitattributes "*.vb text=auto"
    Add-Content -Path .gitattributes "*.resx text=auto"
    Add-Content -Path .gitattributes "*.c text=auto"
    Add-Content -Path .gitattributes "*.cpp text=auto"
    Add-Content -Path .gitattributes "*.cxx text=auto"
    Add-Content -Path .gitattributes "*.h text=auto"
    Add-Content -Path .gitattributes "*.hxx text=auto"
    Add-Content -Path .gitattributes "*.py text=auto"
    Add-Content -Path .gitattributes "*.rb text=auto"
    Add-Content -Path .gitattributes "*.java text=auto"
    Add-Content -Path .gitattributes "*.html text=auto"
    Add-Content -Path .gitattributes "*.htm text=auto"
    Add-Content -Path .gitattributes "*.css text=auto"
    Add-Content -Path .gitattributes "*.scss text=auto"
    Add-Content -Path .gitattributes "*.sass text=auto"
    Add-Content -Path .gitattributes "*.less text=auto"
    Add-Content -Path .gitattributes "*.js text=auto"
    Add-Content -Path .gitattributes "*.lisp text=auto"
    Add-Content -Path .gitattributes "*.clj text=auto"
    Add-Content -Path .gitattributes "*.sql text=auto"
    Add-Content -Path .gitattributes "*.php text=auto"
    Add-Content -Path .gitattributes "*.lua text=auto"
    Add-Content -Path .gitattributes "*.m text=auto"
    Add-Content -Path .gitattributes "*.asm text=auto"
    Add-Content -Path .gitattributes "*.erl text=auto"
    Add-Content -Path .gitattributes "*.fs text=auto"
    Add-Content -Path .gitattributes "*.fsx text=auto"
    Add-Content -Path .gitattributes "*.hs text=auto"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "*.csproj text=auto"
    Add-Content -Path .gitattributes "*.vbproj text=auto"
    Add-Content -Path .gitattributes "*.fsproj text=auto"
    Add-Content -Path .gitattributes "*.dbproj text=auto"
    Add-Content -Path .gitattributes "*.sln text=auto eol=crlf"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "# Set linguist language for .h files explicitly based on"
    Add-Content -Path .gitattributes "# https://github.com/github/linguist/issues/1626#issuecomment-401442069"
    Add-Content -Path .gitattributes "# this only affects the repo's language statistics"
    Add-Content -Path .gitattributes "*.h linguist-language=C"
    Add-Content -Path .gitattributes " "

    Add-Content -Path .gitattributes "# CLR specific"
    Add-Content -Path .gitattributes "src/coreclr/src/pal/tests/palsuite/paltestlist.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/src/pal/tests/palsuite/paltestlist_to_be_reviewed.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/regexdna/regexdna-input25.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/regexdna/regexdna-input25000.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/regex-redux/regexdna-input25.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/regex-redux/regexdna-input25000.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/reverse-complement/revcomp-input25.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/reverse-complement/revcomp-input25000.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/k-nucleotide/knucleotide-input.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/JIT/Performance/CodeQuality/BenchmarksGame/k-nucleotide/knucleotide-input-big.txt text eol=lf"
    Add-Content -Path .gitattributes "src/coreclr/tests/src/performance/Scenario/JitBench/Resources/word2vecnet.patch text eol=lf"
    Add-Content -Path .gitattributes " "

    # init Git repo
    git init

    # open project on Visual Studio
    $solutionFinished = -join($appName, ".sln")
    .\$solutionFinished

    exit 
}