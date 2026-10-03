-- 1. Tabela de Feirantes
create table if not exists feirantes (
    id uuid default gen_random_uuid() primary key,
    nome text not null
);

-- 2. Tabela de Feiras (por data)
create table if not exists feiras (
    data date primary key,
    taxa numeric(10,2) not null default 50.00
);

-- 3. Tabela de Pagamentos (relação entre feira e feirante)
create table if not exists pagamentos (
    feira_data date references feiras(data) on delete cascade,
    feirante_id uuid references feirantes(id) on delete cascade,
    status text not null default 'pendente',
    forma text default '',
    primary key (feira_data, feirante_id)
);

-- 4. Tabela de Despesas das Feiras (com a coluna "descricao" corrigida)
create table if not exists despesas (
    id uuid default gen_random_uuid() primary key,
    feira_data date references feiras(data) on delete cascade,
    descricao text not null,
    valor numeric(10,2) not null,
    forma text not null default 'dinheiro'
);

-- 5. Habilitar Row Level Security (RLS) e políticas públicas para acesso livre
alter table feirantes enable row level security;
alter table feiras enable row level security;
alter table pagamentos enable row level security;
alter table despesas enable row level security;

create policy "Permitir acesso público feirantes" on feirantes for all using (true) with check (true);
create policy "Permitir acesso público feiras" on feiras for all using (true) with check (true);
create policy "Permitir acesso público pagamentos" on pagamentos for all using (true) with check (true);
create policy "Permitir acesso público despesas" on despesas for all using (true) with check (true);