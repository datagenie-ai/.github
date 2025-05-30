alter table datagenie.aggregations 
	add aggr_type char(1) null
;
	
update datagenie.aggregations 
	set aggr_type = 'N' where code in ('__sum__','__avg__','__min__','__max__','__median__',
				'__p75__','__p99__','__p99_3__','__p25__','__p10__','__p95__','__p99_6__','__p99_9__')
;

update datagenie.aggregations 
	set aggr_type = 'P' where code in ('__count__','__percentage__')
;
	
update datagenie.aggregations 
	set aggr_type = 'C' where code in ('__distinct_count__','__null_count__')
;
	
alter table datagenie.aggregations 
	alter column aggr_type SET not null
;
ALTER TABLE datagenie.datasets 
    ADD time_anchor_column_format varchar(50) NULL 
;
ALTER TABLE datagenie.datasets ADD process_weekly_at varchar(3) NULL 
;

ALTER TABLE datagenie.datasets ADD week_start varchar(3) NULL 
;

ALTER TABLE datagenie.datasets ADD
    CONSTRAINT ckc_week_start_datasets check (week_start in ('MON','TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'))
;

ALTER TABLE datagenie.datasets ADD
    CONSTRAINT ckc_process_weekly_at check (week_start in ('MON','TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'))
;
ALTER TABLE datagenie.custom_aggregations ADD is_regressor boolean DEFAULT FALSE NOT NULL 
;

ALTER TABLE datagenie.custom_aggregations ADD is_weekly boolean DEFAULT FALSE NOT NULL 
;

ALTER TABLE datagenie.custom_aggregations ADD is_daily boolean DEFAULT TRUE NOT NULL 
;

ALTER TABLE datagenie.tracker_points ADD is_extra_regressor boolean NULL 
;ALTER TABLE datagenie.custom_aggregations 
    ADD desirable_trend char(1) DEFAULT 'N' NOT NULL
    CONSTRAINT chk_custom_aggregation_desirable_trend   
    CHECK (desirable_trend = 'N' OR desirable_trend = 'U' OR desirable_trend ='D');  

ALTER TABLE datagenie.custom_aggregations 
    ADD values_range char(1) DEFAULT 'A' NOT NULL
    CONSTRAINT chk_custom_aggregation_values_range   
     CHECK (values_range = 'A' OR values_range = 'P' OR values_range ='N');  

ALTER TABLE datagenie.custom_aggregations  
   ADD type char(1) DEFAULT 'N' NOT NULL    
   CONSTRAINT chk_custom_aggregation_type   
   CHECK (type = 'N' OR type = 'P' OR type ='C');

ALTER TABLE datagenie.custom_aggregations
    ADD currency varchar(3);

ALTER TABLE datagenie.custom_aggregations
    ADD code varchar(150);
   
UPDATE datagenie.custom_aggregations SET code = replace(lower(name),' ', '_');

ALTER TABLE datagenie.custom_aggregations
	ALTER COLUMN code SET NOT NULL; 

ALTER TABLE datagenie.custom_aggregations drop constraint pk_custom_aggregations;

ALTER TABLE datagenie.custom_aggregations add constraint pk_custom_aggregations primary key (dataset_id, code);

ALTER TABLE datagenie.custom_aggregations DROP COLUMN id;

ALTER TABLE datagenie.datasets 
    ADD last_modified_at timestamp DEFAULT now() NOT NULL;

ALTER TABLE datagenie.datasets 
    ADD created_at timestamp DEFAULT now() NOT NULL;

ALTER TABLE datagenie.datasets 
    ADD owner varchar(150) NULL;

ALTER TABLE datagenie.datasets 
    ADD owner_email varchar(150) NULL;

ALTER TABLE datagenie.attributes 
    ADD track_data_quality boolean DEFAULT FALSE NOT NULL;
create table datagenie.permission_groups (
   code                 varchar(50)            not null,
   name                 varchar(150)           not null,
   constraint pk_permission_groups primary key (code)
)
;

create table datagenie.permissions (
   id                   serial                 not null,
   group_code           varchar(50)            not null,
   name                 varchar(150)           not null,
   resource_type        varchar(50)            not null,
      constraint ckc_permissions_resource_type check (resource_type in ('USER','TENANT','DATASET')),
   constraint pk_permissions primary key (id)
)
;

alter table datagenie.permissions
   add constraint fk_permissions_groups foreign key (group_code)
      references datagenie.permission_groups (code)
;

create table datagenie.roles (
   id                   serial               not null,
   name                 varchar(150)         not null,
   is_dataset_specific  boolean              not null default false,
   is_system            boolean              not null default false,
   constraint pk_roles primary key (id)
)
;

create table datagenie.roles_permissions (
   role_id              integer              not null,
   permission_id        integer              not null,
   constraint pk_roles_permissions primary key (role_id, permission_id)
)
;

alter table datagenie.roles_permissions
   add constraint fk_roles_permissions foreign key (permission_id)
      references datagenie.permissions (id)
;

alter table datagenie.roles_permissions
   add constraint fk_roles_permissions_roles foreign key (role_id)
      references datagenie.roles (id)
;

create table datagenie.privileges (
   user_id              varchar(255)         not null,
   role_id              integer              not null,
   tenant               varchar(50)          null,
   dataset_id           integer              null,
   granted              timestamp            not null default now()
)
;

create index ind_privileges_users_roles on datagenie.privileges (
user_id asc,
role_id asc
)
;

alter table datagenie.privileges
   add constraint fk_privileg_reference_clients foreign key (tenant)
      references datagenie.clients (code)
;

alter table datagenie.privileges
   add constraint fk_privileg_reference_datasets foreign key (dataset_id)
      references datagenie.datasets (id)
;

alter table datagenie.privileges
   add constraint fk_privileges_roles foreign key (role_id)
      references datagenie.roles (id)
;
create table datagenie.sample_data (
   dataset_id           integer              not null,
   sample_data          text                 not null,
   sample_data_schema   text                 not null,
   constraint pk_sample_data primary key (dataset_id)
)
;

alter table datagenie.sample_data
   add constraint fk_sample_data_datasets foreign key (dataset_id)
      references datagenie.datasets (id)
;-- Permission groups
INSERT INTO datagenie.permission_groups (code,name)
	VALUES ('insights','Insights');
INSERT INTO datagenie.permission_groups (code,name)
	VALUES ('datasets','Dataset Management');
INSERT INTO datagenie.permission_groups (code,name)
	VALUES ('users','User Management');
INSERT INTO datagenie.permission_groups (code,name)
	VALUES ('jobs','Jobs Management');
INSERT INTO datagenie.permission_groups (code,name)
	VALUES ('tenants','Tenant Management');

-- Permissions
-- Auto-generated SQL script #202103032155
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ( 'insights','View Top Insights','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('insights','View Explorer','DATASET');

INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('datasets','View','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('datasets','Modify','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('datasets','Add','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('datasets','Delete','DATASET');

INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('jobs','Jobs Management','DATASET');

INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('tenants','View','TENANT');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('tenants','Modify','TENANT');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('tenants','Add','TENANT');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('tenants','Delete','TENANT');

INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('users','View','USER');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('users','Modify','USER');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('users','Add','USER');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('users','Delete','USER');

-- Roles
INSERT INTO datagenie.roles (name, is_system)
	VALUES ('Global - Level 0', true);
INSERT INTO datagenie.roles (name, is_system)
	VALUES ('Global - Level 1', true);
INSERT INTO datagenie.roles (name, is_system)
	VALUES ('Global - Level 2', true);
INSERT INTO datagenie.roles (name, is_dataset_specific, is_system)
	VALUES ('Dataset Specific - Level 0', true, true);
INSERT INTO datagenie.roles (name, is_dataset_specific, is_system)
	VALUES ('Dataset Specific - Level 1', true, true);

-- Role permissions
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (1,3);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,3);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,5);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,12);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3,3);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3,5);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3,12);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3,13);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3,14);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3,15);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (4,1);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (5,1);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (5,4);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (5,6);
INSERT INTO datagenie.sources (id, name) VALUES(0, 'bigquery');
INSERT INTO datagenie.sources (id, name) VALUES(1, 'azure sql');
INSERT INTO datagenie.sources (id, name) VALUES(2, 'adls');
INSERT INTO datagenie.sources (id, name) VALUES(4, 's3');
INSERT INTO datagenie.sources (id, name) VALUES(5, 'azure blob');

INSERT INTO datagenie.aggregations (code,name,summary_enabled,aggr_type) VALUES
	 ('__distinct_count__','Distinct Count',true,'C'),
	 ('__p75__','%tile 75',false,'N'),
	 ('__p99__','%tile 99',false,'N'),
	 ('__p99_3__','%tile 99.3',false,'N'),
	 ('__p25__','%tile 25',false,'N'),
	 ('__p10__','%tile 10',false,'N'),
	 ('__p95__','%tile 95',false,'N'),
	 ('__p99_6__','%tile 99.6',false,'N'),
	 ('__count__','Count',true,'P'),
	 ('__p99_9__','%tile 99.9',false,'N');
INSERT INTO datagenie.aggregations (code,name,summary_enabled,aggr_type) VALUES
	 ('__max__','Max',false,'N'),
	 ('__median__','Median',true,'N'),
	 ('__null_count__','Null Count',true,'C'),
	 ('__min__','Min',false,'N'),
	 ('__avg__','Mean',true,'N'),
	 ('__percentage__','Visit Mix',true,'P'),
	 ('__sum__','Sum',true,'N');ALTER TABLE datagenie.attributes ADD is_deleted boolean DEFAULT false NOT NULL;

CREATE TABLE datagenie.users (
	id varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	first_name varchar(150) NULL,
	last_name varchar(150) NULL,
	CONSTRAINT pk_users PRIMARY KEY (id)
);
ALTER TABLE datagenie.clients 
    ADD tenant_id varchar(150) NOT NULL;

ALTER TABLE datagenie.datasets 
    ADD tenant_column varchar(150) NULL;

-- permissions

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2, 7);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3, 7);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3, 9);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3, 8);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (3, 10);

ALTER TABLE datagenie.roles 
    ADD is_tenant_specific boolean DEFAULT FALSE NOT NULL;

INSERT INTO datagenie.roles (name, is_tenant_specific, is_system)
	VALUES ('Tenant Specific - Level 0', true, true);
INSERT INTO datagenie.roles (name, is_tenant_specific, is_system)
	VALUES ('Tenant Specific - Level 1', true, true);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (6,3);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (7,3);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (7,5);

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (4,11);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (5,11);

DELETE FROM datagenie.roles_permissions
	WHERE role_id=1 AND permission_id=3;

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (1,12);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (1,13);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (1,14);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (1,15);

DELETE FROM datagenie.roles_permissions
	WHERE role_id=2 AND permission_id=3;
DELETE FROM datagenie.roles_permissions
	WHERE role_id=2 AND permission_id=5;
DELETE FROM datagenie.roles_permissions
	WHERE role_id=2 AND permission_id=7;
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,13);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,14);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,15);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,7);

DELETE FROM datagenie.roles_permissions
	WHERE role_id=3 AND permission_id=3;
DELETE FROM datagenie.roles_permissions
	WHERE role_id=3 AND permission_id=5;
ALTER TABLE datagenie.job_runs 
     ADD granularity    varchar(10)  NULL ,
	 ADD run_type       varchar(10)  NULL ,
	 ADD job_type       varchar(20)  NULL,
	 ADD error_details  text         NULL
;

ALTER TABLE  datagenie.job_runs 
    DROP CONSTRAINT pk_job_runs
;
 
