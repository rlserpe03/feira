-- =========================================================================
-- 1. CRIAÇÃO DAS TABELAS

-- Feira@2026! (senha supabase)
-- =========================================================================

-- Tabela de Feirantes (Cadastro Geral)
CREATE TABLE public.feirantes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(50),
    segmento VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabela de Feiras (Eventos)
CREATE TABLE public.feiras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    data DATE NOT NULL,
    taxa NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabela de Receitas Extras vinculadas a cada Feira
CREATE TABLE public.receitas_extras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    feira_id UUID NOT NULL REFERENCES public.feiras(id) ON DELETE CASCADE,
    descricao VARCHAR(255) NOT NULL,
    valor NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    pagamento VARCHAR(20) NOT NULL CHECK (pagamento IN ('dinheiro', 'pix')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabela de Despesas detalhadas vinculadas a cada Feira
CREATE TABLE public.despesas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    feira_id UUID NOT NULL REFERENCES public.feiras(id) ON DELETE CASCADE,
    descricao VARCHAR(255) NOT NULL,
    valor NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    pagamento VARCHAR(20) NOT NULL CHECK (pagamento IN ('dinheiro', 'pix')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabela de Registros (Presença e Pagamento do Feirante por Feira)
CREATE TABLE public.registros_feirantes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    feira_id UUID NOT NULL REFERENCES public.feiras(id) ON DELETE CASCADE,
    feirante_id UUID NOT NULL REFERENCES public.feirantes(id) ON DELETE CASCADE,
    presente BOOLEAN NOT NULL DEFAULT FALSE,
    pagamento VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (pagamento IN ('pendente', 'dinheiro', 'pix')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    -- Garante que um feirante só tenha um registro por feira
    CONSTRAINT unique_feira_feirante UNIQUE (feira_id, feirante_id)
);


-- =========================================================================
-- 2. ÍNDICES PARA MELHORAR PERFORMANCE DE BUSCAS
-- =========================================================================
CREATE INDEX idx_feirantes_nome ON public.feirantes(nome);
CREATE INDEX idx_feiras_data ON public.feiras(data DESC);
CREATE INDEX idx_receitas_feira ON public.receitas_extras(feira_id);
CREATE INDEX idx_despesas_feira ON public.despesas(feira_id);
CREATE INDEX idx_registros_feira ON public.registros_feirantes(feira_id);
CREATE INDEX idx_registros_feirante ON public.registros_feirantes(feirante_id);


-- =========================================================================
-- 3. CONFIGURAÇÃO DE SEGURANÇA (Row Level Security - RLS)
-- =========================================================================
-- Habilita o RLS em todas as tabelas
ALTER TABLE public.feirantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receitas_extras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registros_feirantes ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso público (Leitura e Escrita livres para uso interno/simples)
-- Caso vá adicionar sistema de login futuramente, você poderá restringir estas políticas.
CREATE POLICY "Permitir acesso público a feirantes" ON public.feirantes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso público a feiras" ON public.feiras FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso público a receitas_extras" ON public.receitas_extras FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso público a despesas" ON public.despesas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso público a registros" ON public.registros_feirantes FOR ALL USING (true) WITH CHECK (true);