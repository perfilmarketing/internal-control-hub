# 🔧 Guia de Configuração do Supabase

Este guia vai te ajudar a configurar as credenciais do Supabase no seu projeto.

## 📋 Passo a Passo

### 1. Obter as Credenciais do Supabase

1. Acesse [supabase.com](https://supabase.com) e faça login na sua conta
2. Selecione seu projeto (ou crie um novo)
3. Vá em **Settings** (⚙️) no menu lateral
4. Clique em **API** no menu de configurações

Você encontrará:
- **Project URL**: URL do seu projeto (ex: `https://xxxxx.supabase.co`)
- **anon public key**: Chave pública para uso no frontend (começa com `eyJ...`)

### 2. Criar o Arquivo `.env`

Na raiz do projeto, crie um arquivo chamado `.env` com o seguinte conteúdo:

```env
# Configuração do Supabase
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sua-anon-key-aqui
VITE_SUPABASE_PROJECT_ID=seu-project-id
```

**⚠️ IMPORTANTE**: Substitua os valores pelos seus dados reais do Supabase!

### 3. Exemplo de Arquivo `.env` Preenchido

```env
VITE_SUPABASE_URL=https://kzegnwfciiisibmhctcc.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6ZWdud2ZjaWlpc2libWhjdGNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk5OTk5OTksImV4cCI6MjAxNTU3NTk5OX0.exemplo
VITE_SUPABASE_PROJECT_ID=kzegnwfciiisibmhctcc
```

### 4. Verificar a Configuração

Após criar o arquivo `.env`:

1. **Reinicie o servidor de desenvolvimento** (se estiver rodando):
   ```bash
   # Pare o servidor (Ctrl+C) e inicie novamente
   npm run dev
   ```

2. O projeto deve iniciar sem erros relacionados ao Supabase

3. Se aparecer algum erro sobre variáveis de ambiente não encontradas, verifique:
   - O arquivo `.env` está na raiz do projeto
   - As variáveis começam com `VITE_`
   - Não há espaços extras ou aspas nas variáveis
   - O servidor foi reiniciado após criar/editar o `.env`

### 5. Configurar o Banco de Dados

Se ainda não configurou o banco de dados, siga as instruções no `README.md` na seção "🔧 Configuração do Supabase" para criar as tabelas necessárias.

## 🔒 Segurança

- **NUNCA** commite o arquivo `.env` no Git
- O arquivo `.env` já está no `.gitignore` para sua proteção
- A chave `anon public` é segura para uso no frontend, mas não compartilhe publicamente

## ❓ Problemas Comuns

### Erro: "Variável de ambiente VITE_SUPABASE_URL não encontrada"
- Verifique se o arquivo `.env` existe na raiz do projeto
- Confirme que a variável está escrita corretamente: `VITE_SUPABASE_URL`
- Reinicie o servidor de desenvolvimento

### Erro de conexão com o Supabase
- Verifique se a URL está correta (sem espaços extras)
- Confirme que a chave pública está completa
- Verifique se o projeto Supabase está ativo

### Dados não aparecem na aplicação
- Verifique se as tabelas foram criadas no Supabase
- Confirme as políticas RLS (Row Level Security) no Supabase
- Verifique o console do navegador para erros específicos

## 📚 Recursos Adicionais

- [Documentação do Supabase](https://supabase.com/docs)
- [Guia de Variáveis de Ambiente no Vite](https://vitejs.dev/guide/env-and-mode.html)
