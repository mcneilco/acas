--
-- PostgreSQL database cluster dump
--

\connect postgres

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET escape_string_warning = 'off';

--
-- Roles
--

DROP ROLE apptest;
CREATE ROLE apptest;
ALTER ROLE apptest WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB LOGIN PASSWORD 'md5c7e91d2aba637c1d87e000416af77201' VALID UNTIL 'infinity';
DROP ROLE "asc";
CREATE ROLE "asc";
ALTER ROLE "asc" WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB LOGIN PASSWORD 'md5df3e6c4b0fbecc6ee25fe4d4867509b0' VALID UNTIL 'infinity';
DROP ROLE demo;
CREATE ROLE demo;
ALTER ROLE demo WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN PASSWORD 'md5c514c91e4ed341f263e458d44b3bb0a7' VALID UNTIL 'infinity';
DROP ROLE jchem;
CREATE ROLE jchem;
ALTER ROLE jchem WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB LOGIN PASSWORD 'md5ad94b1ca33d7b16b9dc314bef35d08b3' VALID UNTIL 'infinity';
DROP ROLE seurat;
CREATE ROLE seurat;
ALTER ROLE seurat WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB LOGIN PASSWORD 'md5913419931dbeddf02a29942a50bd526b' VALID UNTIL 'infinity';


--
-- PostgreSQL database dump complete
--

\connect prod

--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

--
-- Compound SCHEMA
--

DROP SCHEMA seurat;
CREATE SCHEMA seurat
       AUTHORIZATION seurat;
COMMENT ON SCHEMA seurat IS 'Seurat Schema';

SET search_path = seurat, pg_catalog;

--
-- Name: syn_compound_prop_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_compound_prop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_compound_prop_id_seq OWNER TO seurat;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: compound_properties; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE compound_properties (
    compound_prop_id bigint DEFAULT nextval('syn_compound_prop_id_seq'::regclass) NOT NULL,
    compound_cansmi character varying(4000) NOT NULL,
    compound_name character varying(45) NOT NULL,
    property_name character varying(255) NOT NULL,
    property_value character varying(4000) NOT NULL,
    property_value_type character varying(45) NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL,
    file_id bigint
);


ALTER TABLE seurat.compound_properties OWNER TO seurat;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE hibernate_sequence
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.hibernate_sequence OWNER TO seurat;

--
-- Name: ident_scheme; Type: TABLE; Schema: seurat; Owner: asc; Tablespace: 
--

CREATE TABLE ident_scheme (
    id bigint NOT NULL,
    name character varying(20) NOT NULL,
    source character varying(20),
    isvendorscheme smallint NOT NULL
);


ALTER TABLE seurat.ident_scheme OWNER TO "asc";

--
-- Name: jchemproperties; Type: TABLE; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE TABLE jchemproperties (
    prop_name character varying(200) NOT NULL,
    prop_value character varying(200),
    prop_value_ext bytea
);


ALTER TABLE seurat.jchemproperties OWNER TO jchem;

--
-- Name: jchemproperties_cr; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE jchemproperties_cr (
    cache_id character varying(32) NOT NULL,
    registration_time character varying(30) NOT NULL,
    is_protected smallint DEFAULT 0 NOT NULL
);


ALTER TABLE seurat.jchemproperties_cr OWNER TO postgres;

--
-- Name: libdes_vendor_molecules; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE libdes_vendor_molecules (
    cd_id integer NOT NULL,
    cd_structure bytea NOT NULL,
    cd_smiles character varying(1000),
    cd_formula character varying(100),
    cd_molweight double precision,
    cd_hash integer NOT NULL,
    cd_flags character varying(20),
    cd_timestamp timestamp without time zone NOT NULL,
    cd_fp1 integer NOT NULL,
    cd_fp2 integer NOT NULL,
    cd_fp3 integer NOT NULL,
    cd_fp4 integer NOT NULL,
    cd_fp5 integer NOT NULL,
    cd_fp6 integer NOT NULL,
    cd_fp7 integer NOT NULL,
    cd_fp8 integer NOT NULL,
    cd_fp9 integer NOT NULL,
    cd_fp10 integer NOT NULL,
    cd_fp11 integer NOT NULL,
    cd_fp12 integer NOT NULL,
    cd_fp13 integer NOT NULL,
    cd_fp14 integer NOT NULL,
    cd_fp15 integer NOT NULL,
    cd_fp16 integer NOT NULL,
    molname text NOT NULL,
    vendor text NOT NULL
);


ALTER TABLE seurat.libdes_vendor_molecules OWNER TO postgres;

--
-- Name: libdes_vendor_molecules_cd_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE libdes_vendor_molecules_cd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.libdes_vendor_molecules_cd_id_seq OWNER TO postgres;

--
-- Name: libdes_vendor_molecules_cd_id_seq; Type: SEQUENCE OWNED BY; Schema: seurat; Owner: postgres
--

ALTER SEQUENCE libdes_vendor_molecules_cd_id_seq OWNED BY libdes_vendor_molecules.cd_id;


--
-- Name: libdes_vendor_molecules_ul; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE libdes_vendor_molecules_ul (
    update_id integer NOT NULL,
    update_info character varying(20) NOT NULL
);


ALTER TABLE seurat.libdes_vendor_molecules_ul OWNER TO postgres;

--
-- Name: libdes_vendor_molecules_ul_update_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE libdes_vendor_molecules_ul_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.libdes_vendor_molecules_ul_update_id_seq OWNER TO postgres;

--
-- Name: libdes_vendor_molecules_ul_update_id_seq; Type: SEQUENCE OWNED BY; Schema: seurat; Owner: postgres
--

ALTER SEQUENCE libdes_vendor_molecules_ul_update_id_seq OWNED BY libdes_vendor_molecules_ul.update_id;


--
-- Name: mol_alias; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE mol_alias (
    mol_id numeric(19,0) NOT NULL,
    alias_id numeric(19,0) NOT NULL
);


ALTER TABLE seurat.mol_alias OWNER TO postgres;

--
-- Name: molecule_alias_entity; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE molecule_alias_entity (
    id numeric(19,0) NOT NULL,
    alias character varying(255),
    id_scheme_id numeric(19,0)
);


ALTER TABLE seurat.molecule_alias_entity OWNER TO postgres;

--
-- Name: molecule_part; Type: TABLE; Schema: seurat; Owner: asc; Tablespace: 
--

CREATE TABLE molecule_part (
    id numeric(19,0) NOT NULL,
    ident_scheme_id numeric(19,0),
    molname character varying(255),
    canonical_smiles character varying(4000),
    xlogp double precision,
    wlogp double precision,
    molecular_weight double precision,
    num_hbond_donors numeric(5,0),
    num_hbond_acceptors numeric(5,0),
    num_rotatable_bonds numeric(5,0),
    passed_lipinski numeric(1,0),
    passed_all_reos numeric(1,0),
    person_auth_purchase character varying(255),
    wdi_similarity_identity numeric(1,0),
    priority_of_interest double precision,
    number_of_stereocenters numeric(5,0),
    number_of_sssr_rings numeric(5,0),
    max_ring_size numeric(5,0),
    two_dim_psa double precision,
    sum_formal_charge numeric(5,0),
    count_formal_charge numeric(5,0),
    reos_bit_mask character varying(2000),
    reos_bitmask_new bit(1600),
    is_obsolete boolean,
    twodimstructblob bytea
);


ALTER TABLE seurat.molecule_part OWNER TO "asc";

--
-- Name: scaffold_class_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE scaffold_class_id_seq
    START WITH 601
    INCREMENT BY 1
    MAXVALUE 1000000000
    NO MINVALUE
    CACHE 20;


ALTER TABLE seurat.scaffold_class_id_seq OWNER TO postgres;

--
-- Name: scaffold_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE scaffold_id_seq
    START WITH 361
    INCREMENT BY 1
    MAXVALUE 1000000
    NO MINVALUE
    CACHE 20;


ALTER TABLE seurat.scaffold_id_seq OWNER TO postgres;

--
-- Name: scaffoldset_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE scaffoldset_id_seq
    START WITH 321
    INCREMENT BY 1
    MAXVALUE 1000000
    NO MINVALUE
    CACHE 20;