ALTER TABLE datagenie.job_runs 
    ADD CONSTRAINT pk_job_runs PRIMARY KEY (id, name)
;

ALTER TABLE datagenie.datasets 
    ADD reprocess_last_days_once integer NULL default -1,
    ADD reprocess_last_weeks_once integer NULL default -1
;
ALTER TABLE datagenie.attributes 
    ADD last_updated timestamp DEFAULT now() NOT NULL;

ALTER TABLE datagenie.custom_aggregations 
    ADD last_updated timestamp DEFAULT now() NOT NULL;

UPDATE datagenie.system_config SET value='2' WHERE key='zscore_min_daily';
UPDATE datagenie.system_config SET value='2' WHERE key='zscore_min_weekly';
DELETE FROM datagenie.roles_permissions where role_id =1;
DELETE FROM datagenie.roles_permissions where role_id =3;

DELETE FROM datagenie.privileges where role_id =1;
DELETE FROM datagenie.privileges where role_id =3;

DELETE FROM datagenie.roles	WHERE id=1;
DELETE FROM datagenie.roles	WHERE id=3;

INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,8);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,9);
INSERT INTO datagenie.roles_permissions (role_id,permission_id)
	VALUES (2,10);

CREATE TABLE datagenie.alert_groups (
    id                          SERIAL         NOT NULL,
    name                        VARCHAR(150)     NOT NULL,
    dataset_id                  INTEGER         NOT NULL,
    threshold                   DECIMAL(19, 8)  NOT NULL,
    threshold_type              VARCHAR(50)      NOT NULL,
    CONSTRAINT ckc_threshold_type_alert_groups CHECK (threshold_type IN ('population', 'zscore', 'percentile')),
    CONSTRAINT pk_alert_groups PRIMARY KEY (id)
)
;

CREATE TABLE datagenie.alert_kpi_thresholds (
    alert_group_id              INTEGER         NOT NULL,
    dataset_id                  INTEGER         NOT NULL,
    custom_aggregation_code     VARCHAR(150)    NOT NULL,
    granularity                 VARCHAR(50)     NOT NULL,
        CONSTRAINT ckc_granularity_alert_kpi_thresholds CHECK (granularity IN ('weekly', 'daily')),
    threshold                   DECIMAL(19, 8)  NOT NULL,
    threshold_type              VARCHAR(50)      NOT NULL,
        CONSTRAINT ckc_threshold_type_alert_kpi_thresholds CHECK (threshold_type IN ('population', 'zscore', 'percentile')),
    CONSTRAINT pk_alert_kpi_thresholds PRIMARY KEY (alert_group_id, dataset_id, custom_aggregation_code, granularity)
)
;

CREATE TABLE datagenie.alert_data_quality_thresholds (
    alert_group_id              INTEGER         NOT NULL,
    aggregation_code            VARCHAR(50)     NOT NULL,
    granularity                 VARCHAR(50)      NOT NULL
        CONSTRAINT ckc_granularity_alert_data_quality_thresholds CHECK (granularity IN ('weekly', 'daily')),
    threshold                   DECIMAL(19, 8)  NOT NULL,
    threshold_type              VARCHAR(50)      NOT NULL
        CONSTRAINT ckc_threshold_type_alert_data_quality_thresholds CHECK (threshold_type IN ('population', 'zscore', 'percentile')),
    CONSTRAINT pk_alert_data_quality_thresholds PRIMARY KEY (alert_group_id, aggregation_code, granularity)
)
;

CREATE TABLE datagenie.alert_groups_and_channels (
    alert_group_id              INTEGER         NOT NULL,
    alert_channel_id            INTEGER         NOT NULL,
    CONSTRAINT pk_alert_groups_and_channels PRIMARY KEY (alert_group_id, alert_channel_id)
)
;

CREATE TABLE datagenie.alert_channels (
    id                          SERIAL         NOT NULL,
    type                        VARCHAR(50)      NOT NULL,
      CONSTRAINT ckc_type_alert_groups_and_channels CHECK (type IN ('slack')),
    code                        VARCHAR(150)      NOT NULL,
      CONSTRAINT pk_alert_channels PRIMARY KEY (id)
)
;

ALTER TABLE datagenie.alert_groups
    ADD CONSTRAINT fk_alert_groups_datasets FOREIGN KEY (dataset_id)
        REFERENCES datagenie.datasets (id)
;

ALTER TABLE datagenie.alert_kpi_thresholds
    ADD CONSTRAINT fk_alert_kpi_thresholds_alert_groups FOREIGN KEY (alert_group_id)
        REFERENCES datagenie.alert_groups (id)
;

ALTER TABLE datagenie.alert_kpi_thresholds
    ADD CONSTRAINT fk_alert_kpi_thresholds_custom_aggregations FOREIGN KEY (dataset_id, custom_aggregation_code)
        REFERENCES datagenie.custom_aggregations (dataset_id, code)
;

ALTER TABLE datagenie.alert_data_quality_thresholds
    ADD CONSTRAINT fk_alert_data_quality_thresholds_alert_groups FOREIGN KEY (alert_group_id)
        REFERENCES datagenie.alert_groups (id)
;

ALTER TABLE datagenie.alert_groups_and_channels
    ADD CONSTRAINT fk_alert_groups_and_channels_alert_groups FOREIGN KEY (alert_group_id)
        REFERENCES datagenie.alert_groups (id)
;

ALTER TABLE datagenie.alert_groups_and_channels
    ADD CONSTRAINT fk_alert_groups_and_channels_alert_channels FOREIGN KEY (alert_channel_id)
        REFERENCES datagenie.alert_channels (id)
;
ALTER TABLE datagenie.attribute_values_temp ADD profiling_timestamp timestamp NULL;
ALTER TABLE datagenie.attribute_values ADD profiling_timestamp timestamp NULL;
ALTER TABLE datagenie.datasets ADD notification_emails text NULL;ALTER TABLE datagenie.alert_channels
    ADD name VARCHAR(150),
    ADD external_id VARCHAR(255),
    ADD external_url VARCHAR(255),
    ADD external_name VARCHAR(255),
    ADD external_directory_id VARCHAR(255),
    ADD external_directory_name VARCHAR(255),
    ADD cred_name VARCHAR(100),
    ADD cred_key VARCHAR(100),
    ADD last_modification TIMESTAMP DEFAULT now();

ALTER TABLE datagenie.alert_channels
    DROP CONSTRAINT ckc_type_alert_groups_and_channels;

ALTER TABLE datagenie.alert_channels
    ADD CONSTRAINT ckc_type_alert_groups_and_channels CHECK (type IN ('slack', 'jira'));

ALTER TABLE datagenie.alert_groups
    ADD enabled BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE datagenie.alert_channels 
    DROP COLUMN code;
ALTER TABLE datagenie.attributes 
    ADD max_tracked_values int NULL;
INSERT INTO datagenie.permission_groups (code, name) 
VALUES('alert_channels', 'Alert Channels');

INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('alert_channels','View','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('alert_channels','Add','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('alert_channels','Delete','DATASET');
INSERT INTO datagenie.permissions (group_code,name,resource_type)
	VALUES ('alert_channels','Modify','DATASET');

INSERT INTO datagenie.roles_permissions (role_id, permission_id) VALUES(2, 16);
INSERT INTO datagenie.roles_permissions (role_id, permission_id) VALUES(2, 17);
INSERT INTO datagenie.roles_permissions (role_id, permission_id) VALUES(2, 18);
INSERT INTO datagenie.roles_permissions (role_id, permission_id) VALUES(2, 19);
CREATE TABLE datagenie.tracker_points_tmp (	
	tracker_id varchar(500) NOT NULL,
	dataset_id int NOT NULL,
	point_timestamp timestamp NOT NULL,
	point_value decimal(15,4) NULL,
	y_hat decimal(15,4) NULL,
	sigma decimal(15,4) NULL,
	b1 decimal(15,4) NULL,
	b2 decimal(15,4) NULL,
	b3 decimal(15,4) NULL,
	b4 decimal(15,4) NULL,
	a1 decimal(15,4) NULL,
	a2 decimal(15,4) NULL,
	a3 decimal(15,4) NULL,
	a4 decimal(15,4) NULL,
	population decimal(15,8) NULL,
	severity varchar(50) NULL,
	zscore decimal(15,4) NULL	
);
CREATE TABLE datagenie.export_runs (
	id varchar(50) NOT NULL,
	dataset_id int NOT NULL,
	tracker_id varchar(500) NOT NULL,
	point_timestamp timestamp NOT NULL,
	export_trigger_time timestamp DEFAULT now() NOT NULL,
	status varchar(32) NOT NULL,
	folder varchar(500) NOT NULL,
	filesystem varchar(100) NOT NULL,
	granularity varchar(100) NOT NULL,
	"user" varchar(100) NOT NULL,
	CONSTRAINT CI_IdentityER PRIMARY KEY (id, dataset_id),
	CONSTRAINT export_runs_FK_datasets FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id),
	CONSTRAINT export_runs_FK_trackers FOREIGN KEY (tracker_id,dataset_id) REFERENCES datagenie.trackers(id,dataset_id)
);
ALTER TABLE datagenie.datasets
	ADD  partition_column varchar(100);insert into datagenie.system_config("key", "value") values ('ReconWeeklyDay','SAT');
insert into datagenie.system_config("key", "value") values ('ReconDailyDay','SAT');

ALTER TABLE datagenie.job_runs 
    ADD is_ondemand boolean DEFAULT FALSE NOT NULL;

ALTER TABLE datagenie.job_runs 
    ADD submitted_by varchar(256) DEFAULT 'SYSTEM' NOT NULL;
ALTER TABLE datagenie.datasets 
ADD projection_sql_query text NULL;

