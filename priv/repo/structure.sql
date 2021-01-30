--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0 (Debian 13.0-1.pgdg100+1)
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dags (
    dag_id uuid NOT NULL,
    schedule character varying(255),
    enabled boolean,
    name character varying(255),
    owner character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    job_id uuid NOT NULL,
    scheduled_time timestamp(0) without time zone,
    start_time timestamp(0) without time zone,
    end_time timestamp(0) without time zone,
    status character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    dag_id uuid,
    running_tasks uuid
);


--
-- Name: running_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.running_tasks (
    task_id uuid,
    job_id uuid,
    status character varying(255),
    end_time timestamp(0) without time zone,
    start_time timestamp(0) without time zone,
    runningtask_id uuid NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    task_id uuid NOT NULL,
    name character varying(255),
    parent uuid,
    child uuid,
    dag_id uuid,
    mod character varying(255),
    fun character varying(255),
    args character varying(255)[]
);


--
-- Name: tasks_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks_tasks (
    id bigint NOT NULL,
    parent_id uuid,
    child_id uuid
);


--
-- Name: tasks_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tasks_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tasks_tasks_id_seq OWNED BY public.tasks_tasks.id;


--
-- Name: tasks_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_tasks_id_seq'::regclass);


--
-- Name: dags dags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dags
    ADD CONSTRAINT dags_pkey PRIMARY KEY (dag_id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (job_id);


--
-- Name: running_tasks running_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.running_tasks
    ADD CONSTRAINT running_tasks_pkey PRIMARY KEY (runningtask_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (task_id);


--
-- Name: tasks_tasks tasks_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_tasks
    ADD CONSTRAINT tasks_tasks_pkey PRIMARY KEY (id);


--
-- Name: dags_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dags_name_index ON public.dags USING btree (name);


--
-- Name: jobs_dag_id_scheduled_time_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX jobs_dag_id_scheduled_time_index ON public.jobs USING btree (dag_id, scheduled_time);


--
-- Name: running_tasks_job_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX running_tasks_job_index ON public.running_tasks USING btree (job_id);


--
-- Name: running_tasks_task_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX running_tasks_task_index ON public.running_tasks USING btree (task_id);


--
-- Name: tasks_tasks_child_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tasks_tasks_child_index ON public.tasks_tasks USING btree (child_id);


--
-- Name: tasks_tasks_parent_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tasks_tasks_parent_index ON public.tasks_tasks USING btree (parent_id);


--
-- Name: unique_child_and_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_child_and_parent ON public.tasks_tasks USING btree (child_id, parent_id);


--
-- Name: unique_task_per_dag; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_task_per_dag ON public.tasks USING btree (dag_id, name);


--
-- Name: unique_task_per_job; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_task_per_job ON public.running_tasks USING btree (job_id, task_id);


--
-- Name: jobs jobs_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dags(dag_id) ON DELETE CASCADE;


--
-- Name: running_tasks running_tasks_job_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.running_tasks
    ADD CONSTRAINT running_tasks_job_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(job_id) ON DELETE CASCADE;


--
-- Name: running_tasks running_tasks_task_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.running_tasks
    ADD CONSTRAINT running_tasks_task_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(task_id) ON DELETE CASCADE;


--
-- Name: tasks tasks_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dags(dag_id) ON DELETE CASCADE;


--
-- Name: tasks_tasks tasks_tasks_child_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_tasks
    ADD CONSTRAINT tasks_tasks_child_fkey FOREIGN KEY (child_id) REFERENCES public.tasks(task_id) ON DELETE CASCADE;


--
-- Name: tasks_tasks tasks_tasks_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_tasks
    ADD CONSTRAINT tasks_tasks_parent_fkey FOREIGN KEY (parent_id) REFERENCES public.tasks(task_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20201219184742);
INSERT INTO public."schema_migrations" (version) VALUES (20201219191718);
INSERT INTO public."schema_migrations" (version) VALUES (20201220105615);
INSERT INTO public."schema_migrations" (version) VALUES (20201220111742);
INSERT INTO public."schema_migrations" (version) VALUES (20201220170856);
INSERT INTO public."schema_migrations" (version) VALUES (20201220175938);
INSERT INTO public."schema_migrations" (version) VALUES (20201220211253);
INSERT INTO public."schema_migrations" (version) VALUES (20201220212749);
INSERT INTO public."schema_migrations" (version) VALUES (20201220222705);
INSERT INTO public."schema_migrations" (version) VALUES (20201220223857);
INSERT INTO public."schema_migrations" (version) VALUES (20201220233051);
INSERT INTO public."schema_migrations" (version) VALUES (20201221151301);
INSERT INTO public."schema_migrations" (version) VALUES (20201221155645);
INSERT INTO public."schema_migrations" (version) VALUES (20201221160542);
INSERT INTO public."schema_migrations" (version) VALUES (20201221170957);
INSERT INTO public."schema_migrations" (version) VALUES (20201226101555);
INSERT INTO public."schema_migrations" (version) VALUES (20210110221356);
INSERT INTO public."schema_migrations" (version) VALUES (20210110223753);
INSERT INTO public."schema_migrations" (version) VALUES (20210111222348);
INSERT INTO public."schema_migrations" (version) VALUES (20210111223432);
INSERT INTO public."schema_migrations" (version) VALUES (20210112200044);
INSERT INTO public."schema_migrations" (version) VALUES (20210112200328);
INSERT INTO public."schema_migrations" (version) VALUES (20210112200706);
INSERT INTO public."schema_migrations" (version) VALUES (20210112202344);
INSERT INTO public."schema_migrations" (version) VALUES (20210112205743);
INSERT INTO public."schema_migrations" (version) VALUES (20210113085851);
INSERT INTO public."schema_migrations" (version) VALUES (20210113091444);
INSERT INTO public."schema_migrations" (version) VALUES (20210117155809);
INSERT INTO public."schema_migrations" (version) VALUES (20210117205920);
INSERT INTO public."schema_migrations" (version) VALUES (20210117213937);
INSERT INTO public."schema_migrations" (version) VALUES (20210120191823);