ALTER TABLE seurat.scaffoldset_id_seq OWNER TO postgres;

--
-- Name: scaffoldset_owner_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE scaffoldset_owner_id_seq
    START WITH 141
    INCREMENT BY 1
    MAXVALUE 10000
    NO MINVALUE
    CACHE 20;


ALTER TABLE seurat.scaffoldset_owner_id_seq OWNER TO postgres;

--
-- Name: syn_job_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_job_id_seq
    START WITH 1128
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_job_id_seq OWNER TO seurat;

--
-- Name: seurat_job; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE seurat_job (
    job_id bigint DEFAULT nextval('syn_job_id_seq'::regclass) NOT NULL
);


ALTER TABLE seurat.seurat_job OWNER TO seurat;

--
-- Name: smpc_structure; Type: TABLE; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE TABLE smpc_structure (
    cd_id integer NOT NULL,
    cd_structure bytea NOT NULL,
    cd_smiles character varying(1000),
    cd_formula character varying(100),
    cd_molweight double precision,
    cd_hash integer NOT NULL,
    cd_flags character varying(20),
    cd_timestamp timestamp without time zone NOT NULL,
    cd_fp1 integer NOT NULL,
    cd_fp2 integer NOT NULL,
    cd_fp3 integer NOT NULL,
    cd_fp4 integer NOT NULL,
    cd_fp5 integer NOT NULL,
    cd_fp6 integer NOT NULL,
    cd_fp7 integer NOT NULL,
    cd_fp8 integer NOT NULL,
    cd_fp9 integer NOT NULL,
    cd_fp10 integer NOT NULL,
    cd_fp11 integer NOT NULL,
    cd_fp12 integer NOT NULL,
    cd_fp13 integer NOT NULL,
    cd_fp14 integer NOT NULL,
    cd_fp15 integer NOT NULL,
    cd_fp16 integer NOT NULL,
    creator character varying(200) NOT NULL,
    obsoleted smallint,
    cd_sortable_formula character varying(255),
    comments character varying(4000),
    cd_pre_calculated smallint DEFAULT 0 NOT NULL
);


ALTER TABLE seurat.smpc_structure OWNER TO jchem;

--
-- Name: smpc_structure_cd_id_seq; Type: SEQUENCE; Schema: seurat; Owner: jchem
--

CREATE SEQUENCE smpc_structure_cd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.smpc_structure_cd_id_seq OWNER TO jchem;

--
-- Name: smpc_structure_cd_id_seq; Type: SEQUENCE OWNED BY; Schema: seurat; Owner: jchem
--

ALTER SEQUENCE smpc_structure_cd_id_seq OWNED BY smpc_structure.cd_id;


--
-- Name: smpc_structure_ul; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE smpc_structure_ul (
    update_id integer NOT NULL,
    update_info character varying(120) NOT NULL,
    cache_id character varying(32) NOT NULL
);


ALTER TABLE seurat.smpc_structure_ul OWNER TO postgres;

--
-- Name: smpc_structure_ul_update_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE smpc_structure_ul_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.smpc_structure_ul_update_id_seq OWNER TO postgres;

--
-- Name: smpc_structure_ul_update_id_seq; Type: SEQUENCE OWNED BY; Schema: seurat; Owner: postgres
--

ALTER SEQUENCE smpc_structure_ul_update_id_seq OWNED BY smpc_structure_ul.update_id;


--
-- Name: syn_alt_assay_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_alt_assay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_alt_assay_id_seq OWNER TO seurat;

--
-- Name: syn_assay_classification_summary; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_assay_classification_summary (
    id bigint NOT NULL,
    assay_name character varying(500) NOT NULL,
    num_results bigint,
    date_last_run date,
    project character varying(100) NOT NULL,
    assay_category character varying(100),
    area character varying(100) NOT NULL,
    assay_proj_cons character varying(100) NOT NULL,
    assay_target_cons character varying(100) NOT NULL
);


ALTER TABLE seurat.syn_assay_classification_summary OWNER TO postgres;

--
-- Name: syn_chemical_name; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_chemical_name (
    compound_id bigint NOT NULL,
    chem_name character varying(255) NOT NULL
);


ALTER TABLE seurat.syn_chemical_name OWNER TO seurat;

--
-- Name: syn_compound; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_compound (
    compound_id bigint NOT NULL,
    project_id bigint NOT NULL,
    corporate_id character varying(100) NOT NULL,
    file_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT syn_compound_noempty CHECK (((corporate_id)::text <> ''::text))
);


ALTER TABLE seurat.syn_compound OWNER TO seurat;

--
-- Name: syn_compound_lot; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_compound_lot (
    sample_id bigint NOT NULL,
    amt_prepared character varying(20),
    appearance character varying(255),
    compound_id bigint NOT NULL,
    date_prepared timestamp without time zone,
    lot_id character varying(20) DEFAULT 0 NOT NULL,
    purity real,
    salt_id bigint,
    person_id bigint,
    solubility character varying(255),
    total_formula character varying(255),
    total_weight real,
    source_id bigint,
    file_id bigint NOT NULL,
    salt_code integer,
    comments character varying(4000),
    lot_specific_id character varying(100),
    lot_and_salt_specific_id character varying(100),
    corpid_and_salt_specific_id character varying(100)
);


ALTER TABLE seurat.syn_compound_lot OWNER TO seurat;

--
-- Name: syn_compound_scaffclass; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_compound_scaffclass (
    scaffold_class_id double precision NOT NULL,
    compound_id character varying(30) NOT NULL
);


ALTER TABLE seurat.syn_compound_scaffclass OWNER TO postgres;

--
-- Name: syn_corp_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_corp_id_seq
    START WITH 35000
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_corp_id_seq OWNER TO seurat;

--
-- Name: syn_corporate_id; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_corporate_id (
    corp_id bigint DEFAULT nextval('syn_corp_id_seq'::regclass) NOT NULL
);


ALTER TABLE seurat.syn_corporate_id OWNER TO seurat;

--
-- Name: syn_document; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_document (
    id bigint NOT NULL,
    active character varying(1) NOT NULL,
    name character varying(100) NOT NULL,
    archived character varying(1) NOT NULL,
    comments character varying(255) NOT NULL,
    creation_date timestamp without time zone NOT NULL,
    closeout_date timestamp without time zone,
    last_modified_by character varying(20) NOT NULL,
    last_modified_date timestamp without time zone DEFAULT now() NOT NULL,
    doc_location character varying(45) NOT NULL,
    microfilm_date timestamp without time zone,
    project_name character varying(45) NOT NULL,
    person_id bigint NOT NULL,
    doc_version character varying(255),
    file_id bigint
);


ALTER TABLE seurat.syn_document OWNER TO seurat;

--
-- Name: syn_file_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_file_id_seq OWNER TO seurat;

--
-- Name: syn_file; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_file (
    file_id bigint DEFAULT nextval('syn_file_id_seq'::regclass) NOT NULL,
    file_name character varying(4000) NOT NULL,
    file_date timestamp without time zone DEFAULT now() NOT NULL,
    project_id bigint NOT NULL,
    bit_mask bit(1600)
);


ALTER TABLE seurat.syn_file OWNER TO seurat;

--
-- Name: syn_observation; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_observation (
    id bigint NOT NULL,
    observed_item_id bigint NOT NULL,
    primary_groupno bigint NOT NULL,
    comments character varying(255),
    quantity_conc_unit bigint,
    quantity_conc double precision,
    secondary_groupno_date timestamp without time zone DEFAULT now() NOT NULL,
    secondary_groupno bigint NOT NULL,
    document_page character varying(100) DEFAULT 0 NOT NULL,
    obs_operator character varying(4),
    document_id bigint DEFAULT 0 NOT NULL,
    cat_obs_phenomenon character varying(1024),
    quantity double precision,
    quantity_std_dev double precision,
    protocol_id bigint NOT NULL,
    type_id bigint NOT NULL,
    unit_id bigint NOT NULL,
    file_id bigint NOT NULL,
    document_version character varying(30)
);


ALTER TABLE seurat.syn_observation OWNER TO seurat;

