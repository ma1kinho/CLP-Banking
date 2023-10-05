using Pkg
Pkg.add("JSON")
Pkg.add("SQLite")
using SQLite
using JSON
using Printf

struct Financiamento
    id_financiamento::Int
    id_usuario::Int
    data_inicio::String
    data_termino::String
    quantidade_parcelas::Int
    valor_parcela::Float32
    valor_solicitado::Float32
    taxa::Float32
    saldo_devedor::Float32
end

struct Pessoa
    id_pessoa::Int
    salario_pessoa::Float32
    financiamentos_pessoa::Vector{Financiamento}
end

Usuarios = Pessoa[]
Financiamentos_list = Financiamento[]

main()

function main()
    println("Seja bem vindo ao micro-servico de financiamentos!!!")
    println()
    menu()
end

function menu()
    escolha = 1
    opcao = 0

    while escolha < 3
        println("Escolha o procedimento a ser realizado:")
        println("1 - Simular Financiamento")
        println("2 - Ver Financiamentos")
        println("3 - Sair do Programa")
        print("=> ")
        escolha = parse(Int, readline())

        run(`cmd /c "cls"`)
        
        if escolha == 1
            id_inst, valor_inst, parcelas_inst, salario_inst = procurar_instancia()
            simularFinanciamento(id_inst, valor_inst, parcelas_inst, salario_inst)
        elseif escolha == 2
            id_inst = procurar_user()
            verFinanciamentos(id_inst)
        else 
            println("Voce deseja finalizar o servico?")
            println("1 - Continuar utilizando o servico")
            println("2 - Finalizar servico")
            print("=> ")
            opcao = parse(Int, readline())

            if opcao == 2
                run(`cmd /c "cls"`)
                escolha = 3
                println("Obrigado por utilizar o sistema!")
            else
                escolha = 0
                run(`cmd /c "cls"`)
            end
        end
    end
end

function simularFinanciamento(id, valor, parcelas, salario)
    if parcelas <= 24
        taxa_mes = 0.21
    elseif parcelas <= 36
        taxa_mes = 0.3
    else
        taxa_mes = 0.4
    end

    aux = valor/parcelas
    valor_aux = aux*(1+taxa_mes)
    valor_total = valor_aux*parcelas

    println("----SIMULACAO DE FINANCIAMENTO----")
    println("Quantidade de parcelas: ", parcelas)
    @printf("Valor de cada parcela: %.2f\n", valor_aux)
    @printf("Taxa mensal: %.2f\n", taxa_mes)
    @printf("Valor final: %.2f\n", valor_total)
    println()
    println("Aderir ao financiamento?")
    println("1 - Sim")
    println("2 - Nao")
    print("=> ")
    opcao1 = parse(Int, readline())
    run(`cmd /c "cls"`)

    if opcao1 == 1
        if verificarAprovacao(valor_aux, salario)
            efetuarFinanciamento(id, parcelas, valor_aux, taxa_mes, valor_total, valor, salario)
        end
    else
        println("Simulacao finalizada!")
    end
end

function verificarAprovacao(valor_parc, valor_sal)
    if valor_parc >= valor_sal
        println("Voce nao possui saldo suficiente para efetuar o financiamento!")
        return false
    else
        println("Parabens, voce possui saldo suficiente para efetuar o financiamento!")
        return true
    end
end

