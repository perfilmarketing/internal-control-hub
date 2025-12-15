CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--



--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


SET default_table_access_method = heap;

--
-- Name: chips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chips (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    numero text NOT NULL,
    api_usada text NOT NULL,
    token text,
    url text,
    ultima_recarga date NOT NULL,
    data_limite date GENERATED ALWAYS AS ((ultima_recarga + '40 days'::interval)) STORED,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    client_id uuid
);


--
-- Name: client_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id uuid NOT NULL,
    mes integer NOT NULL,
    ano integer NOT NULL,
    total_chips numeric(10,2) DEFAULT 0,
    total_api numeric(10,2) DEFAULT 0,
    total_geral numeric(10,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT client_reports_ano_check CHECK ((ano >= 2020)),
    CONSTRAINT client_reports_mes_check CHECK (((mes >= 1) AND (mes <= 12)))
);


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    chips uuid[] DEFAULT '{}'::uuid[],
    apis uuid[] DEFAULT '{}'::uuid[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: openai_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.openai_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    api_key text NOT NULL,
    tipo text DEFAULT 'individual'::text NOT NULL,
    endpoint text DEFAULT 'https://api.openai.com/v1'::text,
    gasto_atual numeric(10,2) DEFAULT 0,
    atualizado_em timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    client_id uuid
);


--
-- Name: chips chips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chips
    ADD CONSTRAINT chips_pkey PRIMARY KEY (id);


--
-- Name: client_reports client_reports_client_id_mes_ano_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_reports
    ADD CONSTRAINT client_reports_client_id_mes_ano_key UNIQUE (client_id, mes, ano);


--
-- Name: client_reports client_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_reports
    ADD CONSTRAINT client_reports_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: openai_accounts openai_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.openai_accounts
    ADD CONSTRAINT openai_accounts_pkey PRIMARY KEY (id);


--
-- Name: idx_chips_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_chips_client_id ON public.chips USING btree (client_id);


--
-- Name: chips update_chips_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_chips_updated_at BEFORE UPDATE ON public.chips FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: clients update_clients_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON public.clients FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: chips chips_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chips
    ADD CONSTRAINT chips_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: client_reports client_reports_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_reports
    ADD CONSTRAINT client_reports_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: openai_accounts openai_accounts_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.openai_accounts
    ADD CONSTRAINT openai_accounts_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: chips Allow all for chips; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow all for chips" ON public.chips USING (true) WITH CHECK (true);


--
-- Name: client_reports Allow all for client_reports; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow all for client_reports" ON public.client_reports USING (true) WITH CHECK (true);


--
-- Name: clients Allow all for clients; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow all for clients" ON public.clients USING (true) WITH CHECK (true);


--
-- Name: openai_accounts Allow all for openai_accounts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow all for openai_accounts" ON public.openai_accounts USING (true) WITH CHECK (true);


--
-- Name: chips; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.chips ENABLE ROW LEVEL SECURITY;

--
-- Name: client_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.client_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: clients; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

--
-- Name: openai_accounts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.openai_accounts ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--