--
-- Name: syn_observation_protocol; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_observation_protocol (
    id bigint NOT NULL,
    comments character varying(255),
    description character varying(255),
    person_id bigint NOT NULL,
    version_num character varying(20) NOT NULL,
    phenomenon_type_id bigint NOT NULL,
    file_id bigint NOT NULL
);


ALTER TABLE seurat.syn_observation_protocol OWNER TO seurat;

--
-- Name: syn_observation_type; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_observation_type (
    id bigint NOT NULL,
    name character varying(80) NOT NULL,
    description character varying(255)
);


ALTER TABLE seurat.syn_observation_type OWNER TO seurat;

--
-- Name: syn_observation_unit; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_observation_unit (
    id bigint NOT NULL,
    label character varying(10) NOT NULL,
    description character varying(255),
    compound_unit_id bigint
);


ALTER TABLE seurat.syn_observation_unit OWNER TO seurat;

--
-- Name: syn_person; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_person (
    id bigint NOT NULL,
    name character varying(45) NOT NULL,
    address character varying(1000),
    occupation character varying(255),
    supervisor character varying(255)
);


ALTER TABLE seurat.syn_person OWNER TO seurat;

--
-- Name: syn_phenomenon_type; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_phenomenon_type (
    id bigint NOT NULL,
    name character varying(1024) NOT NULL,
    description character varying(255),
    phenom_comment character varying(255)
);


ALTER TABLE seurat.syn_phenomenon_type OWNER TO seurat;

--
-- Name: syn_project_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_project_id_seq OWNER TO seurat;

--
-- Name: syn_project; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_project (
    project_id bigint DEFAULT nextval('syn_project_id_seq'::regclass) NOT NULL,
    active character varying(1) NOT NULL,
    alternate_id character varying(20) NOT NULL,
    project_desc character varying(255) NOT NULL,
    project_name character varying(45) NOT NULL
);


ALTER TABLE seurat.syn_project OWNER TO seurat;

--
-- Name: syn_salt_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_salt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_salt_id_seq OWNER TO seurat;

--
-- Name: syn_salt; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_salt (
    salt_id bigint DEFAULT nextval('syn_salt_id_seq'::regclass) NOT NULL,
    salt_name character varying(45) NOT NULL,
    salt_code integer
);


ALTER TABLE seurat.syn_salt OWNER TO seurat;

--
-- Name: syn_sample_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_sample_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_sample_id_seq OWNER TO seurat;

--
-- Name: syn_sample; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_sample (
    sample_id bigint DEFAULT nextval('syn_sample_id_seq'::regclass) NOT NULL,
    alias_id character varying(100),
    alternate_id character varying(100) NOT NULL,
    data1 character varying(255),
    document_id bigint NOT NULL,
    document_page character varying(100) DEFAULT 0 NOT NULL,
    reg_date timestamp without time zone DEFAULT now() NOT NULL,
    file_id bigint NOT NULL
);


ALTER TABLE seurat.syn_sample OWNER TO seurat;

--
-- Name: syn_scaffold; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_scaffold (
    scaffold_id double precision NOT NULL,
    scaffoldset_id double precision NOT NULL,
    scaffold_name character varying(40) NOT NULL,
    scaffold_rule character varying(2000),
    created_by character varying(25) NOT NULL,
    date_created date NOT NULL,
    updated_by character varying(25),
    date_updated date,
    scaffold_desc character varying(2000) NOT NULL
);


ALTER TABLE seurat.syn_scaffold OWNER TO postgres;

--
-- Name: syn_scaffold_class; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_scaffold_class (
    scaffold_class_id double precision NOT NULL,
    scaffold_id double precision NOT NULL,
    scaffold_class_name character varying(15) NOT NULL,
    scaffold_class_structure character varying(1000),
    scaffold_class_desc character varying(2000) NOT NULL,
    scaffold_class_rule character varying(2000)
);


ALTER TABLE seurat.syn_scaffold_class OWNER TO postgres;

--
-- Name: syn_scaffoldset; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_scaffoldset (
    scaffoldset_id double precision NOT NULL,
    owner_id double precision NOT NULL,
    scaffoldset_name character varying(40) NOT NULL,
    date_created date NOT NULL,
    date_updated date NOT NULL,
    updated_by character varying(25) DEFAULT 1,
    status double precision NOT NULL
);


ALTER TABLE seurat.syn_scaffoldset OWNER TO postgres;

--
-- Name: syn_scaffoldset_owner; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_scaffoldset_owner (
    owner_id double precision NOT NULL,
    owner_name character varying(25) NOT NULL,
    owner_type character(1) NOT NULL,
    owner_full_name character varying(50) NOT NULL,
    CONSTRAINT type CHECK (((owner_type = 'P'::bpchar) OR (owner_type = 'U'::bpchar)))
);


ALTER TABLE seurat.syn_scaffoldset_owner OWNER TO postgres;

--
-- Name: syn_source_id_seq; Type: SEQUENCE; Schema: seurat; Owner: seurat
--

CREATE SEQUENCE syn_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_source_id_seq OWNER TO seurat;

--
-- Name: syn_source; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_source (
    source_id bigint DEFAULT nextval('syn_source_id_seq'::regclass) NOT NULL,
    company_name character varying(255) NOT NULL
);


ALTER TABLE seurat.syn_source OWNER TO seurat;

--
-- Name: syn_structure; Type: TABLE; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE TABLE syn_structure (
    cd_id integer NOT NULL,
    cd_structure bytea NOT NULL,
    cd_smiles character varying(1000),
    cd_formula character varying(100),
    cd_molweight double precision,
    cd_hash integer NOT NULL,
    cd_flags character varying(20),
    cd_timestamp timestamp without time zone NOT NULL,
    cd_fp1 integer NOT NULL,
    cd_fp2 integer NOT NULL,
    cd_fp3 integer NOT NULL,
    cd_fp4 integer NOT NULL,
    cd_fp5 integer NOT NULL,
    cd_fp6 integer NOT NULL,
    cd_fp7 integer NOT NULL,
    cd_fp8 integer NOT NULL,
    cd_fp9 integer NOT NULL,
    cd_fp10 integer NOT NULL,
    cd_fp11 integer NOT NULL,
    cd_fp12 integer NOT NULL,
    cd_fp13 integer NOT NULL,
    cd_fp14 integer NOT NULL,
    cd_fp15 integer NOT NULL,
    cd_fp16 integer NOT NULL,
    creator character varying(100) NOT NULL,
    cd_sortable_formula character varying(255),
    cd_pre_calculated smallint DEFAULT 0 NOT NULL
);


ALTER TABLE seurat.syn_structure OWNER TO jchem;

--
-- Name: syn_structure_cd_id_seq; Type: SEQUENCE; Schema: seurat; Owner: jchem
--

CREATE SEQUENCE syn_structure_cd_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_structure_cd_id_seq OWNER TO jchem;

--
-- Name: syn_structure_cd_id_seq; Type: SEQUENCE OWNED BY; Schema: seurat; Owner: jchem
--

ALTER SEQUENCE syn_structure_cd_id_seq OWNED BY syn_structure.cd_id;


--
-- Name: syn_structure_ul; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_structure_ul (
    update_id integer NOT NULL,
    update_info character varying(120) NOT NULL,
    cache_id character varying(32) NOT NULL
);


ALTER TABLE seurat.syn_structure_ul OWNER TO postgres;

--
-- Name: syn_structure_ul_update_id_seq; Type: SEQUENCE; Schema: seurat; Owner: postgres
--

CREATE SEQUENCE syn_structure_ul_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE seurat.syn_structure_ul_update_id_seq OWNER TO postgres;

--
-- Name: syn_structure_ul_update_id_seq; Type: SEQUENCE OWNED BY; Schema: seurat; Owner: postgres
--

ALTER SEQUENCE syn_structure_ul_update_id_seq OWNED BY syn_structure_ul.update_id;


--
-- Name: syn_therapeutic_area; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_therapeutic_area (
    id bigint NOT NULL,
    name character varying(500) NOT NULL,
    description character varying(4000)
);


ALTER TABLE seurat.syn_therapeutic_area OWNER TO postgres;

--
-- Name: syn_well_info; Type: TABLE; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE TABLE syn_well_info (
    id bigint NOT NULL,
    observation_id bigint NOT NULL,
    conc double precision NOT NULL,
    result double precision NOT NULL,
    result_type character varying(255),
    result_flag integer DEFAULT 0 NOT NULL,
    result_stddev double precision,
    result_n integer,
    file_id bigint
);


