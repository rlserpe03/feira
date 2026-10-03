# 🛒 Controle de Feira & Condomínio (Online)

Sistema web leve, responsivo e integrado ao **Supabase** para o gerenciamento completo de feiras livres em condomínios. A aplicação permite o cadastro de feirantes, controle de taxas por data de realização, registro de recebimentos (Dinheiro ou Pix), lançamento de despesas operacionais, fechamento de caixa e emissão de relatórios consolidados.

---

## 🚀 Funcionalidades

- **Gestão de Feirantes:** Cadastro, edição e exclusão de feirantes/barracas.
- **Controle por Data de Feira:** Abertura e gerenciamento dinâmico de feiras por data específica com valor de taxa configurável.
- **Lançamento de Recebimentos:** Marcação rápida de adimplência (Pago em Dinheiro, Pix ou Pendente).
- **Gestão de Despesas:** Adição e controle de custos do dia (limpeza, energia, etc.) detalhados por forma de pagamento.
- **Caixa Geral & Fechamento:** Visibilidade em tempo real do fluxo de caixa acumulado (Dinheiro vs. Pix, valores brutos, despesas e saldo líquido).
- **Relatórios & Prestação de Contas:** Relatórios individuais por feira e geral consolidado, prontos para impressão ou exportação em PDF.

---

## 🛠️ Tecnologias Utilizadas

- **Frontend:** HTML5, Tailwind CSS (via CDN) e JavaScript Vanilla.
- **Banco de Dados & Backend:** [Supabase](https://supabase.com/) (PostgreSQL com SDK JavaScript v2).
- **Hospedagem / Execução:** Compatível com GitHub Pages, Vercel, Netlify ou execução local direto no navegador.

---

## 📋 Pré-requisitos e Configuração do Banco de Dados

Para rodar o projeto, você precisará de uma conta gratuita no [Supabase](https://supabase.com/).

### 1. Criar as Tabelas no Supabase
Acesse o **SQL Editor** do seu projeto no Supabase e execute o seguinte script para criar as tabelas e políticas de segurança necessárias:

```sql
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

-- 4. Tabela de Despesas das Feiras
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