function efetuarFinanciamento(id, parcelas, valor_aux, taxa_mes, valor_total, val, sal)
    caminho_arquivo = "C:\\Users\\GT\\Documents\\CLP\\Project\\inputs\\users\\financiamentos_("
    caminho_aux = caminho_arquivo * string(id)
    caminho_arquivo = caminho_aux * ").json"

    dados_arq = Dict(
        "quantidade_parcelas" => parcelas,
        "valor_parcela" => valor_aux,
        "taxa_mes" => taxa_mes,
        "valor_total" => valor_total,
        "status" => "em processo"
    )

    open(caminho_arquivo, "a") do io
        JSON.print(io, dados_arq)
    end
    
    temp = 0
    
    for user in Usuarios
        if user.id_pessoa == id
            finn = Financiamento(length(Financiamentos_list), id, "05/10/2023", "05/10/2025", parcelas, valor_aux, val, taxa_mes, valor_total)
            push!(user.financiamentos_pessoa, finn)
            push!(Financiamentos_list, finn)
            temp = 1
            break
        end
    end

    if temp == 0
        str_aux = string(3+parcelas/12)
        finn = Financiamento(length(Financiamentos_list), id, "05/10/2023", "05/10/2025", parcelas, valor_aux, val, taxa_mes, valor_total)
        li = [finn]
        pe = Pessoa(id, sal, li)
        push!(Usuarios, pe)
        push!(Financiamentos_list, finn) 
    end

    println("Financiamento efetuado com sucesso!")
end

function verFinanciamentos(id)
    run(`cmd /c "cls"`)
    println("Escolha uma opcao:")
    println("1 - Ver financiamentos")
    println("2 - Pagar parcelas")
    print("=> ")
    opcao2 = parse(Int, readline())
    run(`cmd /c "cls"`)

    if opcao2 == 2
        println("Digite o id do financiamento da parcela a ser paga: ")
        print("=> ")
        id_pa = parse(Int, readline())
    end
    run(`cmd /c "cls"`)

    for user in Usuarios
        if user.id_pessoa == id 
            for financ in user.financiamentos_pessoa
                if opcao2 == 1
                    printFinanciamentosUsuario(financ)
                    println("---------------------------------------")
                else
                    if id_pa == financ.id_financiamento
                        pagarParcela(financ)
                        run(`cmd /c "cls"`)
                        println("Pagamento efetuado com sucesso!")
                        break
                    end
                end
            end
        end
    end

    println()
end

function pagarParcela(financ)
    #financ.saldo_devedor -= financ.valor_parcela
    #financ.quantidade_parcelas -= 1
end

function printFinanciamentosUsuario(financi)
    println("Id do financiamento: ", financi.id_financiamento)
    println("Id do usuario: ", financi.id_usuario)
    println("Data de inicio: ", financi.data_inicio)
    println("Data de termino: ", financi.data_termino)
    println("Quantidade de parcelas: ", financi.quantidade_parcelas)
    @printf("Valor das parcelas: %.2f\n", financi.valor_parcela)
    @printf("Valor do emprestimo: %.2f\n", financi.valor_solicitado)
    @printf("Taxa mensal: %.2f\n", financi.taxa)
    @printf("Saldo devedor: %.2f\n", financi.saldo_devedor)
end

function procurar_instancia()
    #caminho_arquivo = "C:\\Users\\GT\\Documents\\CLP\\Project\\inputs\\users\\id_1_f1.json" # Caminho para o arquivo JSON
    println("Digite o diretorio da instancia do usuario:")
    print("=> ")

    caminho_arq = readline()
    run(`cmd /c "cls"`)

    if isfile(caminho_arq)
        println("Instancia encontrada!")

        dados_json = JSON.parsefile(caminho_arq)
        id = dados_json["id"]  
        valor = dados_json["valor"]  
        parcelas = dados_json["parcelas"]
        salario = dados_json["salario"]

        return id, valor, parcelas, salario
    else
        println("A instancia nao foi encontrada!")

        return
    end
end

function procurar_user()
    #caminho_arquivo = "C:\\Users\\GT\\Documents\\CLP\\Project\\inputs\\users\\1.json" # Caminho para o arquivo JSON
    println("Digite o diretorio da instancia do usuario:")
    print("=> ")

    caminho_arq = readline()
    run(`cmd /c "cls"`)

    if isfile(caminho_arq)
        println("Instancia encontrada!")
        println()

        dados_json = JSON.parsefile(caminho_arq)
        id = dados_json["id"]  

        return id
    else
        println("A instancia nao foi encontrada!")

        return
    end
end