ALTER TABLE seurat.syn_well_info OWNER TO seurat;

--
-- Name: cd_id; Type: DEFAULT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY libdes_vendor_molecules ALTER COLUMN cd_id SET DEFAULT nextval('libdes_vendor_molecules_cd_id_seq'::regclass);


--
-- Name: update_id; Type: DEFAULT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY libdes_vendor_molecules_ul ALTER COLUMN update_id SET DEFAULT nextval('libdes_vendor_molecules_ul_update_id_seq'::regclass);


--
-- Name: cd_id; Type: DEFAULT; Schema: seurat; Owner: jchem
--

ALTER TABLE ONLY smpc_structure ALTER COLUMN cd_id SET DEFAULT nextval('smpc_structure_cd_id_seq'::regclass);


--
-- Name: update_id; Type: DEFAULT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY smpc_structure_ul ALTER COLUMN update_id SET DEFAULT nextval('smpc_structure_ul_update_id_seq'::regclass);


--
-- Name: cd_id; Type: DEFAULT; Schema: seurat; Owner: jchem
--

ALTER TABLE ONLY syn_structure ALTER COLUMN cd_id SET DEFAULT nextval('syn_structure_cd_id_seq'::regclass);


--
-- Name: update_id; Type: DEFAULT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY syn_structure_ul ALTER COLUMN update_id SET DEFAULT nextval('syn_structure_ul_update_id_seq'::regclass);


--
-- Name: cache_2008224201_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY jchemproperties_cr
    ADD CONSTRAINT cache_2008224201_pk PRIMARY KEY (cache_id);


--
-- Name: compound_prop_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY compound_properties
    ADD CONSTRAINT compound_prop_id_pk PRIMARY KEY (compound_prop_id);


--
-- Name: doc_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_document
    ADD CONSTRAINT doc_name_unique_cons UNIQUE (name);


--
-- Name: ident_scheme_pkey; Type: CONSTRAINT; Schema: seurat; Owner: asc; Tablespace: 
--

ALTER TABLE ONLY ident_scheme
    ADD CONSTRAINT ident_scheme_pkey PRIMARY KEY (id);


--
-- Name: jchemproperties_pkey; Type: CONSTRAINT; Schema: seurat; Owner: jchem; Tablespace: 
--

ALTER TABLE ONLY jchemproperties
    ADD CONSTRAINT jchemproperties_pkey PRIMARY KEY (prop_name);


--
-- Name: libdes_vendor_molecules_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY libdes_vendor_molecules
    ADD CONSTRAINT libdes_vendor_molecules_pkey PRIMARY KEY (cd_id);


--
-- Name: libdes_vendor_molecules_ul_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY libdes_vendor_molecules_ul
    ADD CONSTRAINT libdes_vendor_molecules_ul_pkey PRIMARY KEY (update_id);


--
-- Name: mol_alias_comp_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mol_alias
    ADD CONSTRAINT mol_alias_comp_pk PRIMARY KEY (mol_id, alias_id);


--
-- Name: molecule_alias_entity_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY molecule_alias_entity
    ADD CONSTRAINT molecule_alias_entity_id_pk PRIMARY KEY (id);


--
-- Name: molecule_part_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: asc; Tablespace: 
--

ALTER TABLE ONLY molecule_part
    ADD CONSTRAINT molecule_part_id_pk PRIMARY KEY (id);


--
-- Name: owner_name_unique; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffoldset_owner
    ADD CONSTRAINT owner_name_unique UNIQUE (owner_name);


--
-- Name: scaffold_class_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffold_class
    ADD CONSTRAINT scaffold_class_pkey PRIMARY KEY (scaffold_class_id);


--
-- Name: scaffold_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffold
    ADD CONSTRAINT scaffold_pkey PRIMARY KEY (scaffold_id);


--
-- Name: scaffoldset_owner_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffoldset_owner
    ADD CONSTRAINT scaffoldset_owner_pkey PRIMARY KEY (owner_id);


--
-- Name: scaffoldset_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffoldset
    ADD CONSTRAINT scaffoldset_pkey PRIMARY KEY (scaffoldset_id);


--
-- Name: smpc_structure_pkey; Type: CONSTRAINT; Schema: seurat; Owner: jchem; Tablespace: 
--

ALTER TABLE ONLY smpc_structure
    ADD CONSTRAINT smpc_structure_pkey PRIMARY KEY (cd_id);


--
-- Name: smpc_structure_ul_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smpc_structure_ul
    ADD CONSTRAINT smpc_structure_ul_pkey PRIMARY KEY (update_id);


--
-- Name: syn_assay_class_sum_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_assay_classification_summary
    ADD CONSTRAINT syn_assay_class_sum_pk PRIMARY KEY (id);


--
-- Name: syn_chemical_name_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_chemical_name
    ADD CONSTRAINT syn_chemical_name_pk PRIMARY KEY (compound_id, chem_name);


--
-- Name: syn_cmpnd_scaffclass_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_compound_scaffclass
    ADD CONSTRAINT syn_cmpnd_scaffclass_pk PRIMARY KEY (compound_id, scaffold_class_id);


--
-- Name: syn_compound_lot_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_compound_lot
    ADD CONSTRAINT syn_compound_lot_pk PRIMARY KEY (sample_id);


--
-- Name: syn_compound_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_compound
    ADD CONSTRAINT syn_compound_pk PRIMARY KEY (compound_id, project_id);


--
-- Name: syn_document_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_document
    ADD CONSTRAINT syn_document_id_pk PRIMARY KEY (id);


--
-- Name: syn_file_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_file
    ADD CONSTRAINT syn_file_id_pk PRIMARY KEY (file_id);


--
-- Name: syn_file_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_file
    ADD CONSTRAINT syn_file_name_unique_cons UNIQUE (file_name);


--
-- Name: syn_job_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY seurat_job
    ADD CONSTRAINT syn_job_id_pk PRIMARY KEY (job_id);


--
-- Name: syn_obs_type_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_observation_type
    ADD CONSTRAINT syn_obs_type_name_unique_cons UNIQUE (name);


--
-- Name: syn_obs_unit_label_unique_conc; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_observation_unit
    ADD CONSTRAINT syn_obs_unit_label_unique_conc UNIQUE (label);


--
-- Name: syn_observation_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_pk PRIMARY KEY (id);


--
-- Name: syn_observation_protocol_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_observation_protocol
    ADD CONSTRAINT syn_observation_protocol_id_pk PRIMARY KEY (id);


--
-- Name: syn_observation_type_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_observation_type
    ADD CONSTRAINT syn_observation_type_pk PRIMARY KEY (id);


--
-- Name: syn_person_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_person
    ADD CONSTRAINT syn_person_id_pk PRIMARY KEY (id);


--
-- Name: syn_person_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_person
    ADD CONSTRAINT syn_person_name_unique_cons UNIQUE (name);


--
-- Name: syn_phen_type_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_phenomenon_type
    ADD CONSTRAINT syn_phen_type_name_unique_cons UNIQUE (name);


--
-- Name: syn_phenomenon_type_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_phenomenon_type
    ADD CONSTRAINT syn_phenomenon_type_id_pk PRIMARY KEY (id);


--
-- Name: syn_proj_name_unqiue_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_project
    ADD CONSTRAINT syn_proj_name_unqiue_cons UNIQUE (project_name);


--
-- Name: syn_project_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_project
    ADD CONSTRAINT syn_project_id_pk PRIMARY KEY (project_id);


--
-- Name: syn_salt_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_salt
    ADD CONSTRAINT syn_salt_id_pk PRIMARY KEY (salt_id);


--
-- Name: syn_salt_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_salt
    ADD CONSTRAINT syn_salt_name_unique_cons UNIQUE (salt_name);


--
-- Name: syn_sample_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_sample
    ADD CONSTRAINT syn_sample_id_pk PRIMARY KEY (sample_id);


--
-- Name: syn_source_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_source
    ADD CONSTRAINT syn_source_id_pk PRIMARY KEY (source_id);


