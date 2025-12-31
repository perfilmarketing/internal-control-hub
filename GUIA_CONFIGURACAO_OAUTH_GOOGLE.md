# 🔐 Guia Completo: Configuração OAuth Google com Supabase

Este guia passo a passo vai te ajudar a configurar o login OAuth do Google no seu projeto Supabase.

## 📋 Pré-requisitos

- Conta no [Supabase](https://supabase.com)
- Conta no [Google Cloud Console](https://console.cloud.google.com)
- Projeto Supabase criado e configurado

---

## 🚀 Passo 1: Configurar OAuth no Google Cloud Console

### 1.1 Criar um Projeto no Google Cloud

1. Acesse [Google Cloud Console](https://console.cloud.google.com)
2. Clique em **"Selecionar projeto"** no topo
3. Clique em **"Novo Projeto"**
4. Preencha:
   - **Nome do projeto**: `AutoControl` (ou outro nome de sua escolha)
   - **Organização**: (opcional)
5. Clique em **"Criar"**

### 1.2 Configurar Tela de Consentimento OAuth

1. No menu lateral, vá em **"APIs e Serviços"** > **"Tela de consentimento OAuth"**
2. Selecione **"Externo"** e clique em **"Criar"**
3. Preencha as informações:
   - **Nome do app**: `AutoControl`
   - **Email de suporte do usuário**: seu email
   - **Email de contato do desenvolvedor**: seu email
4. Clique em **"Salvar e continuar"**
5. Na seção **"Escopos"**, clique em **"Salvar e continuar"** (sem adicionar escopos)
6. Na seção **"Usuários de teste"**, adicione os emails que poderão testar (opcional)
7. Clique em **"Salvar e continuar"**
8. Revise e clique em **"Voltar ao painel"**

### 1.3 Criar Credenciais OAuth 2.0

1. Vá em **"APIs e Serviços"** > **"Credenciais"**
2. Clique em **"+ Criar credenciais"** > **"ID do cliente OAuth"**
3. Selecione **"Aplicativo da Web"**
4. Preencha:
   - **Nome**: `AutoControl Web Client`
   - **Origens JavaScript autorizadas**: 
     ```
     http://localhost:8080
     http://localhost:5173
     https://seu-dominio.com
     ```
   - **URIs de redirecionamento autorizados**:
     ```
     http://localhost:8080/dashboard
     http://localhost:5173/dashboard
     https://seu-dominio.com/dashboard
     https://ldkincjowaokcismhnqz.supabase.co/auth/v1/callback
     ```
     ⚠️ **IMPORTANTE**: Substitua `ldkincjowaokcismhnqz` pelo ID do seu projeto Supabase!
5. Clique em **"Criar"**
6. **Copie e guarde**:
   - **ID do cliente** (Client ID)
   - **Segredo do cliente** (Client Secret)

---

## 🔧 Passo 2: Configurar OAuth no Supabase

### 2.1 Acessar Configurações de Autenticação

1. Acesse seu projeto no [Supabase Dashboard](https://app.supabase.com)
2. No menu lateral, vá em **"Authentication"** > **"Providers"**
3. Role até encontrar **"Google"**

### 2.2 Habilitar e Configurar Google OAuth

1. Clique no toggle para **habilitar** o Google
2. Preencha os campos:
   - **Client ID (for OAuth)**: Cole o **ID do cliente** do Google Cloud
   - **Client Secret (for OAuth)**: Cole o **Segredo do cliente** do Google Cloud
3. Clique em **"Save"**

### 2.3 Configurar URL de Redirecionamento

1. Ainda em **"Authentication"** > **"URL Configuration"**
2. Adicione suas URLs de redirecionamento em **"Redirect URLs"**:
   ```
   http://localhost:8080/dashboard
   http://localhost:5173/dashboard
   https://seu-dominio.com/dashboard
   ```
3. Clique em **"Save"**

---

## 🗄️ Passo 3: Criar Tabela de Perfis no Banco de Dados

### 3.1 Acessar SQL Editor

1. No Supabase Dashboard, vá em **"SQL Editor"** no menu lateral
2. Clique em **"New query"**

### 3.2 Executar Script SQL

Copie e cole o seguinte SQL e execute:

```sql
-- Criar tabela de perfis de usuário
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política: usuários podem ver seu próprio perfil
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

-- Política: usuários podem atualizar seu próprio perfil
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Política: usuários podem inserir seu próprio perfil
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Função para criar perfil automaticamente quando um usuário se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger para criar perfil automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger para updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_profiles_updated_at();
```

3. Clique em **"Run"** ou pressione `Ctrl+Enter`

### 3.3 Verificar Criação da Tabela

1. Vá em **"Table Editor"** no menu lateral
2. Verifique se a tabela `profiles` foi criada
3. Verifique se as políticas RLS estão ativas

---

## 🔄 Passo 4: Atualizar Tipos do Supabase (Opcional)

Se você usar TypeScript e quiser tipos atualizados:

1. Instale o Supabase CLI (se ainda não tiver):
   ```bash
   npm install -g supabase
   ```

2. Faça login:
   ```bash
   supabase login
   ```

3. Gere os tipos atualizados:
   ```bash
   supabase gen types typescript --project-id seu-project-id > src/integrations/supabase/types.ts
   ```

   ⚠️ Substitua `seu-project-id` pelo ID do seu projeto Supabase.

---

## ✅ Passo 5: Testar o Login

### 5.1 Iniciar o Servidor de Desenvolvimento

```bash
npm run dev
```

### 5.2 Testar o Fluxo

1. Acesse `http://localhost:8080/login` (ou a porta configurada)
2. Clique em **"Entrar com Google"**
3. Selecione sua conta Google
4. Autorize o aplicativo
5. Você deve ser redirecionado para `/dashboard`
6. Verifique se seu perfil foi criado na tabela `profiles`

---

## 🐛 Solução de Problemas

### Erro: "redirect_uri_mismatch"

**Causa**: A URL de redirecionamento não está configurada corretamente no Google Cloud Console.

**Solução**:
1. Verifique se adicionou todas as URLs de redirecionamento no Google Cloud Console
2. Certifique-se de incluir a URL do Supabase: `https://seu-projeto-id.supabase.co/auth/v1/callback`
3. Aguarde alguns minutos após salvar as configurações

### Erro: "invalid_client"

**Causa**: Client ID ou Client Secret incorretos no Supabase.

**Solução**:
1. Verifique se copiou corretamente o Client ID e Client Secret do Google Cloud Console
2. Certifique-se de não ter espaços extras ao colar
3. Salve novamente as configurações no Supabase

### Perfil não é criado automaticamente

**Causa**: O trigger não foi criado ou não está funcionando.

**Solução**:
1. Verifique se o trigger `on_auth_user_created` existe em **"Database"** > **"Triggers"**
2. Execute novamente o script SQL de criação do trigger
3. Verifique os logs em **"Database"** > **"Logs"**

### Erro de CORS

**Causa**: Origens JavaScript não autorizadas no Google Cloud Console.

**Solução**:
1. Adicione `http://localhost:8080` e `http://localhost:5173` nas **"Origens JavaScript autorizadas"**
2. Aguarde alguns minutos após salvar

---

## 📝 Checklist Final

- [ ] Projeto criado no Google Cloud Console
- [ ] Tela de consentimento OAuth configurada
- [ ] Credenciais OAuth 2.0 criadas (Client ID e Secret)
- [ ] URLs de redirecionamento configuradas no Google Cloud
- [ ] Google OAuth habilitado no Supabase
- [ ] Client ID e Secret configurados no Supabase
- [ ] URLs de redirecionamento configuradas no Supabase
- [ ] Tabela `profiles` criada no banco de dados
- [ ] Políticas RLS configuradas
- [ ] Trigger de criação automática de perfil funcionando
- [ ] Login testado com sucesso

---

## 🔒 Segurança Adicional

### Para Produção:

1. **Restringir domínios autorizados**: Adicione apenas seus domínios de produção nas configurações do Google Cloud
2. **Revisar políticas RLS**: Ajuste as políticas conforme necessário para seu caso de uso
3. **Monitorar logs**: Acompanhe os logs de autenticação no Supabase Dashboard
4. **Configurar rate limiting**: Configure limites de taxa no Supabase para prevenir abuso

---

## 📚 Recursos Adicionais

- [Documentação Supabase Auth](https://supabase.com/docs/guides/auth)
- [Documentação Google OAuth](https://developers.google.com/identity/protocols/oauth2)
- [Guia de RLS do Supabase](https://supabase.com/docs/guides/auth/row-level-security)

---

## 💡 Dicas

- Mantenha suas credenciais seguras e nunca as commite no Git
- Use variáveis de ambiente para diferentes ambientes (dev, staging, prod)
- Teste o fluxo completo antes de fazer deploy em produção
- Configure backups regulares do banco de dados

---

**Pronto!** Seu sistema de autenticação OAuth Google está configurado e funcionando! 🎉

