use `banco_financeiro`;

-- Mini Projeto: Heloisa Colatto Polese 3º Período

-- Tema do banco: Sistema bancário

-- Tabelas Principais: Clientes, Contas, Agencias e Transacoes
	
-- Relacionamentos
	-- Uma Agencia possui Contas (1:0*)
	-- Uma Conta efetua zero ou varias transacoes (1:0*)
	-- Uma Conta pode possuir zero ou vários Cartoes (1:0*)
	-- Uma Conta pode ser Corrente (1:0..1)
	-- Uma Conta pode ser Poupança (1:0..1)
	-- Um Cliente pode ter várias Contas e uma Conta pode ter vários Clientes (tabela associativa ClientesContas)
	-- Um Cliente pode ter vários Endereços e um Endereço pode ter vários Clientes (tabela associativa ClientesEnderecos)
	-- Uma Agencia pode ter vários Enderecos e um Endereço pode ter várias Agencias (tabela associativa AgenciasEnderecos)

-- Objetivo do sistema:
	-- Gerenciar clientes, contas bancárias e transações
	-- permite consultas para análise de dados financeiros

-- Quantidade de Inserts em cada tabela
	-- agencias: 10060
	-- agenciasenderecos: 10060
	-- cartoes: 11728
	-- clientes 11752
	-- clientescontas: 10000
	-- clientesenderecos: 11752
	-- enderecos: 11752
	-- contas 13949
	-- contascorrentes: 5000
	-- contaspoupancas: 4010
	-- transações: 10008

-- Quantidade de consultas por categoria de indice:
	-- 1 Consultas de Indice Único
	-- 3 Consultas de Indice Composto
	-- 2 Consultas de Indice Simples

-- Consultas 

--  consultas simples (SELECT com WHERE)

     -- 1) Consulta (Indice Composto) que retorna o nome e data de nascimento, do cliente que nasceu em '2000-01-01' e tem o telefone = '2799990001'
	   --  de 11.514 linhas para 1 após criação do índice
	

		-- create e drop para testes da criação de índices
		create index idx_telefone_datanasc on clientes(telefone,data_nascimento);
		drop index idx_telefone_datanasc on clientes;
		
		-- Importante
			--  YEAR() na coluna faz o banco aplicar a função em todos os registros FULL SCAN

		explain select c.nome,c.data_nascimento
		from Clientes c
		where c.data_nascimento = '2000-01-01'
		and c.telefone = '2799990001';

      -- 2) Consulta (Indice Unique) que retorna todos os dados do cliente com telefone = '2799990001'
	    -- de 11.514 linhas para 1 linha após criação do índice


		-- create e drop para testes da criação de índices
		create unique index idx_telefone on clientes(telefone);
		drop index idx_telefone on clientes;

		explain select *
		from Clientes c
		where c.telefone = '2799990001';

      -- 3) Consulta (Indice Simples) que retorna o nome da agencia com o numero_agencia = 1705
	    -- de 9.957 linhas para 1 linha
	
		-- create e drop para testes da criação de índices
		create index idx_num_agencia on agencias(numero_agencia);
		drop index idx_num_agencia on agencias;

		explain select a.nome	
		from Agencias a
		where a.numero_agencia = 1705;

-- consultas com JOIN
	
      -- 1) Consulta (Indice Simples) que retorna o nome dos clientes que possuem cep = '29900000'
	    -- de 11.514 linhas para 3
	
		-- create e drop para testes da criação de índices
		create index idx_cep on Enderecos(cep);
		drop index idx_cep on Enderecos;

		explain select c.nome
		from Enderecos e
		inner join ClientesEnderecos ce on ce.id_endereco = e.id_endereco
		inner join Clientes c on c.id_cliente = ce.id_cliente
		where cep = '29900000';

       -- 2) Consulta (Indice Composto) que retorna o nome e a data de nascimento de clientes que moram no Espiríto Santo na cidade Linhares
	     -- de 11.514 linhas para 1.012

		-- create e drop para testes da criação de índices
		create index idx_uf_cidade on Enderecos(UF,cidade);
		drop index idx_uf_cidade on Enderecos;

		explain select c.nome,c.data_nascimento
		from Enderecos e
		inner join ClientesEnderecos ce on ce.id_endereco = e.id_endereco
		inner join Clientes c on c.id_cliente = ce.id_cliente
		where uf = 'ES'
		and cidade = 'Linhares';


-- consulta com ordenação (ORDER BY)
	
      -- 1) Consulta (Indice Composto) que retorna todas as informações das contas com saldo maior que R$1.000,00 de data de abertura = '2024-01-05' 
	    -- de 13.850 linhas para 32
	
		-- IMPORTANTE: Se o índice começasse por saldo:(saldo, data_abertura) o banco precisaria procurar
		-- todos os registros com saldo maior que 1000 Resultado = FULL SCAN ou ALL

		-- create e drop para testes da criação de índices
		create index idx_saldo_data on contas(data_abertura,saldo); 
		drop index idx_saldo_data on contas;

		explain select *
		from Contas c
		where c.saldo > 1000 
		and c.data_abertura = '2024-01-05'
		order by c.saldo;
	