--
-- Name: syn_source_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_source
    ADD CONSTRAINT syn_source_name_unique_cons UNIQUE (company_name);


--
-- Name: syn_structure_pkey; Type: CONSTRAINT; Schema: seurat; Owner: jchem; Tablespace: 
--

ALTER TABLE ONLY syn_structure
    ADD CONSTRAINT syn_structure_pkey PRIMARY KEY (cd_id);


--
-- Name: syn_structure_ul_pkey; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_structure_ul
    ADD CONSTRAINT syn_structure_ul_pkey PRIMARY KEY (update_id);


--
-- Name: syn_ther_area_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_therapeutic_area
    ADD CONSTRAINT syn_ther_area_name_unique_cons UNIQUE (name);


--
-- Name: syn_therapeutic_area_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_therapeutic_area
    ADD CONSTRAINT syn_therapeutic_area_pk PRIMARY KEY (id);


--
-- Name: syn_unit_id_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_observation_unit
    ADD CONSTRAINT syn_unit_id_pk PRIMARY KEY (id);


--
-- Name: syn_well_info_pk; Type: CONSTRAINT; Schema: seurat; Owner: seurat; Tablespace: 
--

ALTER TABLE ONLY syn_well_info
    ADD CONSTRAINT syn_well_info_pk PRIMARY KEY (id);


--
-- Name: unique_scaffold_class; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffold_class
    ADD CONSTRAINT unique_scaffold_class UNIQUE (scaffold_id, scaffold_class_name);


--
-- Name: unique_scaffoldset; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_scaffoldset
    ADD CONSTRAINT unique_scaffoldset UNIQUE (owner_id, scaffoldset_name);


--
-- Name: libdes_vendor_molecules_hx; Type: INDEX; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE INDEX libdes_vendor_molecules_hx ON libdes_vendor_molecules USING btree (cd_hash);


--
-- Name: smpc_structure_cx; Type: INDEX; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE INDEX smpc_structure_cx ON smpc_structure_ul USING btree (cache_id);


--
-- Name: smpc_structure_fx; Type: INDEX; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE INDEX smpc_structure_fx ON smpc_structure USING btree (cd_sortable_formula);


--
-- Name: smpc_structure_hx; Type: INDEX; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE INDEX smpc_structure_hx ON smpc_structure USING btree (cd_hash);


--
-- Name: smpc_structure_px; Type: INDEX; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE INDEX smpc_structure_px ON smpc_structure USING btree (cd_pre_calculated);


--
-- Name: syn_compound_unique_idx; Type: INDEX; Schema: seurat; Owner: seurat; Tablespace: 
--

CREATE UNIQUE INDEX syn_compound_unique_idx ON syn_compound USING btree (corporate_id);


--
-- Name: syn_structure_cx; Type: INDEX; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE INDEX syn_structure_cx ON syn_structure_ul USING btree (cache_id);


--
-- Name: syn_structure_fx; Type: INDEX; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE INDEX syn_structure_fx ON syn_structure USING btree (cd_sortable_formula);


--
-- Name: syn_structure_hx; Type: INDEX; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE INDEX syn_structure_hx ON syn_structure USING btree (cd_hash);


--
-- Name: syn_structure_px; Type: INDEX; Schema: seurat; Owner: jchem; Tablespace: 
--

CREATE INDEX syn_structure_px ON syn_structure USING btree (cd_pre_calculated);


