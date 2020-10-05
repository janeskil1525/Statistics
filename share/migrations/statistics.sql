-- 1 up

create table if not exists users
(
    users_pkey serial not null,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    userid varchar not null UNIQUE,
    username varchar,
    passwd varchar not null,
    active BOOLEAN NOT NULL DEFAULT false,
    is_admin BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT users_pkey PRIMARY KEY (users_pkey)
);

create table if not exists codes
(
    codes_pkey serial not null,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    code character varying(100) NOT NULL,
    type bigint NOT NULL DEFAULT 0,
    subtype bigint NOT NULL DEFAULT 0,
    CONSTRAINT codes_pkey PRIMARY KEY (codes_pkey)
     USING INDEX TABLESPACE "webshop"
) ;

CREATE UNIQUE INDEX codes_code_type_subtype_unique
    ON public.codes(code, type, subtype);

create table if not exists codes_trans
(
    codes_trans_pkey serial not null,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    code_text text,
    languages_fkey bigint NOT NULL,
    codes_fkey bigint NOT NULL,
    CONSTRAINT codes_trans_pkey PRIMARY KEY (codes_trans_pkey),
    CONSTRAINT codes_trans_code_fkey FOREIGN KEY (codes_fkey)
       REFERENCES public.codes (codes_pkey) MATCH SIMPLE
       ON UPDATE NO ACTION
       ON DELETE NO ACTION
       DEFERRABLE,
    CONSTRAINT codes_trans_languages_fkey FOREIGN KEY (languages_fkey)
       REFERENCES public.languages (languages_pkey) MATCH SIMPLE
       ON UPDATE NO ACTION
       ON DELETE NO ACTION
       DEFERRABLE
) ;

CREATE UNIQUE INDEX languages_fkey_codes_fkey_unique
    ON public.codes_trans(languages_fkey, codes_fkey);

CREATE INDEX IF NOT EXISTS idx_codes_trans_codes_fkey
    ON public.codes_trans USING btree
        (codes_fkey, languages_fkey);

CREATE INDEX IF NOT EXISTS idx_codes_trans_codes_text
    ON public.codes_trans USING btree
        (code_text COLLATE pg_catalog."default");

CREATE INDEX IF NOT EXISTS idx_codes_code
    ON public.codes USING btree
        (code COLLATE pg_catalog."default");

create table if not exists statistics
(
    statistics_pkey serial not null,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    statistic_type bigint default 0 not null,
    statisticid character varying(100) not null,
    statistic jsonb not null,
    CONSTRAINT statistics_pkey PRIMARY KEY (statistics_pkey)
) ;

CREATE UNIQUE INDEX statistic_type_statisticid_unique
    ON public.statistics(statistic_type, statisticid);

ALTER TABLE public.statistics
    ADD COLUMN year integer DEFAULT 0;

ALTER TABLE public.statistics
    ADD COLUMN month integer DEFAULT 0;

ALTER TABLE public.statistics
    ADD COLUMN companies_fkey bigint DEFAULT 0;

ALTER TABLE public.statistics
    ADD COLUMN company varchar DEFAULT '';

CREATE  INDEX idx_statistics_year
    ON public.statistics(year);

CREATE  INDEX idx_statistics_month
    ON public.statistics(month);

CREATE  INDEX idx_statistics_companies_fkey
    ON public.statistics(companies_fkey);

CREATE  INDEX idx_statistics_company
    ON public.statistics(company);

CREATE  INDEX if not exists idx_statistics_year_month
    ON public.statistics(year,month);

create table if not exists statistics_intervals
(
    statistics_intervals_pkey serial not null,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    statistic_type bigint default 0 not null,
    year bigint not null,
    month bigint not null,
    CONSTRAINT statistics_intervals_pkey PRIMARY KEY (statistics_intervals_pkey)
) ;

CREATE UNIQUE INDEX idx_statistics_intervals_statistic_type
    ON public.statistics_intervals(year, month) ;

create table if not exists sales_statistics_basedata
(
    sales_statistics_basedata_pkey serial not null ,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    salesstats jsonb NOT NULL,
    calculated boolean NOT NULL DEFAULT false,
    CONSTRAINT pki_sales_statistics_basedata_pkey PRIMARY KEY (sales_statistics_basedata_pkey)
) ;

ALTER TABLE public.statistics
    ADD COLUMN codes1_fkey bigint  ;

ALTER TABLE public.statistics
    ADD COLUMN codes2_fkey bigint  ;

ALTER TABLE public.statistics
    ADD CONSTRAINT fki_codes1_fkey FOREIGN KEY (codes1_fkey)
        REFERENCES public.codes (codes_pkey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
CREATE INDEX fki_fki_codes1_fkey
    ON public.statistics(codes1_fkey)
    TABLESPACE webshop;

ALTER TABLE public.statistics
    ADD CONSTRAINT fki_codes2_fkey FOREIGN KEY (codes2_fkey)
        REFERENCES public.codes (codes_pkey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
CREATE INDEX fki_fki_codes2_fkey
    ON public.statistics(codes2_fkey)
    TABLESPACE webshop;

create table if not exists warehouse_pricing_stats
(
    warehouse_pricing_stats_pkey serial not null ,
    editnum bigint NOT NULL DEFAULT 1,
    insby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    insdatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    modby character varying(25) COLLATE pg_catalog."default" NOT NULL DEFAULT 'System',
    moddatetime timestamp without time zone NOT NULL DEFAULT NOW(),
    codes1_fkey bigint NOT NULL,
    codes2_fkey bigint NOT NULL ,
    maxprice numeric(15,2) NOT NULL DEFAULT 0.0,
    averageprice numeric(15,2) NOT NULL DEFAULT 0.0,
    minprice numeric(15,2)NOT NULL DEFAULT 0.0,
    quantity bigint NOT NULL DEFAULT 0,
    CONSTRAINT pki_warehouse_pricing_stats_pkey PRIMARY KEY (warehouse_pricing_stats_pkey)
) ;

ALTER TABLE public.warehouse_pricing_stats
    ADD CONSTRAINT fki_warehouse_pricing_stats_codes1_fkey FOREIGN KEY (codes1_fkey)
        REFERENCES public.codes (codes_pkey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID;
CREATE INDEX fki_fki_warehouse_pricing_stats_codes1_fkey
    ON public.warehouse_pricing_stats(codes1_fkey);

ALTER TABLE public.warehouse_pricing_stats
    ADD CONSTRAINT fki_warehouse_pricing_stats_codes2_fkey FOREIGN KEY (codes2_fkey)
        REFERENCES public.codes (codes_pkey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID;
CREATE INDEX fki_fki_warehouse_pricing_stats_codes2_fkey
    ON public.warehouse_pricing_stats(codes2_fkey) ;

-- 1 down

drop table if exists statistics;