CREATE TABLE datagenie.custom_aggregations_attribute_values (
	dataset_id int NOT NULL,
	aggregation_code varchar(150) NOT NULL,
	attribute_value_id varchar(500) NOT NULL,
	granularity varchar(10) NOT NULL,
	last_updated timestamp DEFAULT now() NOT NULL,
	CONSTRAINT custom_aggregations_attribute_values_PK PRIMARY KEY (dataset_id,aggregation_code,attribute_value_id),
	CONSTRAINT custom_aggregations_attribute_values_FK FOREIGN KEY (dataset_id,aggregation_code) REFERENCES datagenie.custom_aggregations(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT custom_aggregations_attribute_values_FK_1 FOREIGN KEY (attribute_value_id) REFERENCES datagenie.attribute_values(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.custom_aggregation_dimensions_tracked (
	dataset_id int NOT NULL,
	aggregation_code varchar(150) NOT NULL,
	attribute_code varchar(500) NOT NULL,
	enabled boolean DEFAULT TRUE NOT NULL,
	last_updated timestamp DEFAULT now() NOT NULL,
	CONSTRAINT custom_aggregation_dimensions_tracked_PK PRIMARY KEY (dataset_id,aggregation_code,attribute_code),
	CONSTRAINT custom_aggregation_dimensions_tracked_ca_FK FOREIGN KEY (dataset_id,aggregation_code) REFERENCES datagenie.custom_aggregations(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT custom_aggregation_dimensions_tracked_attr_FK FOREIGN KEY (dataset_id,attribute_code) REFERENCES datagenie.attributes(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.dataset_granularities (
	dataset_id int NOT NULL,
	time_unit varchar(150) NOT NULL,
		constraint ckc_time_units check (time_unit in ('WEEKS', 'DAYS', 'HOURS', 'MINUTES')),
	status varchar(150) NOT NULL,
		constraint ckc_status_granularities check (status in ('BACKLOG_PROCESSING_TO_BE_TRIGGERED','BACKLOG_PROCESSING_TRIGGERED', 'BACKLOG_PROCESSING_FAILED', 'READY')),
	max_depth int NOT NULL,
	backlog_period int NOT NULL,
	ad_period int NOT NULL,
	reprocess_period int NOT NULL,
	min_population numeric(15,4) NOT NULL,
	processing_period int NOT NULL,
	skip_period int NOT NULL,
	process_once int NULL,
	trigger_processing_at time NOT NULL,
	insights_min_population_threshold numeric(15,4) DEFAULT 0.5 NOT NULL,
	last_updated timestamp DEFAULT now() NOT NULL,
	CONSTRAINT dataset_granularities_PK PRIMARY KEY (dataset_id,time_unit),
	CONSTRAINT dataset_granularities_datasets_FK FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE datagenie.custom_aggregations ADD kind varchar(50) NOT NULL;

ALTER TABLE datagenie.custom_aggregations 
add	constraint ckc_aggregation_kind check (kind in ('BUSINESS', 'REGRESSOR', 'DATA_QUALITY'));

CREATE TABLE datagenie.top_stories (
	tracker_id varchar(500) NOT NULL,
	point_timestamp timestamp NOT NULL DEFAULT now(),
	population decimal(15,4) DEFAULT 0 NULL,
	relative_population decimal(15,4) NULL,
	final_score decimal(15,4) NULL,
	zscore numeric(15,4) NULL,
	severity varchar(50) NULL,
	deviation1 decimal(15,4) NULL,
	tracker_points text NULL,
	is_root boolean NULL DEFAULT TRUE,
	cluster_id varchar(2500) NOT NULL,
	attribute_values_str varchar(2500) NOT NULL,
	dataset_id int NOT NULL,
	granularity varchar(10) NOT NULL,
	aggregation varchar(100) NULL,
	deviation2 decimal(15,4) NULL,
	sensitivity_level int DEFAULT 1 NOT NULL,
	anomaly_percentile int DEFAULT 90 NULL,
	attribute_depth int NULL
);

CREATE INDEX top_stories_dataset_id_ts_gran_IDX 
	ON datagenie.top_stories (dataset_id, point_timestamp, granularity);

CREATE TABLE datagenie.tracker_points_bin (
	dataset_id int NOT NULL,
	granularity varchar(10) NOT NULL,
	tracker_id varchar(500) NOT NULL,
	tracker_points bytea NULL,
	CONSTRAINT PK_tracker_points_bin PRIMARY KEY (dataset_id, tracker_id)
);

-- ALTER TABLE constraints for custom_aggregations_attribute_values to include granularity
alter table datagenie.custom_aggregations_attribute_values drop constraint custom_aggregations_attribute_values_PK;

alter table datagenie.custom_aggregations_attribute_values add constraint custom_aggregations_attribute_values_PK PRIMARY KEY (dataset_id,aggregation_code,attribute_value_id, granularity);

CREATE TABLE datagenie.db_scripts (
	name varchar(150) NOT NULL,
	description varchar(500) NOT NULL,
	executed_at timestamp DEFAULT now() NOT NULL,
	author varchar(100) NOT NULL,
	CONSTRAINT db_scripts_PK PRIMARY KEY (name)
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20211031_01.sql', 'Initial DB schema changes for Dec 2021 release.', 'lukasz@codez.ai');
update datagenie.severity_configs 
	set z_score_threshold = 2.0001 where code='MINOR';

update datagenie.severity_configs 
	set z_score_threshold = 4.0001 where code='MAJOR';

update datagenie.severity_configs 
	set z_score_threshold = 8.0001 where code='CRITICAL' and granularity='daily';

update datagenie.severity_configs 
	set z_score_threshold = 6.0001 where code='CRITICAL' and granularity='weekly';

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20211213_01.sql', 'Z-Score thresholds adjustment.', 'skanda@codez.ai');ALTER TABLE datagenie.attribute_values ADD population decimal(15,4) NULL;
ALTER TABLE datagenie.attribute_values_temp ADD population decimal(15,4) NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220118_01.sql', 'Add population column to attribute_values.', 'lukasz@codez.ai');CREATE TABLE datagenie.supported_domains (
	domain varchar(256) NOT NULL,
	name varchar(1024) NOT NULL,
	idp_hint varchar(64) NOT NULL,
	logo bytea NOT NULL,
	CONSTRAINT supported_domains_PK PRIMARY KEY (domain)
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220224_01.sql', 'Add supported_domains table.', 'lukasz@codez.ai');
INSERT INTO datagenie.sources (id,name)
	VALUES (6,'athena');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220302_01.sql', 'Add Athena data source.', 'lukasz@codez.ai');
ALTER TABLE datagenie.datasets ADD 
    anchor_kpi varchar(500) NULL;

ALTER TABLE datagenie.datasets ADD 
    CONSTRAINT dataset_anchor_kpi_FK FOREIGN KEY (id, anchor_kpi) 
    REFERENCES datagenie.custom_aggregations(dataset_id, code) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE datagenie.datasets ADD 
    importance_weights_anchor_kpi varchar(500) NULL;

ALTER TABLE datagenie.datasets ADD 
    CONSTRAINT importance_weights_anchor_kpi_FK FOREIGN KEY (id, importance_weights_anchor_kpi) 
    REFERENCES datagenie.custom_aggregations(dataset_id, code) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE datagenie.datasets ADD importance_weight_deviation decimal(15, 4) DEFAULT 0 NOT NULL;
ALTER TABLE datagenie.datasets ADD importance_weight_score decimal(15, 4) DEFAULT 1 NOT NULL;
ALTER TABLE datagenie.datasets ADD importance_weight_population decimal(15, 4) DEFAULT 4 NOT NULL;
ALTER TABLE datagenie.datasets ADD importance_weight_anchor_kpi decimal(15, 4) DEFAULT 0 NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220324_01.sql', 'Add anchor_kpi to datasets.', 'lukasz@codez.ai');
INSERT INTO datagenie.system_config ("key", "value") VALUES('date_format_in_table_view', 'DD-MM-YYYY');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220513_01.sql', 'System config update.', 'lukasz@codez.ai');

CREATE TABLE datagenie.top_stories_bin (
	dataset_id int NOT NULL,
	granularity varchar(10) NOT NULL,
	point_timestamp timestamp NOT NULL,
	stories bytea NOT NULL
);

ALTER TABLE datagenie.top_stories_bin 
    ADD CONSTRAINT top_stories_bin_FK FOREIGN KEY (dataset_id) 
    REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE;


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220518_01.sql', 'New table for AS output.', 'lukasz@codez.ai');
 CREATE TABLE datagenie.product_analytics (
 	id bigserial,  
 	event_timestamp timestamp NOT NULL,
 	user_id varchar(255) DEFAULT NULL REFERENCES datagenie.users(id),
 	dataset_id integer DEFAULT NULL REFERENCES datagenie.datasets(id),
 	category_id varchar(255) NOT NULL,
 	event_id varchar(255) NOT NULL,
 	details text DEFAULT NULL,
 	CONSTRAINT pk_product_analytics PRIMARY KEY (id)
 );

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220525_01.sql', 'Add product_analytics table.', 'michalopielka');
-- DB schema changes for https://codezzz.atlassian.net/browse/DAT-319

ALTER TABLE datagenie.custom_aggregations 
    ADD show_in_top_stories boolean DEFAULT TRUE NOT NULL;

ALTER TABLE datagenie.custom_aggregations 
    ADD ad_sensitivity varchar(10) DEFAULT 'low' NOT NULL
    CONSTRAINT chck_custom_aggregation_ad_sensitivity   
        CHECK (ad_sensitivity = 'low' OR ad_sensitivity = 'medium' OR ad_sensitivity ='high');


ALTER TABLE datagenie.datasets 
    ADD data_type varchar(32) DEFAULT 'TRANSACTIONAL' NOT NULL
    CONSTRAINT chck_datasets_data_type   
        CHECK (data_type = 'TRANSACTIONAL' OR data_type = 'AGGREGATED');

ALTER TABLE datagenie.datasets 
    ADD usecase_details text NULL;

ALTER TABLE datagenie.custom_aggregations 
    ADD native_aggregator varchar(50) NULL;

ALTER TABLE datagenie.custom_aggregations
   ADD constraint fk_custom_aggregations_aggregators foreign key (native_aggregator)
      references datagenie.aggregations (code);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220603_01.sql', 'Dataset enhancements.', 'lukasz@codez.ai');
-- feature flags

CREATE TABLE datagenie.feature_flags (
	code varchar(500) NOT NULL,
	display_name text NOT NULL,
	enabled boolean DEFAULT false NOT NULL,
    CONSTRAINT pk_feature_flags PRIMARY KEY (code)
);

INSERT INTO datagenie.feature_flags(code, display_name) VALUES
('raw_data_export', 'Raw Data Exports'),
('connectors_athena_enabled', 'Athena connector available');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220630_01.sql', 'Feature flags.', 'lukasz@codez.ai');
-- additionl granularities https://codezzz.atlassian.net/browse/DAT-299

ALTER TABLE datagenie.dataset_granularities DROP CONSTRAINT ckc_time_units;

ALTER TABLE datagenie.dataset_granularities ADD CONSTRAINT ckc_time_units 
CHECK (time_unit='MINUTES' OR time_unit='HOURS' OR time_unit='DAYS' OR time_unit='WEEKS' 
    OR time_unit='MONTHS' OR time_unit='QUARTERS');


ALTER TABLE datagenie.custom_aggregations 
    ADD is_hourly boolean DEFAULT FALSE NOT NULL,
    ADD	is_monthly boolean DEFAULT FALSE NOT NULL,
    ADD	is_quarterly boolean DEFAULT FALSE NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220707_01.sql', 'Additional granularities.', 'lukasz@codez.ai');
-- ALTER TABLE [datagenie-v3].datagenie.datasets DROP CONSTRAINT DF__datasets__lower___03BB8E22;
-- ALTER TABLE datagenie.datasets DROP COLUMN lower_percentile_threshold;

ALTER TABLE datagenie.alert_groups DROP CONSTRAINT ckc_threshold_type_alert_groups;

ALTER TABLE datagenie.alert_groups DROP COLUMN threshold_type;
ALTER TABLE datagenie.alert_groups DROP COLUMN threshold;
ALTER TABLE datagenie.alert_groups ADD max_top_stories int DEFAULT 0 NOT NULL;
ALTER TABLE datagenie.alert_groups ADD show_contributors boolean DEFAULT FALSE NOT NULL;
ALTER TABLE datagenie.alert_groups ADD include_minor boolean DEFAULT FALSE NOT NULL;
ALTER TABLE datagenie.alert_groups ADD include_major boolean DEFAULT FALSE NOT NULL;
ALTER TABLE datagenie.alert_groups ADD include_critical boolean DEFAULT FALSE NOT NULL;

ALTER TABLE datagenie.alert_kpi_thresholds DROP CONSTRAINT ckc_granularity_alert_kpi_thresholds;
ALTER TABLE datagenie.alert_kpi_thresholds DROP CONSTRAINT ckc_threshold_type_alert_kpi_thresholds;

ALTER TABLE datagenie.alert_kpi_thresholds DROP COLUMN threshold;
ALTER TABLE datagenie.alert_kpi_thresholds DROP COLUMN threshold_type;

ALTER TABLE datagenie.alert_data_quality_thresholds DROP CONSTRAINT ckc_threshold_type_alert_data_quality_thresholds;
ALTER TABLE datagenie.alert_data_quality_thresholds DROP CONSTRAINT ckc_granularity_alert_data_quality_thresholds;

ALTER TABLE datagenie.alert_data_quality_thresholds DROP COLUMN threshold;
ALTER TABLE datagenie.alert_data_quality_thresholds DROP COLUMN threshold_type;

ALTER TABLE datagenie.alert_kpi_thresholds ADD CONSTRAINT ckc_granularity_alert_kpi_thresholds 
CHECK (granularity='hourly' OR granularity='daily' OR granularity='weekly' OR granularity='monthly' OR granularity='quarterly');

ALTER TABLE datagenie.alert_data_quality_thresholds ADD CONSTRAINT ckc_granularity_alert_data_quality_thresholds 
CHECK (granularity='hourly' OR granularity='daily' OR granularity='weekly' OR granularity='monthly' OR granularity='quarterly');


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220730_01.sql', 'Alerts refactoring.', 'lukasz@codez.ai');
ALTER TABLE datagenie.datasets ADD show_contributors_count int DEFAULT 1 NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220806_01.sql', 'Add show_contributors_count column.', 'lukasz@codez.ai');
ALTER TABLE datagenie.dataset_granularities 
    ADD processing_schedule varchar(512) NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220814_01.sql', 'DAT-427: add processing_schedule column to dataset_granularities table.', 'lukasz@codez.ai');
INSERT INTO datagenie.severity_configs (granularity,code,name,z_score_threshold,show_band) VALUES
	 ('daily','MINOR','Minor',2.0001,false),
	 ('daily','MAJOR','Major',4.0001,false),
	 ('daily','CRITICAL','Critical',8.0001,false),
	 ('daily','NOT_AN_ANOMALY','NotAnAnomaly',0.0000,false),
	 ('weekly','NOT_AN_ANOMALY','NotAnAnomaly',0.0000,false),
	 ('weekly','MINOR','Minor',2.0001,false),
	 ('weekly','MAJOR','Major',4.0001,false),
	 ('weekly','CRITICAL','Critical',6.0001,false),
	 ('hourly','MINOR','Minor',2.0001,false),
	 ('hourly','MAJOR','Major',4.0001,false),
	 ('hourly','CRITICAL','Critical',8.0001,false),
	 ('hourly','NOT_AN_ANOMALY','NotAnAnomaly',0.0000,false),
	 ('quarterly','MINOR','Minor',2.0001,false),
	 ('quarterly','MAJOR','Major',4.0001,false),
	 ('quarterly','CRITICAL','Critical',8.0001,false),
	 ('quarterly','NOT_AN_ANOMALY','NotAnAnomaly',0.0000,false),
	 ('monthly','MINOR','Minor',2.0001,false),
	 ('monthly','MAJOR','Major',4.0001,false),
	 ('monthly','CRITICAL','Critical',8.0001,false),
	 ('monthly','NOT_AN_ANOMALY','NotAnAnomaly',0.0000,false);

DROP TABLE datagenie.score_weights;

CREATE TABLE datagenie.dataset_preprocessing_v2 (
	dataset_id int NOT NULL,
	config text NOT NULL,
	CONSTRAINT pk_dataset_preprocessing_v2 PRIMARY KEY (dataset_id)
);

ALTER TABLE datagenie.dataset_preprocessing_v2 ADD CONSTRAINT dataset_preprocessing_v2_FK 
FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220901_01.sql', 'Define severity config for new granularities.', 'lukasz@codez.ai');
CREATE TABLE datagenie.dashboards (
	id bigserial NOT NULL,
	name varchar(512) NOT NULL,
	title varchar(512) NOT NULL,
	description text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	last_updated_at timestamp NOT NULL,
	created_by varchar(255) NOT NULL,
	last_updated_by varchar(255) NULL,
	period_from timestamp NULL,
	period_to timestamp NULL,
	period_interval varchar(100) NULL,
	period_type varchar(100) DEFAULT 'FIXED' NOT NULL 
		CONSTRAINT ckc_dashboard_period_type CHECK (period_type IN ('FIXED', 'EDITABLE')),

	CONSTRAINT dashboards_PK PRIMARY KEY (id),
	CONSTRAINT dashboards_FK_users_create FOREIGN KEY (created_by) REFERENCES datagenie.users(id),
	CONSTRAINT dashboards_FK_users_update FOREIGN KEY (last_updated_by) REFERENCES datagenie.users(id)
);

CREATE UNIQUE INDEX dashboards_id_IDX ON datagenie.dashboards (id);

CREATE TABLE datagenie.dashboard_widgets (
	dashboard_id bigint NOT NULL,
	order_number int NOT NULL,
	position_x int NOT NULL,
	position_y int NOT NULL,
	width int NOT NULL,
	height int NOT NULL,
	type varchar(32) NOT NULL
        CONSTRAINT ckc_dashboard_widget_type CHECK (type IN ('plot', 'scorecard', 'label')),
	properties text NULL,
    CONSTRAINT dashboards_FK_widgets FOREIGN KEY (dashboard_id) REFERENCES datagenie.dashboards(id)
);
CREATE UNIQUE INDEX dashboard_widgets_dashboard_id_IDX ON datagenie.dashboard_widgets (dashboard_id, order_number);

CREATE TABLE datagenie.dashboard_global_filters (
	dashboard_id bigint NOT NULL,
	dataset_id int NOT NULL,
	attribute_code varchar(500) NOT NULL,
	attribute_value_id varchar(500) NULL,
	CONSTRAINT dashboard_global_filters_PK PRIMARY KEY (dashboard_id,dataset_id,attribute_code),
	CONSTRAINT dashboard_global_filters_FK_attributes FOREIGN KEY (dataset_id,attribute_code) REFERENCES datagenie.attributes(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT dashboard_global_filters_FK_datasets FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT dashboard_global_filters_FK_attribute_values FOREIGN KEY (attribute_value_id) REFERENCES datagenie.attribute_values(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT dashboard_global_filters_FK_dashboards FOREIGN KEY (dashboard_id) REFERENCES datagenie.dashboards(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220905_01.sql', 'DAT-459 Design database structures for Dashboards.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-496
-- add column with AS output version to top_tories_bin table
-- https://codezzz.atlassian.net/browse/DAT-499
-- add column with output version to tracker_points_bin table 

ALTER TABLE datagenie.top_stories_bin 
    ADD as_output_version int DEFAULT 1 NOT NULL;

ALTER TABLE datagenie.tracker_points_bin 
    ADD output_version int DEFAULT 1 NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20220928_01.sql', 'DAT-496 add column with AS output version.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-521 

CREATE TABLE datagenie.suppressed_dimension_rules (
	id bigserial NOT NULL,
	created_by varchar(255) NOT NULL,
    dataset_id int NOT NULL,
	enabled boolean DEFAULT TRUE NOT NULL,
	last_updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT suppressed_dimension_rules_PK PRIMARY KEY (id),
    CONSTRAINT suppressed_dimension_rules_FK_datasets FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT suppressed_dimension_rules_FK_users FOREIGN KEY (created_by) REFERENCES datagenie.users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.suppressed_dimensions (
	rule_id bigint NOT NULL,
	dataset_id int NOT NULL,
	attribute_code varchar(500) NOT NULL,
	CONSTRAINT suppressed_dimensions_PK PRIMARY KEY (rule_id,dataset_id,attribute_code),
	CONSTRAINT suppressed_dimensions_FK_attributes FOREIGN KEY (dataset_id,attribute_code) REFERENCES datagenie.attributes(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT suppressed_dimensions_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.suppressed_dimension_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.suppressed_dimension_values (
	rule_id bigint NOT NULL,
	attribute_value_id varchar(500) NOT NULL,
	CONSTRAINT suppressed_dimension_values_PK PRIMARY KEY (rule_id,attribute_value_id),
	CONSTRAINT suppressed_dimension_values_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.suppressed_dimension_rules(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT suppressed_dimension_values_FK_attribute_values FOREIGN KEY (attribute_value_id) REFERENCES datagenie.attribute_values(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.suppressed_custom_aggregations (
	rule_id bigint NOT NULL,
	dataset_id int NOT NULL,
	custom_aggregation_code varchar(150) NOT NULL,
	CONSTRAINT suppressed_custom_aggregations_PK PRIMARY KEY (rule_id,dataset_id,custom_aggregation_code),
	CONSTRAINT suppressed_custom_aggregations_FK_kpis FOREIGN KEY (dataset_id,custom_aggregation_code) REFERENCES datagenie.custom_aggregations(dataset_id,code),
	CONSTRAINT suppressed_custom_aggregations_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.suppressed_dimension_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221006_01.sql', 'DAT-521 create table for suppresion rules.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-529

INSERT INTO datagenie.sources (id,name) VALUES (7,'mssql');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221013_01.sql', 'DAT-529 Add MS SQL as a data source.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-561

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
	 ('unlimited_overlay_attributes','Unlimited Overlay attributes',false);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221020_01.sql', 'DAT-561 Allow unlimited attributes in overlay.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-551

ALTER TABLE datagenie.dashboards ADD global_filters_disabled boolean DEFAULT FALSE NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221021_01.sql', 'DAT-551: add column to disable dashboard filters.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-551

INSERT INTO datagenie.permission_groups (code,name) VALUES
	 ('dashboards','Dashboards');

ALTER TABLE datagenie.permissions DROP CONSTRAINT ckc_permissions_resource_type;

ALTER TABLE datagenie.permissions ADD CONSTRAINT ckc_permissions_resource_type 
CHECK (resource_type='DATASET' OR resource_type='TENANT' OR resource_type='USER' OR resource_type = 'DASHBOARD');

INSERT INTO datagenie.permissions (id, group_code, name, resource_type) VALUES
(20, 'dashboards', 'Add', 'DASHBOARD'),
(21, 'dashboards', 'Delete', 'DASHBOARD'),
(22, 'dashboards', 'Modify', 'DASHBOARD'),
(23, 'dashboards', 'View', 'DASHBOARD');

INSERT INTO datagenie.roles_permissions (role_id, permission_id) VALUES
(2, 20),
(2, 21),
(2, 22),
(2, 23);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221021_02.sql', 'DAT-454: RBAC for Dashboards.', 'lukasz@codez.ai');

ALTER TABLE datagenie.dashboard_widgets DROP CONSTRAINT ckc_dashboard_widget_type;

ALTER TABLE datagenie.dashboard_widgets ADD CONSTRAINT ckc_dashboard_widget_type 
CHECK (type='label' OR type='scorecard' OR type='plot' OR type = 'line' OR type = 'rectangle');


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221025_01.sql', 'Add new widget types.', 'lukasz@codez.ai');

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
	 ('dashboards_enabled','Dashboards feature',false);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221027_01.sql', 'Dashboards feature.', 'lukasz@codez.ai');
ALTER TABLE datagenie.dashboards ADD descriptiondisabled boolean DEFAULT FALSE NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221109_01.sql', 'Add DESCRIPTIONDISABLED column.', 'lukasz@codez.ai');
INSERT INTO datagenie.sources (id,name)
	VALUES (8,'redshift');

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
	 ('connectors_redshift_enabled','Redshift connector available',false);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221116_01.sql', 'Redshift data source feature.', 'lukasz@codez.ai');
ALTER TABLE datagenie.dataset_granularities ADD regular_as_nodes int NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20221127_01.sql', 'Add column for AS num_workers override', 'bala@codez.ai');
ALTER TABLE datagenie.dashboard_widgets DROP CONSTRAINT ckc_dashboard_widget_type;

ALTER TABLE datagenie.dashboard_widgets ADD CONSTRAINT ckc_dashboard_widget_type 
CHECK (type='label' OR type='scorecard' OR type='plot' OR type = 'line' OR type = 'rectangle' OR type = 'miniplot' OR type = 'barchart');


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230127_01.sql', 'Add new widget types.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-813

INSERT INTO datagenie.sources (id,name) VALUES (9,'snowflake');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230222_01.sql', 'DAT-813 Add Snowflake as a data source.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-828


CREATE TABLE datagenie.filtering_rules (
	id bigserial NOT NULL,
	name varchar(256) NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	last_updated_at timestamp DEFAULT now() NOT NULL,
	created_by varchar(255) NOT NULL,
	dataset_id int NOT NULL,
    CONSTRAINT filtering_rules_PK PRIMARY KEY (id),
	CONSTRAINT filtering_rules_FK_users FOREIGN KEY (created_by) REFERENCES datagenie.users(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT filtering_rules_FK_datasets FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE datagenie.dimension_filters (
	rule_id bigint NOT NULL,
	dataset_id int NOT NULL,
	attribute_code varchar(500) NOT NULL,
    CONSTRAINT dimension_filters_PK PRIMARY KEY (rule_id,dataset_id,attribute_code),
	CONSTRAINT dimension_filters_FK_attributes FOREIGN KEY (dataset_id,attribute_code) REFERENCES datagenie.attributes(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT dimension_filters_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.dimension_filter_values (
	rule_id bigint NOT NULL,
	attribute_value_id varchar(500) NOT NULL,
	CONSTRAINT dimension_filter_values_PK PRIMARY KEY (rule_id,attribute_value_id),
	CONSTRAINT dimension_filter_values_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT dimension_filter_values_FK_attribute_values FOREIGN KEY (attribute_value_id) REFERENCES datagenie.attribute_values(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.kpi_filters (
	rule_id bigint NOT NULL,
	dataset_id int NOT NULL,
	custom_aggregation_code varchar(150) NOT NULL,
    min_value numeric(15, 4) NULL,
    max_value numeric(15, 4) NULL,
	CONSTRAINT kpi_filters_PK PRIMARY KEY (rule_id,dataset_id,custom_aggregation_code),
	CONSTRAINT kpi_filters_FK_kpis FOREIGN KEY (dataset_id,custom_aggregation_code) REFERENCES datagenie.custom_aggregations(dataset_id,code),
	CONSTRAINT kpi_filters_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.deviation_filters (
	rule_id bigint NOT NULL,
    positive_severities varchar(64) NOT NULL,
    negative_severities varchar(64) NOT NULL,
	desirable_severities varchar(64) NOT NULL,
    undesirable_severities varchar(64) NOT NULL,
	min_value numeric(15, 4) NULL,
    max_value numeric(15, 4) NULL,
	CONSTRAINT deviation_filters_PK PRIMARY KEY (rule_id),
	CONSTRAINT deviation_filters_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.impact_score_filters (
	rule_id bigint NOT NULL,
    min_value numeric(15, 4) NULL,
    max_value numeric(15, 4) NULL,
	CONSTRAINT impact_score_filters_PK PRIMARY KEY (rule_id),
	CONSTRAINT impact_score_filters_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.subpopulation_filters (
	rule_id bigint NOT NULL,
    min_value numeric(15, 4) NULL,
    max_value numeric(15, 4) NULL,
	CONSTRAINT subpopulation_filters_PK PRIMARY KEY (rule_id),
	CONSTRAINT subpopulation_filters_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.depth_filters (
	rule_id bigint NOT NULL,
    depths varchar(16) NOT NULL,
	CONSTRAINT depth_filters_PK PRIMARY KEY (rule_id),
	CONSTRAINT depth_filters_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230224_01.sql', 'DAT-828 create table for filtering rules.', 'lukasz@codez.ai');
-- DAT-912

ALTER TABLE datagenie.dashboard_widgets ADD z_index int DEFAULT 0 NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230307_01.sql', 'DAT-912 add Z_INDEX column to dashboard_widgets table.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-936

CREATE TABLE datagenie.alert_configurations (
	id bigserial NOT NULL,
	max_top_stories int NOT NULL,
	show_contributors boolean NOT NULL,
	channel_id int NOT NULL,
	dataset_id int NOT NULL,
	enabled boolean NOT NULL,
	CONSTRAINT alert_configurations_PK PRIMARY KEY (id),
	CONSTRAINT alert_configurations_FK FOREIGN KEY (channel_id) REFERENCES datagenie.alert_channels(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT alert_configurations_FK_1 FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.alert_configurations_filtering_rules (
	alert_configuration_id bigint NOT NULL,
	rule_id bigint NOT NULL,
	CONSTRAINT alert_configurations_filtering_rules_PK PRIMARY KEY (alert_configuration_id,rule_id),
	CONSTRAINT alert_configurations_filtering_rules_FK_configs FOREIGN KEY (alert_configuration_id) REFERENCES datagenie.alert_configurations(id),
	CONSTRAINT alert_configurations_filtering_rules_FK_rules FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id)
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230309_01.sql', 'DAT-936 Tables for Alert configurations.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-828


CREATE TABLE datagenie.granularity_filters (
	rule_id bigint NOT NULL,
	granularities varchar(256) NOT NULL,
	CONSTRAINT granularity_filters_PK PRIMARY KEY (rule_id),
	CONSTRAINT granularity_filters_FK FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE datagenie.filtering_rules ADD is_exclusive boolean DEFAULT false NOT NULL;


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230327_01.sql', 'DAT-828 add granularity filter and is_exclusive flag.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-942

CREATE TABLE datagenie.tracker_counts (
	dataset_id int,
	name varchar(150),
	depth float,
	granularity varchar(10),
	values text,
	CONSTRAINT datagenie_tracker_counts_PK PRIMARY KEY (dataset_id,name ,granularity,depth),
	CONSTRAINT tracker_counts_FK_datasets FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id),
	CONSTRAINT tracker_counts_FK_kpis FOREIGN KEY (dataset_id,name) REFERENCES datagenie.custom_aggregations(dataset_id,code)
);
ALTER TABLE datagenie.dataset_granularities ADD use_ideal_points_if_possible bit NULL;

ALTER TABLE datagenie.dataset_granularities 
	ADD artifacts varchar(100) NULL;

ALTER TABLE datagenie.dataset_granularities 
	ADD reference_kpi varchar(500) NULL;
ALTER TABLE datagenie.dataset_granularities 
	ADD CONSTRAINT dataset_granularities_kpis_FK FOREIGN KEY (dataset_id,reference_kpi) 
		REFERENCES datagenie.custom_aggregations(dataset_id,code);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230424_01.sql', 'DAT-942 Control trackers threshold.', 'bala@codez.ai');
INSERT INTO datagenie.sources (id,name)
	VALUES (10,'s3');

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
	 ('connectors_s3_enabled','S3 connector available',true);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230519_01.sql', 'S3 as a data source feature.', 'lukasz@codez.ai');
ALTER TABLE datagenie.custom_aggregations ADD lower_bound decimal(15,4) NULL;
ALTER TABLE datagenie.custom_aggregations ADD upper_bound decimal(15,4) NULL;

ALTER TABLE datagenie.attributes ADD is_required boolean NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230524_01.sql', 'DB schema changes for Nokia POC.', 'lukasz@codez.ai');-- DAT-1090 filter logic changes

-- remove unused tables
DROP TABLE datagenie.suppressed_custom_aggregations;
DROP TABLE datagenie.suppressed_dimension_values;
DROP TABLE datagenie.suppressed_dimensions;
DROP TABLE datagenie.suppressed_dimension_rules;

ALTER TABLE datagenie.kpi_filters ADD is_data_filter boolean DEFAULT TRUE NOT NULL;
ALTER TABLE datagenie.kpi_filters ADD is_view_filter boolean DEFAULT TRUE NOT NULL;

ALTER TABLE datagenie.filtering_rules ADD kpis_logical_condition varchar(8) DEFAULT 'AND' NOT NULL;
ALTER TABLE datagenie.filtering_rules ADD dimensions_logical_condition varchar(8) DEFAULT 'OR' NOT NULL;

ALTER TABLE datagenie.filtering_rules ADD CONSTRAINT ckc_kpis_logical_condition 
CHECK (kpis_logical_condition='AND' OR kpis_logical_condition='OR');

ALTER TABLE datagenie.filtering_rules ADD CONSTRAINT ckc_dimensions_logical_condition 
CHECK (dimensions_logical_condition='AND' OR dimensions_logical_condition='OR');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230530_01.sql', 'DAT-1090: DB schema changes for filters.', 'lukasz@codez.ai');
INSERT INTO datagenie.feature_flags (code, display_name, enabled) 
VALUES('genie_plus_enabled', 'Genie+ feature', false);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230605_01.sql', 'DAT-1070: Add feature flag for Genie+.', 'lukasz@codez.ai');
ALTER TABLE datagenie.dashboard_widgets DROP CONSTRAINT ckc_dashboard_widget_type;

ALTER TABLE datagenie.dashboard_widgets ADD CONSTRAINT ckc_dashboard_widget_type 
CHECK (type='table' OR type='label' OR type='scorecard' OR type='plot' OR type = 'line' OR type = 'rectangle' OR type = 'miniplot' OR type = 'barchart');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230727_01.sql', 'Add widget type for Table.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-1598

INSERT INTO datagenie.sources (id,name) VALUES (11,'gcs');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20230822_01.sql', 'DAT-1598 Add GCS as a data source.', 'lukasz@codez.ai');
ALTER TABLE datagenie.dataset_granularities 
    ADD genie_plus_enabled boolean DEFAULT false NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('202300904_01.sql', 'DAT-1624 Add Genie+ enabled flag.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-1876

CREATE TABLE datagenie.top_story_summarizations (
	dataset_id integer NOT NULL,
	granularity varchar(10) NOT NULL,
	point_timestamp timestamp NOT NULL,
    story_id integer NOT NULL,
	text_summary text NOT NULL,
	CONSTRAINT top_story_summarizations_PK PRIMARY KEY (dataset_id,granularity,point_timestamp, story_id),
	CONSTRAINT top_story_summarizations_datasets_FK FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20231012_01.sql', 'DAT-1876 Add table for Top Story summarization.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-1898

ALTER TABLE datagenie.custom_aggregations ADD bounds_updated_at timestamp NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20231017_01.sql', 'DAT-1898: Last modification date for KPI min/max.', 'lukasz@datagenie.ai');
-- https://codezzz.atlassian.net/browse/DAT-1926

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
	 ('top_story_feedback','Ability to add Top Story feedback',false);

DROP TABLE datagenie.user_feedback;

DROP TABLE datagenie.user_feedback_options;

CREATE TABLE datagenie.top_stories_feedback (
    id bigserial NOT NULL, 
	dataset_id int NOT NULL,
	granularity varchar(10) NOT NULL,
	point_timestamp timestamp NOT NULL,
    story_id int NOT NULL,
    created_by varchar(255) NOT NULL,
    reaction_code varchar(24) NOT NULL,
    root_dimensions text NULL,
    kpis text NULL,
    dimensions text NULL,
	CONSTRAINT top_story_feedback_PK PRIMARY KEY (id),
    CONSTRAINT top_stories_feedback_FK_users FOREIGN KEY (created_by) REFERENCES datagenie.users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT top_stories_feedback_FK_datasets FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20231022_01.sql', 'DAT-1926: Top Stories feedback.', 'lukasz@datagenie.ai');
-- DG-1659

ALTER TABLE datagenie.filtering_rules ADD is_default boolean NOT NULL DEFAULT false;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20231127_01.sql', 'DG-1659: add column to mark default filter preset.', 'lukasz@datagenie.ai');
-- DG-2423

ALTER TABLE datagenie.dashboard_widgets DROP CONSTRAINT ckc_dashboard_widget_type;

ALTER TABLE datagenie.dashboard_widgets ADD CONSTRAINT ckc_dashboard_widget_type 
CHECK (type='table' OR type='label' OR type='scorecard' OR type='plot' OR type = 'line' OR type = 'rectangle' OR type = 'miniplot' OR type = 'barchart' OR type = 'pie');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20231204_01.sql', 'Add Pie chart widget type.', 'lukasz@codez.ai');
-- https://codezzz.atlassian.net/browse/DAT-1598

INSERT INTO datagenie.sources (id,name) VALUES (12,'mongodb');

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
	 ('connectors_mongodb_enabled','MongoDB connector available',false);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20231206_01.sql', 'DG-2448: add MongoDB data source type.', 'lukasz@datagenie.ai');

CREATE TABLE datagenie.notebooks (
    id bigserial NOT NULL,
    name varchar(1024) NOT NULL,
    creation_date timestamp NOT NULL,
    last_use_date timestamp NOT NULL,
    user_id varchar(255),
    is_favourite boolean NOT NULL DEFAULT FALSE,
    dataset_thread_assoc text,

    CONSTRAINT notebooks_PK PRIMARY KEY (id),
    CONSTRAINT notebooks_users_FK FOREIGN KEY (user_id) REFERENCES datagenie.users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.notebook_entries (
    id bigserial NOT NULL,
    creation_date timestamp NOT NULL,
    prompt text NOT NULL,
    answer text,
    dataset_id integer NOT NULL,
    notebook_id integer NOT NULL,
    is_favourite boolean NOT NULL DEFAULT FALSE,
    is_thumb_up boolean NOT NULL DEFAULT FALSE,
    is_thumb_down boolean NOT NULL DEFAULT FALSE,
    feedback text DEFAULT NULL,

    CONSTRAINT notebook_entry_PK PRIMARY KEY (id),
    CONSTRAINT notebook_entries_datasets_FK FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE,
    CONSTRAINT notebook_entries_notebooks_FK FOREIGN KEY (notebook_id) REFERENCES datagenie.notebooks(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.notebook_data_connections (
    id bigserial NOT NULL,
    notebook_entry_id integer NOT NULL,
    granularity varchar(10),
    date_from timestamp,
    date_to timestamp,

    CONSTRAINT notebook_data_connections_PK PRIMARY KEY (id),
    CONSTRAINT notebook_data_connections_notebook_entries_FK FOREIGN KEY (notebook_entry_id) REFERENCES datagenie.notebook_entries(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.notebook_suggestions (
    id bigserial NOT NULL,
    prompt text NOT NULL,
    bookmarked boolean NOT NULL DEFAULT FALSE,
    notebook_entry_id integer NOT NULL,

    CONSTRAINT notebook_suggestions_PK PRIMARY KEY (id),
    CONSTRAINT notebook_suggestions_notebook_entries_FK FOREIGN KEY (notebook_entry_id) REFERENCES datagenie.notebook_entries (id) ON DELETE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20240105_01.sql', 'DG-2532: create schema for Genie+ 2.0 notebooks', 'WiktorUtracki');-- https://app.clickup.com/t/9006018026/DG-2689

CREATE TABLE datagenie.report_templates (
	id bigserial NOT NULL,
    dataset_id int NULL,
    active boolean NOT NULL DEFAULT FALSE,
	report_title varchar(256) NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
    created_by varchar(255) NOT NULL,
    updated_at timestamp DEFAULT now() NOT NULL,
    updated_by varchar(255) NOT NULL,
    frequency varchar(50) NOT NULL
        CONSTRAINT ckc_frequency CHECK (frequency IN ('daily', 'weekly', 'monthly', 'quarterly')),
    period int NOT NULL,
    time_unit varchar(64) NOT NULL
        CONSTRAINT ckc_time_units CHECK (time_unit IN ('HOURS', 'DAYS', 'WEEKS', 'MONTHS','QUARTERS')),

    CONSTRAINT report_templates_pk PRIMARY KEY (id),
    CONSTRAINT report_templates_datasets_fk FOREIGN KEY (dataset_id) 
        REFERENCES datagenie.datasets(id) ON DELETE CASCADE,
    CONSTRAINT report_templates_users_creator_fk FOREIGN KEY (created_by) 
        REFERENCES datagenie.users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT report_templates_users_updater_fk FOREIGN KEY (created_by) 
        REFERENCES datagenie.users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.report_templates_kpis (
    report_template_id int NOT NULL,
    dataset_id int NOT NULL,
    kpi_code varchar(150) NOT NULL,
    kpi_order int NOT NULL,

    CONSTRAINT report_templates_kpis_pk PRIMARY KEY (report_template_id, dataset_id, kpi_code),
    CONSTRAINT report_templates_fk FOREIGN KEY (report_template_id) 
        REFERENCES datagenie.report_templates(id) ON DELETE CASCADE,
    CONSTRAINT report_templates_kpis_datasets_fk FOREIGN KEY (dataset_id) 
        REFERENCES datagenie.datasets(id) ON DELETE CASCADE,
	CONSTRAINT report_templates_kpis_custom_aggregations_fk FOREIGN KEY (dataset_id,kpi_code) 
        REFERENCES datagenie.custom_aggregations(dataset_id,code) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE datagenie.report_templates_dimensions (
    report_template_id int NOT NULL,
    dataset_id int NOT NULL,
	attribute_code varchar(500) NOT NULL,
    attribute_order int NOT NULL,

    CONSTRAINT report_templates_dimensions_pk PRIMARY KEY (report_template_id, dataset_id, attribute_code),
    CONSTRAINT report_templates_fk FOREIGN KEY (report_template_id) 
        REFERENCES datagenie.report_templates(id) ON DELETE CASCADE,
    CONSTRAINT report_templates_dimensions_datasets_fk FOREIGN KEY (dataset_id) 
        REFERENCES datagenie.datasets(id) ON DELETE CASCADE,
	CONSTRAINT report_templates_dimensions_attributes FOREIGN KEY (dataset_id,attribute_code) 
        REFERENCES datagenie."attributes"(dataset_id,code) ON DELETE CASCADE
);

CREATE TABLE datagenie.report_templates_filters (
    report_template_id int NOT NULL,
    attribute_value_id varchar(500) NOT NULL,
	
    CONSTRAINT report_templates_filters_pk PRIMARY KEY (report_template_id, attribute_value_id),
	CONSTRAINT report_templates_filters_attribute_values_fk FOREIGN KEY (attribute_value_id)
        REFERENCES datagenie.attribute_values(id) ON DELETE CASCADE,
    CONSTRAINT report_templates_filters_templates_fk FOREIGN KEY (report_template_id)
        REFERENCES datagenie.report_templates(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.report_runs (
	id varchar(256) NOT NULL,
	report_template_id int NOT NULL,
	generated_at timestamp DEFAULT now() NOT NULL,
	status varchar(32) NOT NULL 
        CONSTRAINT ckc_status CHECK (status IN ('ready', 'failed', 'running')),
	folder varchar(500) NOT NULL,
	generated_by varchar(100) NULL,
	
    CONSTRAINT report_runs_pk PRIMARY KEY (id),
    CONSTRAINT report_runs_templates_fk FOREIGN KEY (report_template_id) 
        REFERENCES datagenie.report_templates(id) ON DELETE CASCADE,
    CONSTRAINT report_runs_users_fk FOREIGN KEY (generated_by) 
        REFERENCES datagenie.users(id)
);

-- RBAC

INSERT INTO datagenie.permission_groups (code,name) VALUES
	 ('reports','Reports');

ALTER TABLE datagenie.permissions DROP CONSTRAINT ckc_permissions_resource_type;

ALTER TABLE datagenie.permissions ADD CONSTRAINT ckc_permissions_resource_type 
CHECK (resource_type='DATASET' OR resource_type='TENANT' OR resource_type='USER' OR resource_type = 'DASHBOARD' OR resource_type = 'REPORT');

INSERT INTO datagenie.permissions (id, group_code, name, resource_type) VALUES
(24, 'reports', 'Add', 'REPORT'),
(25, 'reports', 'Delete', 'REPORT'),
(26, 'reports', 'Modify', 'REPORT'),
(27, 'reports', 'View', 'REPORT');

INSERT INTO datagenie.roles_permissions (role_id, permission_id) VALUES
(2, 24),
(2, 25),
(2, 26),
(2, 27);

-- feature flag

INSERT INTO datagenie.feature_flags (code,display_name,enabled) VALUES
('reporting_module','Enable Reporting module', false);


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240126_01.sql', 'DG-2689: schema for Report Management.', 'lukasz@codez.ai');
ALTER TABLE datagenie.report_templates 
ADD COLUMN type varchar(255);

ALTER TABLE datagenie.report_templates_dimensions 
ADD COLUMN type varchar(255),
ADD COLUMN display_name varchar(255) DEFAULT NULL; 

ALTER TABLE datagenie.report_templates_kpis
ADD COLUMN display_name varchar(255) DEFAULT NULL; 

ALTER TABLE datagenie.report_runs
ADD COLUMN name varchar(255),
ADD COLUMN date_from timestamp NOT NULL,
ADD COLUMN date_to timestamp NOT NULL,
ADD COLUMN is_ad_hoc boolean NOT NULL DEFAULT FALSE,
ADD COLUMN date_column varchar(255);

ALTER TABLE datagenie.report_templates_dimensions
ADD COLUMN order_by varchar(4) DEFAULT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240206_01.sql', 'Adapt reports schema for snapshots and ad-hoc reports', 'WiktorUtracki');-- https://app.clickup.com/t/9006018026/DG-2978

ALTER TABLE datagenie.notebooks ADD last_used_by varchar(255);
ALTER TABLE datagenie.notebooks ADD CONSTRAINT notebooks_users_last_used_fk FOREIGN KEY (last_used_by) REFERENCES datagenie.users(id) ON DELETE CASCADE;
UPDATE datagenie.notebooks n SET last_used_by = (SELECT n1.user_id from datagenie.notebooks n1 where n1.id = n.id);
ALTER TABLE datagenie.notebooks ALTER COLUMN last_used_by SET NOT NULL;

ALTER TABLE datagenie.notebook_entries ADD created_by varchar(255);
ALTER TABLE datagenie.notebook_entries ADD CONSTRAINT notebook_entries_created_byusers_fk FOREIGN KEY (created_by) REFERENCES datagenie.users(id) ON DELETE CASCADE;
    UPDATE datagenie.notebook_entries ne SET created_by = (SELECT n.user_id from datagenie.notebooks n where n.id = ne.notebook_id);
ALTER TABLE datagenie.notebook_entries ALTER COLUMN created_by SET NOT NULL;

CREATE TABLE datagenie.notebook_shares (
    shared_at timestamp NOT NULL,
    notebook_id integer NOT NULL,
    shared_by varchar(255),
    shared_with varchar(255),
    share_permissions varchar(16) NOT NULL DEFAULT 'READ_WRITE'
        CONSTRAINT ckc__share_permissions CHECK (share_permissions IN ('READ_ONLY', 'READ_WRITE')),
    
    CONSTRAINT notebook_shares_pk PRIMARY KEY (notebook_id, shared_with),
    CONSTRAINT notebook_shares_notebooks_fk FOREIGN KEY (notebook_id) REFERENCES datagenie.notebooks(id) ON DELETE CASCADE,
    CONSTRAINT notebook_shares_1_users_fk FOREIGN KEY (shared_by) 
        REFERENCES datagenie.users(id) ON DELETE CASCADE,
    CONSTRAINT notebook_shares_2_users_fk FOREIGN KEY (shared_with) 
        REFERENCES datagenie.users(id) ON DELETE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240312_01.sql', 'Schema changes for Notebook sharing', 'lukasz@codez.ai');-- https://app.clickup.com/t/9006018026/DG-2981

CREATE TABLE datagenie.multi_scenario_analysis (
	id bigserial NOT NULL,
	"name" varchar(1024) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	executed_at timestamp NOT NULL,
	created_by varchar(255) NOT NULL,
	updated_by varchar(255) NOT NULL,
	executed_by varchar(255) NOT NULL,
	forecast_period int NULL,
	forecast_time_unit varchar(12) DEFAULT 'DAYS' NOT NULL,
	CONSTRAINT multi_scenario_analysis_pk PRIMARY KEY (id),
	CONSTRAINT multi_scenario_analysis_time_units_check CHECK (forecast_time_unit IN ('HOURS', 'DAYS', 'WEEKS', 'MONTHS','QUARTERS')),
	CONSTRAINT multi_scenario_analysis_users_fk FOREIGN KEY (created_by) REFERENCES datagenie.users(id) ON DELETE CASCADE,
	CONSTRAINT multi_scenario_analysis_updater_users_fk FOREIGN KEY (updated_by) REFERENCES datagenie.users(id),
	CONSTRAINT multi_scenario_analysis_executer_users_fk FOREIGN KEY (executed_by) REFERENCES datagenie.users(id)
);

CREATE TABLE datagenie.multi_scenario_analysis_scenarios (
	id bigserial NOT NULL,
	analysis_id bigint NOT NULL,
	"name" varchar(1024) NOT NULL,
	is_baseline boolean DEFAULT false NOT NULL,
    created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	created_by varchar(255) NOT NULL,
	updated_by varchar(255) NOT NULL,
	CONSTRAINT multi_scenario_analysis_scenarios_pk PRIMARY KEY (id),
    CONSTRAINT multi_scenario_analysis_scenarios_creator_users_fk FOREIGN KEY (created_by) REFERENCES datagenie.users(id) ON DELETE CASCADE,
	CONSTRAINT multi_scenario_analysis_scenarios_updater_users_fk FOREIGN KEY (updated_by) REFERENCES datagenie.users(id),
    CONSTRAINT multi_scenario_analysis_scenarios_multi_scenario_analysis_fk FOREIGN KEY (analysis_id) REFERENCES datagenie.multi_scenario_analysis(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.multi_scenario_analysis_kpis (
	scenario_id bigint NOT NULL,
	dataset_id int NOT NULL,
	kpi_code varchar(150) NOT NULL,
    granularity varchar(12) NOT NULL,
    sensitivity varchar(8) NOT NULL,
	is_regressor boolean DEFAULT false NOT NULL,
	last_forecast text NULL,
	CONSTRAINT multi_scenario_analysis_kpis_pk PRIMARY KEY (scenario_id,dataset_id,kpi_code),
	CONSTRAINT multi_scenario_analysis_kpis_custom_aggregations_fk FOREIGN KEY (dataset_id,kpi_code) REFERENCES datagenie.custom_aggregations(dataset_id,code),
	CONSTRAINT multi_scenario_analysis_kpis_multi_scenario_analysis_scenarios_fk FOREIGN KEY (scenario_id) REFERENCES datagenie.multi_scenario_analysis_scenarios(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.multi_scenario_analysis_dimensions (
	scenario_id bigint NOT NULL,
	attribute_value_id varchar(500) NOT NULL,
	CONSTRAINT multi_scenario_analysis_dimensions_unique UNIQUE (scenario_id,attribute_value_id),
	CONSTRAINT multi_scenario_analysis_dimensions_attribute_values_fk FOREIGN KEY (attribute_value_id) REFERENCES datagenie.attribute_values(id),
	CONSTRAINT multi_scenario_analysis_dimensions_multi_scenario_analysis_scenarios_fk FOREIGN KEY (scenario_id) REFERENCES datagenie.multi_scenario_analysis_scenarios(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.scenario_analysis_shares (
    shared_at timestamp NOT NULL,
    scenario_analysis_id integer NOT NULL,
    shared_by varchar(255),
    shared_with varchar(255),
    share_permissions varchar(16) NOT NULL DEFAULT 'READ_WRITE'
        CONSTRAINT ckc__share_permissions CHECK (share_permissions IN ('READ_ONLY', 'READ_WRITE')),
    
    CONSTRAINT scenario_analytics_shares_pk PRIMARY KEY (scenario_analysis_id, shared_with),
    CONSTRAINT scenario_analytics_shares_scenario_analytics_fk FOREIGN KEY (scenario_analysis_id) REFERENCES datagenie.multi_scenario_analysis(id) ON DELETE CASCADE,
    CONSTRAINT scenario_analytics_shares_1_users_fk FOREIGN KEY (shared_by) 
        REFERENCES datagenie.users(id) ON DELETE CASCADE,
    CONSTRAINT scenario_analytics_shares_2_users_fk FOREIGN KEY (shared_with) 
        REFERENCES datagenie.users(id) ON DELETE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240313_01.sql', 'DG-2981: Schema changes for MSF CRUD', 'lukasz@codez.ai');-- dataset auto selection

ALTER TABLE datagenie.notebook_entries ALTER COLUMN dataset_id DROP NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240429_01.sql', 'DG-3124: make dataset id column optional.', 'lukasz@codez.ai');
-- DG-3102

INSERT INTO datagenie.permission_groups (code,name) VALUES
	 ('credentials','Credentials Management');
	
INSERT INTO datagenie.permissions (id, group_code,"name",resource_type) VALUES
	 (28, 'credentials','View Credentials','DATASET'),
	 (29, 'credentials','Edit Credentials','DATASET');

INSERT INTO datagenie.roles (id, "name",is_dataset_specific,is_system,is_tenant_specific) VALUES
	 (-1, 'Dataset Specific - Admin',true,true,false);

INSERT INTO datagenie.roles_permissions (role_id,permission_id) VALUES
	 (-1,28),
	 (-1,29),
	 (-1,1),
	 (-1,4),
	 (-1,6),
	 (-1,11);

UPDATE datagenie.roles SET "name"='Dataset Specific - Reader' WHERE id=4;
UPDATE datagenie.roles SET "name"='Dataset Specific - Editor' WHERE id=5;
UPDATE datagenie.roles SET "name"='Global - Admin' WHERE id=2;
UPDATE datagenie.roles SET "name"='Tenant Specific - Reader' WHERE id=6;
UPDATE datagenie.roles SET "name"='Tenant Specific - Editor' WHERE id=7;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240508_01.sql', 'DG-3102: rename default roles and add new permission group Credentials Management.', 'lukasz@codez.ai');
-- https://app.clickup.com/t/9006018026/DG-3245

ALTER TABLE datagenie.dataset_granularities 
ADD genie_plus_status varchar(32) DEFAULT 'NONE' NOT NULL;

ALTER TABLE datagenie.dataset_granularities 
    ADD CONSTRAINT dataset_granularities_check 
    CHECK (genie_plus_status = 'NONE' or genie_plus_status = 'ONBOARDING' OR  genie_plus_status = 'FAILED' OR genie_plus_status = 'SUCCESS');

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240603_01.sql', 'DG-3245: add genie_plus_status column.', 'lukasz@codez.ai');-- https://app.clickup.com/t/9006018026/DG-3253

ALTER TABLE datagenie.datasets ADD gp_default_kpi varchar(150) NULL;
COMMENT ON COLUMN datagenie.datasets.gp_default_kpi IS 'Default KPI for Genie+';

ALTER TABLE datagenie.datasets ADD gp_start_date timestamp NULL;
COMMENT ON COLUMN datagenie.datasets.gp_start_date IS 'Default start date for Genie+';

ALTER TABLE datagenie.datasets ADD gp_end_date timestamp NULL;
COMMENT ON COLUMN datagenie.datasets.gp_end_date IS 'Default end date for Genie+';

ALTER TABLE datagenie.datasets ADD gp_priority_order int NULL;
COMMENT ON COLUMN datagenie.datasets.gp_priority_order IS 'Dataset priority for Genie+';

ALTER TABLE datagenie.datasets ADD CONSTRAINT datasets_custom_aggregations_fk 
FOREIGN KEY (id,gp_default_kpi) REFERENCES datagenie.custom_aggregations(dataset_id,code);

ALTER TABLE datagenie.dataset_granularities DROP COLUMN genie_plus_enabled;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240603_02.sql', 'DG-3253: add table for dataset metadata.', 'lukasz@codez.ai');-- DG-3315

ALTER TABLE datagenie.notebook_entries ADD dataset_autodetected boolean DEFAULT false NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240613_01.sql', 'DG-3315: add dataset_autodetected flag.', 'lukasz@codez.ai');
-- DG-3359

INSERT INTO datagenie.sources (id,name) VALUES (13,'postgresql');

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20240620_01.sql', 'DAT-529 Add PostgreSQL as a data source.', 'MichalWieczorek');
-- DG-3266

ALTER TABLE datagenie.notebook_suggestions ADD structured_prompt text DEFAULT '{}' NOT NULL;
COMMENT ON COLUMN datagenie.notebook_suggestions.structured_prompt IS 'JSON with Structured Prompt';

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240719_01.sql', 'DG-3266: add structured prompt to notebook suggestion.', 'lukasz@codez.ai');-- CUS-1156

ALTER TABLE datagenie.datasets ADD has_ts_in_mongo boolean DEFAULT false NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240820_01.sql', 'CUS-1156: add has_ts_in_mongo flag to datasets table.', 'lukasz@codez.ai');
-- CUS-1164


ALTER TABLE datagenie.filtering_rules ADD contributor_dimensions_logical_condition varchar(8) DEFAULT 'OR' NOT NULL;

ALTER TABLE datagenie.dimension_filters ADD is_contributor boolean DEFAULT false NOT NULL;

ALTER TABLE datagenie.dimension_filter_values ADD is_contributor boolean DEFAULT false NOT NULL;

ALTER TABLE datagenie.dimension_filter_values DROP CONSTRAINT dimension_filter_values_pk;
ALTER TABLE datagenie.dimension_filter_values ADD CONSTRAINT dimension_filter_values_pk PRIMARY KEY (rule_id,attribute_value_id,is_contributor);

ALTER TABLE datagenie.dimension_filters DROP CONSTRAINT dimension_filters_pk;
ALTER TABLE datagenie.dimension_filters ADD CONSTRAINT dimension_filters_pk PRIMARY KEY (rule_id,dataset_id,attribute_code,is_contributor);


INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240823_01.sql', 'CUS-1164: add is_contributor flag to dimension filter tables.', 'lukasz@codez.ai');-- DG-3659

ALTER TABLE datagenie.notebooks ADD is_deleted boolean DEFAULT false NOT NULL;

ALTER TABLE datagenie.notebook_entries ADD is_deleted boolean DEFAULT false NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20240828_01.sql', 'DG-3659: add is_deleted flag to notebooks and notebook_entries tables.', 'MichalWieczorek');-- DG-3992

ALTER TABLE datagenie.custom_aggregations RENAME COLUMN show_in_top_stories TO generate_insights;
ALTER TABLE datagenie.custom_aggregations ADD derived_kpi_expression text NULL;
ALTER TABLE datagenie.custom_aggregations ADD show_in_ui bool DEFAULT true NOT NULL;
ALTER TABLE datagenie.custom_aggregations ADD is_distinct bool DEFAULT false NOT NULL;
ALTER TABLE datagenie.custom_aggregations ADD derived_kpi_parts text NULL;

UPDATE datagenie.datagenie.custom_aggregations SET show_in_ui = true;

COMMENT ON COLUMN datagenie.custom_aggregations.derived_kpi_expression IS 'Derived KPI definition';
COMMENT ON COLUMN datagenie.custom_aggregations.derived_kpi_parts IS 'Comma separated list of KPI codes used in Derived KPI expression.';

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240829_01.sql', 'DG-3992: schema for Derived KPIs', 'lukasz@codez.ai');-- DG-3708

CREATE TABLE datagenie.user_filtering_rules (
	user_id varchar(255) NOT NULL,
	rule_id bigserial NOT NULL,
	dataset_id int4 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT user_filtering_rules_pk PRIMARY KEY (user_id,dataset_id),
	CONSTRAINT user_filtering_rules_filtering_rules_fk FOREIGN KEY (rule_id) REFERENCES datagenie.filtering_rules(id),
	CONSTRAINT user_filtering_rules_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id),
	CONSTRAINT user_filtering_rules_users_fk FOREIGN KEY (user_id) REFERENCES datagenie.users(id)
);
COMMENT ON TABLE datagenie.user_filtering_rules IS 'User default filters per dataset.';

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240904_01.sql', 'DG-3708: user default filters', 'lukasz@codez.ai');-- DG-3777

CREATE TABLE datagenie.fiscal_calendars (
	id bigserial NOT NULL,
	client_code varchar(50) NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by varchar(255) NOT NULL,
	CONSTRAINT fiscal_calendars_pk PRIMARY KEY (id),
	CONSTRAINT fiscal_calendars_users_fk FOREIGN KEY (created_by) REFERENCES datagenie.users(id),
	CONSTRAINT fiscal_calendars_clients_fk FOREIGN KEY (client_code) REFERENCES datagenie.clients(code)
);

CREATE TABLE datagenie.fiscal_calendar_entries (
	calendar_id int4 NOT NULL,
	point_timestamp timestamp NOT NULL,
	fiscal_year int NOT NULL,
	fiscal_quarter int NOT NULL,
	fiscal_period int NOT NULL,
	fiscal_week int NOT NULL,
	CONSTRAINT fiscal_calendar_entries_pk PRIMARY KEY (calendar_id,point_timestamp),
	CONSTRAINT fiscal_calendar_entries_calendars_fk FOREIGN KEY (calendar_id) REFERENCES datagenie.fiscal_calendars(id) ON DELETE CASCADE
);

CREATE TABLE datagenie.datasets_fiscal_calendars (
	dataset_id int4 NOT NULL,
	calendar_id int4 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by varchar(255) NOT NULL,
	CONSTRAINT datasets_fiscal_calendars_pk PRIMARY KEY (dataset_id,calendar_id),
	CONSTRAINT datasets_fiscal_calendars_fiscal_calendars_fk FOREIGN KEY (calendar_id) REFERENCES datagenie.fiscal_calendars(id),
	CONSTRAINT datasets_fiscal_calendars_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id),
	CONSTRAINT datasets_fiscal_calendars_users_fk FOREIGN KEY (created_by) REFERENCES datagenie.users(id)
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20240925_01.sql', 'DG-3777: schema for Fiscal Calendar', 'lukasz@codez.ai');-- DG-3822

ALTER TABLE datagenie.top_stories_feedback ALTER COLUMN story_id TYPE varchar(255) USING story_id::varchar(255);

DELETE FROM datagenie.top_story_summarizations;
ALTER TABLE datagenie.top_story_summarizations ALTER COLUMN story_id TYPE varchar(255) USING story_id::varchar(255);
ALTER TABLE datagenie.top_story_summarizations DROP CONSTRAINT top_story_summarizations_pk;
ALTER TABLE datagenie.top_story_summarizations ADD CONSTRAINT top_story_summarizations_pk PRIMARY KEY (story_id);

CREATE TABLE datagenie.top_story_summarizations_contributors (
	story_id varchar(255) NOT NULL,
	root_kpi varchar(150) NOT NULL,
	text_summary text NOT NULL,
	dataset_id int4 NOT NULL,
	granularity varchar(10) NOT NULL,
	point_timestamp timestamp NOT NULL,
	CONSTRAINT top_story_summarizations_contributors_pk PRIMARY KEY (story_id),
	CONSTRAINT top_story_summarizations_contributors_custom_aggregations_fk FOREIGN KEY (dataset_id,root_kpi) REFERENCES datagenie.custom_aggregations(dataset_id,code),
	CONSTRAINT top_story_summarizations_contributors_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE
);

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20241011_01.sql', 'DG-3822: schema changes for Top Story summaries', 'lukasz@codez.ai');-- DG-3871

ALTER TABLE datagenie.notebook_entries ADD original_structured_prompt text NULL;

INSERT INTO datagenie.db_scripts (name, description, author) 
VALUES('20241103_01.sql', 'DG-3871: add column for original prompt.', 'lukasz@codez.ai');-- DG-3983

ALTER TABLE datagenie.dataset_granularities ADD COLUMN tc_enabled bool DEFAULT false NULL;
ALTER TABLE datagenie.dataset_granularities ADD COLUMN tc_expression text DEFAULT NULL NULL;

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20241114_01.sql', 'DG-3983: schema changes for TO', 'mathan@codez.ai');
-- https://app.clickup.com/t/9006018026/DG-4110

ALTER TABLE datagenie.dataset_granularities DROP CONSTRAINT ckc_time_units;

UPDATE datagenie.dataset_granularities SET  time_unit='hourly' WHERE time_unit='HOURS' ;
UPDATE datagenie.dataset_granularities SET  time_unit='daily' WHERE time_unit='DAYS' ;
UPDATE datagenie.dataset_granularities SET  time_unit='weekly' WHERE time_unit='WEEKS' ;
UPDATE datagenie.dataset_granularities SET  time_unit='monthly' WHERE time_unit='MONTHS' ;
UPDATE datagenie.dataset_granularities SET  time_unit='quarterly' WHERE time_unit='QUARTERS' ;

ALTER TABLE datagenie.dataset_granularities RENAME COLUMN time_unit TO granularity;
ALTER TABLE datagenie.dataset_granularities ADD CONSTRAINT dataset_granularities_check_granularity CHECK (granularity = 'hourly' OR granularity = 'daily' OR granularity = 'weekly' OR  granularity = 'monthly' OR  granularity = 'quarterly');
ALTER TABLE datagenie.dataset_granularities RENAME COLUMN ad_period TO insights_period;
ALTER TABLE datagenie.dataset_granularities RENAME COLUMN trigger_processing_at TO trigger_time;
ALTER TABLE datagenie.dataset_granularities RENAME COLUMN processing_schedule TO trigger_schedule;
ALTER TABLE datagenie.dataset_granularities ADD no_of_retries int DEFAULT 1 NOT NULL;
COMMENT ON COLUMN datagenie.dataset_granularities.no_of_retries IS 'How many times to retry Job execution.';
ALTER TABLE datagenie.dataset_granularities ADD retry_cool_off_period int DEFAULT 120 NOT NULL;
COMMENT ON COLUMN datagenie.dataset_granularities.retry_cool_off_period IS 'Cool of period in minutes.';
ALTER TABLE datagenie.dataset_granularities ADD additional_config json NULL;
COMMENT ON COLUMN datagenie.dataset_granularities.additional_config IS 'Additional Job configuration.';

CREATE TABLE datagenie.jobs_timetable (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	retry_no int DEFAULT 0 NOT NULL,
	dataset_id bigint NOT NULL,
	granularity varchar(30) NOT NULL,
	job_mode varchar(64) DEFAULT 'regular' NOT NULL,
	processing_start_date timestamp NOT NULL,
	processing_end_date timestamp NOT NULL,
	insight_start_date timestamp NOT NULL,
	insight_end_date timestamp NOT NULL,
	additional_config json NULL,
	scheduled_at timestamp NOT NULL,
	created_by varchar(64) NOT NULL,
	status varchar(64) DEFAULT 'scheduled' NOT NULL,
	CONSTRAINT jobs_timetable_pk PRIMARY KEY (id,retry_no),
	CONSTRAINT jobs_timetable_check_granularity CHECK (granularity = 'hourly' OR granularity = 'daily' OR granularity = 'weekly' OR  granularity = 'monthly' OR  granularity = 'quarterly'),
	CONSTRAINT jobs_timetable_check_status CHECK (status = 'scheduled' OR status = 'running' OR status = 'failed' OR status = 'cancelled' OR status = 'success'),
	CONSTRAINT jobs_timetable_check_job_mode CHECK (job_mode = 'regular' OR job_mode = 'reconciliation' OR job_mode = 'backlog' OR job_mode = 'profiler'),
	CONSTRAINT jobs_timetable_datasets_fk FOREIGN KEY (dataset_id) REFERENCES datagenie.datasets(id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE datagenie.jobs_timetable IS 'Time table for job execution.';

CREATE TABLE datagenie.jobs_timetable_executions (
	timetable_id uuid NOT NULL,
	retry_id int NOT NULL,
	run_id varchar(255) NOT NULL,
	job_name varchar(255) NOT NULL,
	started_at timestamp NOT NULL,
	finished_at timestamp NULL,
	status varchar(64) NOT NULL,
	run_details text NULL,
	submitted_by varchar(64) NOT NULL,
	CONSTRAINT jobs_timetable_executions_check_status CHECK (status = 'scheduled' OR status = 'running' OR status = 'failed' OR status = 'cancelled' OR status = 'success'),
	CONSTRAINT jobs_timetable_executions_jobs_timetable_fk FOREIGN KEY (timetable_id,retry_id) REFERENCES datagenie.jobs_timetable(id,retry_no) ON DELETE CASCADE ON UPDATE CASCADE
);


-- https://app.clickup.com/t/9006018026/DG-4138

ALTER TABLE datagenie.jobs_timetable ADD created_at timestamp DEFAULT now() NOT NULL;
ALTER TABLE datagenie.jobs_timetable ADD last_updated_at timestamp DEFAULT now() NOT NULL;

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20250117_01.sql', 'DG-4110: refactor job scheduling tables.', 'lukasz@codez.ai');BEGIN TRANSACTION;

ALTER TABLE datagenie.dashboards
	ADD COLUMN is_homepage bool NOT NULL DEFAULT FALSE;

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20250217_01.sql', 'DG-4310 Add is_homepage flag to dashboards', 'michel@datagenie.ai');

COMMIT;BEGIN TRANSACTION;

CREATE TABLE datagenie.homepages (
	id serial NOT NULL PRIMARY KEY,
	latest_top_stories_dataset_id int DEFAULT NULL REFERENCES datagenie.datasets(id),
	latest_top_stories_filtering_rule_id int DEFAULT NULL REFERENCES datagenie.filtering_rules(id),
	date_from timestamp DEFAULT NULL,
	date_to timestamp DEFAULT NULL,
	created_at timestamp NOT NULL,
	created_by varchar NOT NULL REFERENCES datagenie.users(id)
);

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20250320_01.sql', 'DG-4428 Implement backend for top stories homepage', 'michel@datagenie.ai');

COMMIT;-- DG-4835

ALTER TABLE datagenie.datasets ADD COLUMN nirvana_components TEXT COLLATE "default" NULL;
COMMENT ON COLUMN datagenie.datasets.nirvana_components IS 'Comma separated values of the nirvana dataset components';

ALTER TABLE datagenie.custom_aggregations ADD COLUMN custom_yhat_mapping varchar(150) NULL;

INSERT INTO datagenie.db_scripts (name, description, author)
VALUES('20250526_01.sql', 'DG-4835 Add bring_yhat_mapping and nirvana_components', 'mathan@datagenie.ai');

