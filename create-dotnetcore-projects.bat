@echo off
rem oculta o caminho relativo no cmd. Exemplo: C:/
echo " ====================== Iniciando criacao dos projetos ====================== "

set /p aplicacao=Informe o nome da aplicacao 

if [%aplicacao%] == [] (
    color 4
    echo "Nome da aplicacao nao informado"
) else (
    echo O nome escolhido foi %aplicacao%

    rem cria uma pasta para o projeto 
    md %aplicacao%

    cd %aplicacao%

    rem criando a solution
    dotnet new sln -n %aplicacao%

    rem ============================ APRESENTAÇÃO ============================
    rem criando o projeto de apresentação
    dotnet new webapi -n Application -o Api.Application --no-https

    rem adicionando a solução
    dotnet sln add .\Api.Application\

    rem ============================ DOMíNIO ============================
    rem criando a camada de domínio
    dotnet new classlib -n Domain -o Api.Domain -f netcoreapp3.1

    rem adicionando o domínio a solução
    dotnet sln add .\Api.Domain\

    cd .\Api.Domain\

    md Entities
    md Interfaces
    cd .\Interfaces\
    md Services
    cd ..
    cd ..

    rem ============================ CROSS CUTTING ============================
    rem criando o projeto da camada CrossCutting
    dotnet new classlib -n CrossCutting -o Api.CrossCutting -f netcoreapp3.1

    rem adionando a solução
    dotnet sln add .\Api.CrossCutting\

    cd .\Api.CrossCutting\

    md DependencyInjection

    cd ..

    rem ============================ DATA ============================
    rem criando o projeto Data
    dotnet new classlib -n Data -o Api.Data -f netcoreapp3.1

    rem adicionando a solução
    dotnet sln add Api.Data\

    cd .\Api.Data\

    md Context
    md Factory
    md Mapping
    md Repository

    cd ..

    rem ============================ SERVICE ============================
    rem criando o projeto da camada de serviço
    dotnet new classlib -n Service -o Api.Service -f netcoreapp3.1

    rem adicionando a solução
    dotnet sln add Api.Service\

    cd .\Api.Service\

    md Services

    cd ..

    rem ============================ ADICIONANDO AS REFERÊNCIAS NOS PROJETOS ============================
    dotnet add .\Api.Data\ reference .\Api.Domain\

    rem service
    dotnet add .\Api.Service\ reference .\Api.Domain\
    dotnet add .\Api.Service\ reference .\Api.Data\

    rem application
    dotnet add .\Api.Application\ reference .\Api.Domain\
    dotnet add .\Api.Application\ reference .\Api.Service\
    dotnet add .\Api.Application\ reference .\Api.CrossCutting\

    rem cross cutting
    dotnet add .\Api.CrossCutting\ reference .\Api.Domain\
    dotnet add .\Api.CrossCutting\ reference .\Api.Service\
    dotnet add .\Api.CrossCutting\ reference .\Api.Data\

    rem ============================ REMOVENDO CLASSES DESNECESSÁRIAS DOS PROJETOS ============================
    rem inicia remoção das classes Class1.cs dos projetos

    cd .\Api.Service\
    if exist Class1.cs (
        del Class1.cs
    )
    cd ..

    cd .\Api.Domain\
    if exist Class1.cs (
        del Class1.cs
    )
    cd ..

    cd .\Api.Data\
    if exist Class1.cs (
        del Class1.cs
    )
    cd ..

    cd .\Api.CrossCutting\
    if exist Class1.cs (
        del Class1.cs
    )
    cd ..

    cd .\Api.Application\
    if exist WeatherForecast.cs (
        del WeatherForecast.cs
    )
    cd .\Controllers\
    if exist WeatherForecastController.cs (
        del WeatherForecastController.cs
    )
    cd ..
    cd ..

    rem ============================ ADICIONANDO AS DEPENDÊNCIAS NOS PROJETOS ============================
    rem inicia instalação de dependências dos projetos
    cd .\Api.Data\

    dotnet add package Microsoft.EntityFrameworkCore.SqlServer
    dotnet add package Microsoft.EntityFrameworkCore.Tools
    dotnet add package Microsoft.EntityFrameworkCore.Design

    cd ..

    cd .\Api.CrossCutting\

    dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection

    cd ..

    dotnet restore
	dotnet build

    rem iniciando um repositório git no projeto
    echo "Iniciando um repositorio Git"
    git init
    
    color 2
    echo " ====================== Execucao do script finalizada ====================== "
    echo " ====================== Projetos criados ====================== "

    rem abrindo o projeto no vs code 
    code .
)

pause