--
-- Name: scaffold_class_scaffold_id_fkey; Type: FK CONSTRAINT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY syn_scaffold_class
    ADD CONSTRAINT scaffold_class_scaffold_id_fkey FOREIGN KEY (scaffold_id) REFERENCES syn_scaffold(scaffold_id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: scaffold_scaffoldset_id_fkey; Type: FK CONSTRAINT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY syn_scaffold
    ADD CONSTRAINT scaffold_scaffoldset_id_fkey FOREIGN KEY (scaffoldset_id) REFERENCES syn_scaffoldset(scaffoldset_id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: scaffoldset_owner_id_fkey; Type: FK CONSTRAINT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY syn_scaffoldset
    ADD CONSTRAINT scaffoldset_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES syn_scaffoldset_owner(owner_id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: syn_assay_class_sum_aname_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY syn_assay_classification_summary
    ADD CONSTRAINT syn_assay_class_sum_aname_fk FOREIGN KEY (assay_name) REFERENCES syn_phenomenon_type(name);


--
-- Name: syn_chemical_name_compound_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_chemical_name
    ADD CONSTRAINT syn_chemical_name_compound_id_fk FOREIGN KEY (compound_id) REFERENCES syn_structure(cd_id);


--
-- Name: syn_cmpnd_scaffclass_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: postgres
--

ALTER TABLE ONLY syn_compound_scaffclass
    ADD CONSTRAINT syn_cmpnd_scaffclass_fk FOREIGN KEY (scaffold_class_id) REFERENCES syn_scaffold_class(scaffold_class_id) ON DELETE CASCADE;


--
-- Name: syn_compound_file_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound
    ADD CONSTRAINT syn_compound_file_fk FOREIGN KEY (file_id) REFERENCES syn_file(file_id);


--
-- Name: syn_compound_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound
    ADD CONSTRAINT syn_compound_id_fk FOREIGN KEY (compound_id) REFERENCES syn_structure(cd_id);


--
-- Name: syn_compound_lot_compound_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound_lot
    ADD CONSTRAINT syn_compound_lot_compound_id_fk FOREIGN KEY (compound_id) REFERENCES syn_structure(cd_id);


--
-- Name: syn_compound_lot_file_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound_lot
    ADD CONSTRAINT syn_compound_lot_file_id_fk FOREIGN KEY (file_id) REFERENCES syn_file(file_id);


--
-- Name: syn_compound_lot_person_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound_lot
    ADD CONSTRAINT syn_compound_lot_person_id_fk FOREIGN KEY (person_id) REFERENCES syn_person(id);


--
-- Name: syn_compound_lot_salt_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound_lot
    ADD CONSTRAINT syn_compound_lot_salt_id_fk FOREIGN KEY (salt_id) REFERENCES syn_salt(salt_id);


--
-- Name: syn_compound_lot_source_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound_lot
    ADD CONSTRAINT syn_compound_lot_source_id_fk FOREIGN KEY (source_id) REFERENCES syn_source(source_id);


--
-- Name: syn_compound_project_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_compound
    ADD CONSTRAINT syn_compound_project_fk FOREIGN KEY (project_id) REFERENCES syn_project(project_id);


--
-- Name: syn_document_person_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_document
    ADD CONSTRAINT syn_document_person_id_fk FOREIGN KEY (person_id) REFERENCES syn_person(id);


--
-- Name: syn_obs_protocol_file_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation_protocol
    ADD CONSTRAINT syn_obs_protocol_file_id_fk FOREIGN KEY (file_id) REFERENCES syn_file(file_id);


--
-- Name: syn_obs_protocol_person_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation_protocol
    ADD CONSTRAINT syn_obs_protocol_person_id_fk FOREIGN KEY (person_id) REFERENCES syn_person(id);


--
-- Name: syn_obs_protocol_phenom_type_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation_protocol
    ADD CONSTRAINT syn_obs_protocol_phenom_type_id_fk FOREIGN KEY (phenomenon_type_id) REFERENCES syn_phenomenon_type(id);


--
-- Name: syn_observation_document_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_document_id_fk FOREIGN KEY (document_id) REFERENCES syn_document(id);


--
-- Name: syn_observation_file_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_file_id_fk FOREIGN KEY (file_id) REFERENCES syn_file(file_id);


--
-- Name: syn_observation_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_well_info
    ADD CONSTRAINT syn_observation_id_fk FOREIGN KEY (observation_id) REFERENCES syn_observation(id);


--
-- Name: syn_observation_obs_conc_unit_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_obs_conc_unit_fk FOREIGN KEY (quantity_conc_unit) REFERENCES syn_observation_unit(id);


--
-- Name: syn_observation_obs_protocol_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_obs_protocol_fk FOREIGN KEY (protocol_id) REFERENCES syn_observation_protocol(id);


--
-- Name: syn_observation_obs_type_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_obs_type_fk FOREIGN KEY (type_id) REFERENCES syn_observation_type(id);


--
-- Name: syn_observation_obs_unit_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_obs_unit_fk FOREIGN KEY (unit_id) REFERENCES syn_observation_unit(id);


--
-- Name: syn_observation_sample_id_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_observation
    ADD CONSTRAINT syn_observation_sample_id_fk FOREIGN KEY (observed_item_id) REFERENCES syn_sample(sample_id);


--
-- Name: syn_sample_document_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_sample
    ADD CONSTRAINT syn_sample_document_fk FOREIGN KEY (document_id) REFERENCES syn_document(id);


--
-- Name: syn_sample_file_fk; Type: FK CONSTRAINT; Schema: seurat; Owner: seurat
--

ALTER TABLE ONLY syn_sample
    ADD CONSTRAINT syn_sample_file_fk FOREIGN KEY (file_id) REFERENCES syn_file(file_id);


--
-- Name: seurat; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA seurat FROM seurat;
REVOKE ALL ON SCHEMA seurat FROM postgres;
GRANT ALL ON SCHEMA seurat TO postgres;
GRANT ALL ON SCHEMA seurat TO seurat;
GRANT ALL ON SCHEMA seurat TO seurat;


--
-- Name: syn_compound_prop_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_compound_prop_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_compound_prop_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_compound_prop_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_compound_prop_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_compound_prop_id_seq TO seurat;


--
-- Name: compound_properties; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE compound_properties FROM seurat;
REVOKE ALL ON TABLE compound_properties FROM seurat;
GRANT ALL ON TABLE compound_properties TO seurat;
GRANT ALL ON TABLE compound_properties TO seurat;
GRANT ALL ON TABLE compound_properties TO demo;
GRANT ALL ON TABLE compound_properties TO seurat;


--
-- Name: hibernate_sequence; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE hibernate_sequence FROM seurat;
REVOKE ALL ON SEQUENCE hibernate_sequence FROM seurat;
GRANT ALL ON SEQUENCE hibernate_sequence TO seurat;
GRANT ALL ON SEQUENCE hibernate_sequence TO demo;
GRANT ALL ON SEQUENCE hibernate_sequence TO seurat;


--
-- Name: ident_scheme; Type: ACL; Schema: seurat; Owner: asc
--

REVOKE ALL ON TABLE ident_scheme FROM seurat;
REVOKE ALL ON TABLE ident_scheme FROM "asc";
GRANT ALL ON TABLE ident_scheme TO "asc";
GRANT ALL ON TABLE ident_scheme TO seurat;
GRANT ALL ON TABLE ident_scheme TO demo;
GRANT ALL ON TABLE ident_scheme TO seurat;


--
-- Name: jchemproperties; Type: ACL; Schema: seurat; Owner: jchem
--

REVOKE ALL ON TABLE jchemproperties FROM seurat;
REVOKE ALL ON TABLE jchemproperties FROM jchem;
GRANT ALL ON TABLE jchemproperties TO jchem;
GRANT ALL ON TABLE jchemproperties TO seurat;
GRANT ALL ON TABLE jchemproperties TO "asc";
GRANT ALL ON TABLE jchemproperties TO seurat;
GRANT ALL ON TABLE jchemproperties TO demo;
GRANT ALL ON TABLE jchemproperties TO seurat;


--
-- Name: jchemproperties_cr; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE jchemproperties_cr FROM seurat;
REVOKE ALL ON TABLE jchemproperties_cr FROM postgres;
GRANT ALL ON TABLE jchemproperties_cr TO postgres;
GRANT ALL ON TABLE jchemproperties_cr TO jchem;
GRANT ALL ON TABLE jchemproperties_cr TO seurat;
GRANT ALL ON TABLE jchemproperties_cr TO seurat;
GRANT ALL ON TABLE jchemproperties_cr TO demo;
GRANT ALL ON TABLE jchemproperties_cr TO seurat;


--
-- Name: libdes_vendor_molecules; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE libdes_vendor_molecules FROM seurat;
REVOKE ALL ON TABLE libdes_vendor_molecules FROM postgres;
GRANT ALL ON TABLE libdes_vendor_molecules TO postgres;
GRANT ALL ON TABLE libdes_vendor_molecules TO "asc";
GRANT ALL ON TABLE libdes_vendor_molecules TO seurat;
GRANT ALL ON TABLE libdes_vendor_molecules TO demo;
GRANT ALL ON TABLE libdes_vendor_molecules TO seurat;


--
-- Name: libdes_vendor_molecules_cd_id_seq; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON SEQUENCE libdes_vendor_molecules_cd_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE libdes_vendor_molecules_cd_id_seq FROM postgres;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_cd_id_seq TO postgres;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_cd_id_seq TO seurat WITH GRANT OPTION;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_cd_id_seq TO demo;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_cd_id_seq TO seurat;


--
-- Name: libdes_vendor_molecules_ul; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE libdes_vendor_molecules_ul FROM seurat;
REVOKE ALL ON TABLE libdes_vendor_molecules_ul FROM postgres;
GRANT ALL ON TABLE libdes_vendor_molecules_ul TO postgres;
GRANT ALL ON TABLE libdes_vendor_molecules_ul TO "asc";
GRANT ALL ON TABLE libdes_vendor_molecules_ul TO seurat;
GRANT ALL ON TABLE libdes_vendor_molecules_ul TO demo;
GRANT ALL ON TABLE libdes_vendor_molecules_ul TO seurat;


--
-- Name: libdes_vendor_molecules_ul_update_id_seq; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON SEQUENCE libdes_vendor_molecules_ul_update_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE libdes_vendor_molecules_ul_update_id_seq FROM postgres;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_ul_update_id_seq TO postgres;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_ul_update_id_seq TO seurat WITH GRANT OPTION;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_ul_update_id_seq TO demo;
GRANT ALL ON SEQUENCE libdes_vendor_molecules_ul_update_id_seq TO seurat;


--
-- Name: mol_alias; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE mol_alias FROM seurat;
REVOKE ALL ON TABLE mol_alias FROM postgres;
GRANT ALL ON TABLE mol_alias TO postgres;
GRANT ALL ON TABLE mol_alias TO seurat;
GRANT ALL ON TABLE mol_alias TO demo;
GRANT ALL ON TABLE mol_alias TO seurat;


--
-- Name: molecule_alias_entity; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE molecule_alias_entity FROM seurat;
REVOKE ALL ON TABLE molecule_alias_entity FROM postgres;
GRANT ALL ON TABLE molecule_alias_entity TO postgres;
GRANT ALL ON TABLE molecule_alias_entity TO seurat;
GRANT ALL ON TABLE molecule_alias_entity TO demo;
GRANT ALL ON TABLE molecule_alias_entity TO seurat;


--
-- Name: molecule_part; Type: ACL; Schema: seurat; Owner: asc
--

REVOKE ALL ON TABLE molecule_part FROM seurat;
REVOKE ALL ON TABLE molecule_part FROM "asc";
GRANT ALL ON TABLE molecule_part TO "asc";
GRANT ALL ON TABLE molecule_part TO seurat;
GRANT ALL ON TABLE molecule_part TO demo;
GRANT ALL ON TABLE molecule_part TO seurat;


--
-- Name: scaffold_class_id_seq; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON SEQUENCE scaffold_class_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE scaffold_class_id_seq FROM postgres;
GRANT ALL ON SEQUENCE scaffold_class_id_seq TO postgres;
GRANT ALL ON SEQUENCE scaffold_class_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffold_class_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffold_class_id_seq TO demo;


--
-- Name: scaffold_id_seq; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON SEQUENCE scaffold_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE scaffold_id_seq FROM postgres;
GRANT ALL ON SEQUENCE scaffold_id_seq TO postgres;
GRANT ALL ON SEQUENCE scaffold_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffold_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffold_id_seq TO demo;


--
-- Name: scaffoldset_id_seq; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON SEQUENCE scaffoldset_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE scaffoldset_id_seq FROM postgres;
GRANT ALL ON SEQUENCE scaffoldset_id_seq TO postgres;
GRANT ALL ON SEQUENCE scaffoldset_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffoldset_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffoldset_id_seq TO demo;


--
-- Name: scaffoldset_owner_id_seq; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON SEQUENCE scaffoldset_owner_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE scaffoldset_owner_id_seq FROM postgres;
GRANT ALL ON SEQUENCE scaffoldset_owner_id_seq TO postgres;
GRANT ALL ON SEQUENCE scaffoldset_owner_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffoldset_owner_id_seq TO seurat;
GRANT ALL ON SEQUENCE scaffoldset_owner_id_seq TO demo;


--
-- Name: syn_job_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_job_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_job_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_job_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_job_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_job_id_seq TO seurat;


--
-- Name: seurat_job; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE seurat_job FROM seurat;
REVOKE ALL ON TABLE seurat_job FROM seurat;
GRANT ALL ON TABLE seurat_job TO seurat;
GRANT ALL ON TABLE seurat_job TO seurat;
GRANT ALL ON TABLE seurat_job TO demo;
GRANT ALL ON TABLE seurat_job TO seurat;


--
-- Name: smpc_structure; Type: ACL; Schema: seurat; Owner: jchem
--

REVOKE ALL ON TABLE smpc_structure FROM seurat;
REVOKE ALL ON TABLE smpc_structure FROM jchem;
GRANT ALL ON TABLE smpc_structure TO jchem;
GRANT ALL ON TABLE smpc_structure TO seurat;
GRANT ALL ON TABLE smpc_structure TO seurat;
GRANT ALL ON TABLE smpc_structure TO demo;
GRANT ALL ON TABLE smpc_structure TO seurat;


--
-- Name: smpc_structure_cd_id_seq; Type: ACL; Schema: seurat; Owner: jchem
--

REVOKE ALL ON SEQUENCE smpc_structure_cd_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE smpc_structure_cd_id_seq FROM jchem;
GRANT ALL ON SEQUENCE smpc_structure_cd_id_seq TO jchem;
GRANT ALL ON SEQUENCE smpc_structure_cd_id_seq TO seurat WITH GRANT OPTION;
GRANT ALL ON SEQUENCE smpc_structure_cd_id_seq TO demo;
GRANT ALL ON SEQUENCE smpc_structure_cd_id_seq TO seurat;


--
-- Name: smpc_structure_ul; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE smpc_structure_ul FROM seurat;
REVOKE ALL ON TABLE smpc_structure_ul FROM postgres;
GRANT ALL ON TABLE smpc_structure_ul TO postgres;
GRANT ALL ON TABLE smpc_structure_ul TO jchem;
GRANT ALL ON TABLE smpc_structure_ul TO seurat;
GRANT ALL ON TABLE smpc_structure_ul TO seurat;
GRANT ALL ON TABLE smpc_structure_ul TO demo;
GRANT ALL ON TABLE smpc_structure_ul TO seurat;


--
-- Name: syn_alt_assay_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_alt_assay_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_alt_assay_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_alt_assay_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_alt_assay_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_alt_assay_id_seq TO seurat;


--
-- Name: syn_assay_classification_summary; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_assay_classification_summary FROM seurat;
REVOKE ALL ON TABLE syn_assay_classification_summary FROM postgres;
GRANT ALL ON TABLE syn_assay_classification_summary TO postgres;
GRANT SELECT ON TABLE syn_assay_classification_summary TO seurat;
GRANT SELECT ON TABLE syn_assay_classification_summary TO seurat;


--
-- Name: syn_chemical_name; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_chemical_name FROM seurat;
REVOKE ALL ON TABLE syn_chemical_name FROM seurat;
GRANT ALL ON TABLE syn_chemical_name TO seurat;
GRANT ALL ON TABLE syn_chemical_name TO seurat;
GRANT ALL ON TABLE syn_chemical_name TO demo;
GRANT ALL ON TABLE syn_chemical_name TO seurat;


--
-- Name: syn_compound; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_compound FROM seurat;
REVOKE ALL ON TABLE syn_compound FROM seurat;
GRANT ALL ON TABLE syn_compound TO seurat;
GRANT ALL ON TABLE syn_compound TO seurat;
GRANT ALL ON TABLE syn_compound TO demo;
GRANT ALL ON TABLE syn_compound TO seurat;


--
-- Name: syn_compound_lot; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_compound_lot FROM seurat;
REVOKE ALL ON TABLE syn_compound_lot FROM seurat;
GRANT ALL ON TABLE syn_compound_lot TO seurat;
GRANT ALL ON TABLE syn_compound_lot TO seurat;
GRANT ALL ON TABLE syn_compound_lot TO demo;
GRANT ALL ON TABLE syn_compound_lot TO seurat;


--
-- Name: syn_compound_scaffclass; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_compound_scaffclass FROM seurat;
REVOKE ALL ON TABLE syn_compound_scaffclass FROM postgres;
GRANT ALL ON TABLE syn_compound_scaffclass TO postgres;
GRANT ALL ON TABLE syn_compound_scaffclass TO jchem;
GRANT ALL ON TABLE syn_compound_scaffclass TO seurat;
GRANT ALL ON TABLE syn_compound_scaffclass TO seurat;
GRANT ALL ON TABLE syn_compound_scaffclass TO demo;
GRANT ALL ON TABLE syn_compound_scaffclass TO seurat;


--
-- Name: syn_corp_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_corp_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_corp_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_corp_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_corp_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_corp_id_seq TO seurat;


--
-- Name: syn_corporate_id; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_corporate_id FROM seurat;
REVOKE ALL ON TABLE syn_corporate_id FROM seurat;
GRANT ALL ON TABLE syn_corporate_id TO seurat;
GRANT ALL ON TABLE syn_corporate_id TO demo;
GRANT ALL ON TABLE syn_corporate_id TO seurat;
GRANT ALL ON TABLE syn_corporate_id TO seurat;


--
-- Name: syn_document; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_document FROM seurat;
REVOKE ALL ON TABLE syn_document FROM seurat;
GRANT ALL ON TABLE syn_document TO seurat;
GRANT ALL ON TABLE syn_document TO seurat;
GRANT ALL ON TABLE syn_document TO demo;
GRANT ALL ON TABLE syn_document TO seurat;


--
-- Name: syn_file_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_file_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_file_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_file_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_file_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_file_id_seq TO seurat;


--
-- Name: syn_file; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_file FROM seurat;
REVOKE ALL ON TABLE syn_file FROM seurat;
GRANT ALL ON TABLE syn_file TO seurat;
GRANT ALL ON TABLE syn_file TO seurat;
GRANT ALL ON TABLE syn_file TO demo;
GRANT ALL ON TABLE syn_file TO seurat;


--
-- Name: syn_observation; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_observation FROM seurat;
REVOKE ALL ON TABLE syn_observation FROM seurat;
GRANT ALL ON TABLE syn_observation TO seurat;
GRANT ALL ON TABLE syn_observation TO seurat;
GRANT ALL ON TABLE syn_observation TO demo;
GRANT ALL ON TABLE syn_observation TO seurat;


--
-- Name: syn_observation_protocol; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_observation_protocol FROM seurat;
REVOKE ALL ON TABLE syn_observation_protocol FROM seurat;
GRANT ALL ON TABLE syn_observation_protocol TO seurat;
GRANT ALL ON TABLE syn_observation_protocol TO seurat;
GRANT ALL ON TABLE syn_observation_protocol TO demo;
GRANT ALL ON TABLE syn_observation_protocol TO seurat;


--
-- Name: syn_observation_type; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_observation_type FROM seurat;
REVOKE ALL ON TABLE syn_observation_type FROM seurat;
GRANT ALL ON TABLE syn_observation_type TO seurat;
GRANT ALL ON TABLE syn_observation_type TO seurat;
GRANT ALL ON TABLE syn_observation_type TO demo;
GRANT ALL ON TABLE syn_observation_type TO seurat;


--
-- Name: syn_observation_unit; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_observation_unit FROM seurat;
REVOKE ALL ON TABLE syn_observation_unit FROM seurat;
GRANT ALL ON TABLE syn_observation_unit TO seurat;
GRANT ALL ON TABLE syn_observation_unit TO seurat;
GRANT ALL ON TABLE syn_observation_unit TO demo;
GRANT ALL ON TABLE syn_observation_unit TO seurat;


--
-- Name: syn_person; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_person FROM seurat;
REVOKE ALL ON TABLE syn_person FROM seurat;
GRANT ALL ON TABLE syn_person TO seurat;
GRANT ALL ON TABLE syn_person TO seurat;
GRANT ALL ON TABLE syn_person TO demo;
GRANT ALL ON TABLE syn_person TO seurat;


--
-- Name: syn_phenomenon_type; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_phenomenon_type FROM seurat;
REVOKE ALL ON TABLE syn_phenomenon_type FROM seurat;
GRANT ALL ON TABLE syn_phenomenon_type TO seurat;
GRANT ALL ON TABLE syn_phenomenon_type TO seurat;
GRANT ALL ON TABLE syn_phenomenon_type TO demo;
GRANT ALL ON TABLE syn_phenomenon_type TO seurat;


--
-- Name: syn_project_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_project_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_project_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_project_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_project_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_project_id_seq TO seurat;


--
-- Name: syn_project; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_project FROM seurat;
REVOKE ALL ON TABLE syn_project FROM seurat;
GRANT ALL ON TABLE syn_project TO seurat;
GRANT ALL ON TABLE syn_project TO seurat;
GRANT ALL ON TABLE syn_project TO demo;
GRANT ALL ON TABLE syn_project TO seurat;


--
-- Name: syn_salt_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_salt_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_salt_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_salt_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_salt_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_salt_id_seq TO seurat;


--
-- Name: syn_salt; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_salt FROM seurat;
REVOKE ALL ON TABLE syn_salt FROM seurat;
GRANT ALL ON TABLE syn_salt TO seurat;
GRANT ALL ON TABLE syn_salt TO seurat;
GRANT ALL ON TABLE syn_salt TO demo;
GRANT ALL ON TABLE syn_salt TO seurat;


--
-- Name: syn_sample_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_sample_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_sample_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_sample_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_sample_id_seq TO demo;


--
-- Name: syn_sample; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_sample FROM seurat;
REVOKE ALL ON TABLE syn_sample FROM seurat;
GRANT ALL ON TABLE syn_sample TO seurat;
GRANT ALL ON TABLE syn_sample TO seurat;
GRANT ALL ON TABLE syn_sample TO demo;
GRANT ALL ON TABLE syn_sample TO seurat;


--
-- Name: syn_scaffold; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_scaffold FROM seurat;
REVOKE ALL ON TABLE syn_scaffold FROM postgres;
GRANT ALL ON TABLE syn_scaffold TO postgres;
GRANT ALL ON TABLE syn_scaffold TO seurat;
GRANT ALL ON TABLE syn_scaffold TO seurat;
GRANT ALL ON TABLE syn_scaffold TO demo;


--
-- Name: syn_scaffold_class; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_scaffold_class FROM seurat;
REVOKE ALL ON TABLE syn_scaffold_class FROM postgres;
GRANT ALL ON TABLE syn_scaffold_class TO postgres;
GRANT ALL ON TABLE syn_scaffold_class TO seurat;
GRANT ALL ON TABLE syn_scaffold_class TO seurat;
GRANT ALL ON TABLE syn_scaffold_class TO demo;


--
-- Name: syn_scaffoldset; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_scaffoldset FROM seurat;
REVOKE ALL ON TABLE syn_scaffoldset FROM postgres;
GRANT ALL ON TABLE syn_scaffoldset TO postgres;
GRANT ALL ON TABLE syn_scaffoldset TO seurat;
GRANT ALL ON TABLE syn_scaffoldset TO seurat;
GRANT ALL ON TABLE syn_scaffoldset TO demo;


--
-- Name: syn_scaffoldset_owner; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_scaffoldset_owner FROM seurat;
REVOKE ALL ON TABLE syn_scaffoldset_owner FROM postgres;
GRANT ALL ON TABLE syn_scaffoldset_owner TO postgres;
GRANT ALL ON TABLE syn_scaffoldset_owner TO seurat;
GRANT ALL ON TABLE syn_scaffoldset_owner TO seurat;
GRANT ALL ON TABLE syn_scaffoldset_owner TO demo;


--
-- Name: syn_source_id_seq; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON SEQUENCE syn_source_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_source_id_seq FROM seurat;
GRANT ALL ON SEQUENCE syn_source_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_source_id_seq TO demo;
GRANT ALL ON SEQUENCE syn_source_id_seq TO seurat;


--
-- Name: syn_source; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_source FROM seurat;
REVOKE ALL ON TABLE syn_source FROM seurat;
GRANT ALL ON TABLE syn_source TO seurat;
GRANT ALL ON TABLE syn_source TO seurat;
GRANT ALL ON TABLE syn_source TO demo;
GRANT ALL ON TABLE syn_source TO seurat;


--
-- Name: syn_structure; Type: ACL; Schema: seurat; Owner: jchem
--

REVOKE ALL ON TABLE syn_structure FROM seurat;
REVOKE ALL ON TABLE syn_structure FROM jchem;
GRANT ALL ON TABLE syn_structure TO jchem;
GRANT ALL ON TABLE syn_structure TO seurat;
GRANT ALL ON TABLE syn_structure TO seurat;
GRANT ALL ON TABLE syn_structure TO demo;
GRANT ALL ON TABLE syn_structure TO seurat;


--
-- Name: syn_structure_cd_id_seq; Type: ACL; Schema: seurat; Owner: jchem
--

REVOKE ALL ON SEQUENCE syn_structure_cd_id_seq FROM seurat;
REVOKE ALL ON SEQUENCE syn_structure_cd_id_seq FROM jchem;
GRANT ALL ON SEQUENCE syn_structure_cd_id_seq TO jchem;
GRANT ALL ON SEQUENCE syn_structure_cd_id_seq TO seurat;
GRANT ALL ON SEQUENCE syn_structure_cd_id_seq TO seurat WITH GRANT OPTION;
GRANT ALL ON SEQUENCE syn_structure_cd_id_seq TO demo;


--
-- Name: syn_structure_ul; Type: ACL; Schema: seurat; Owner: postgres
--

REVOKE ALL ON TABLE syn_structure_ul FROM seurat;
REVOKE ALL ON TABLE syn_structure_ul FROM postgres;
GRANT ALL ON TABLE syn_structure_ul TO postgres;
GRANT ALL ON TABLE syn_structure_ul TO jchem;
GRANT ALL ON TABLE syn_structure_ul TO seurat;
GRANT ALL ON TABLE syn_structure_ul TO seurat;
GRANT ALL ON TABLE syn_structure_ul TO demo;
GRANT ALL ON TABLE syn_structure_ul TO seurat;


--
-- Name: syn_well_info; Type: ACL; Schema: seurat; Owner: seurat
--

REVOKE ALL ON TABLE syn_well_info FROM seurat;
REVOKE ALL ON TABLE syn_well_info FROM seurat;
GRANT ALL ON TABLE syn_well_info TO seurat;
GRANT ALL ON TABLE syn_well_info TO jchem;
GRANT ALL ON TABLE syn_well_info TO seurat;
GRANT ALL ON TABLE syn_well_info TO demo;
GRANT ALL ON TABLE syn_well_info TO seurat;


--
-- PostgreSQL database dump complete
--

\connect template1

--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'Default template database';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = seurat, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: syn_therapeutic_area; Type: TABLE; Schema: seurat; Owner: postgres; Tablespace: 
--

CREATE TABLE syn_therapeutic_area (
    id bigint NOT NULL,
    name character varying(500) NOT NULL,
    description character varying(4000)
);


ALTER TABLE seurat.syn_therapeutic_area OWNER TO postgres;

--
-- Name: syn_ther_area_name_unique_cons; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_therapeutic_area
    ADD CONSTRAINT syn_ther_area_name_unique_cons UNIQUE (name);


--
-- Name: syn_therapeutic_area_pk; Type: CONSTRAINT; Schema: seurat; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY syn_therapeutic_area
    ADD CONSTRAINT syn_therapeutic_area_pk PRIMARY KEY (id);


--
-- Name: seurat; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA seurat FROM seurat;
REVOKE ALL ON SCHEMA seurat FROM postgres;
GRANT ALL ON SCHEMA seurat TO postgres;
GRANT ALL ON SCHEMA seurat TO seurat;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

