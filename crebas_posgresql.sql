   /*==============================================================*/
   /* Schema: datagenie                                              */
   /*==============================================================*/
   
   create schema airflow;
   
   create schema datagenie
   ;


   /*==============================================================*/
   /* Table: anomaly_summaries                                     */
   /*==============================================================*/
   CREATE TABLE datagenie.anomaly_summaries(
      Id bigserial    not null,
      tracker_id varchar(500)  not null,
      dataset_id int NOT NULL,
      point_timestamp timestamp NOT NULL,
      historical_score decimal(15, 4) NULL,
      attribute_depth decimal(15, 4) NULL,
      attribute_importance numeric(18, 0) NULL,
      attribute_frequency int NOT NULL default 0,
      population decimal(15, 4) NULL default 0,
      cluster_id int NOT NULL,
      root_cause int NOT NULL,
      zscore numeric(15, 4) NULL,
      historical_score_scaled decimal(15, 4) NULL,
      attribute_depth_scaled decimal(15, 4) NULL,
      attribute_importance_scaled decimal(15, 4) NULL,
      attribute_frequency_scaled decimal(15, 4) NULL,
      CONSTRAINT CI_IdentityAS PRIMARY KEY (id, dataset_id) 
   )
   ;

   CREATE INDEX ind_anomaly_summaries_datasets ON datagenie.anomaly_summaries
   (point_timestamp ASC) 
   ;

   CREATE  INDEX NCI_anomaly_summaries_dspcl ON datagenie.anomaly_summaries (dataset_id,tracker_id,point_timestamp)
   INCLUDE (historical_score,population,cluster_id,zscore,historical_score_scaled,attribute_depth_scaled,attribute_importance_scaled,attribute_frequency_scaled)
   ;

   /*==============================================================*/
   /* Table: anomaly_summaries_final_score                         */
   /*==============================================================*/
   CREATE TABLE datagenie.anomaly_summaries_final_score(
      Id bigserial    not null,
      tracker_id varchar(500)  not null,
      dataset_id int NOT NULL,
      point_timestamp timestamp NOT NULL,
      historical_score decimal(15, 4) NULL,
      attribute_depth decimal(15, 4) NULL,
      attribute_importance numeric(18, 0) NULL,
      attribute_frequency int NOT NULL default 0,
      population decimal(15, 4) NULL default 0,
      cluster_id int NOT NULL,
      root_cause int NOT NULL,
      zscore numeric(15, 4) NULL,
      attribute_score_scaled decimal(15,4) NULL,
      aggregation varchar(50) NULL,
      historical_score_scaled decimal(15, 4) NULL,
      attribute_depth_scaled decimal(15, 4) NULL,
      attribute_importance_scaled decimal(15, 4) NULL,
      attribute_frequency_scaled decimal(15, 4) NULL,
      granularity varchar(10)   NOT NULL,
      final_score decimal(15, 4) NULL,
      CONSTRAINT CI_IdentityAS_FS PRIMARY KEY  (id, dataset_id) 
   ) 
   ;

   CREATE INDEX ind_anomaly_summaries_final_score_datasets ON datagenie.anomaly_summaries_final_score
   (point_timestamp ASC)
   ;

   CREATE  INDEX NCI_anomaly_summaries_final_score_dspcl ON datagenie.anomaly_summaries_final_score (dataset_id,tracker_id,point_timestamp)
   INCLUDE (historical_score,population,zscore,historical_score_scaled,attribute_depth_scaled,attribute_importance_scaled,attribute_frequency_scaled,final_score,granularity)
   ;

   /*==============================================================*/
   /* Table: anomaly_summaries_filtered                            */
   /*==============================================================*/
   CREATE TABLE datagenie.anomaly_summaries_filtered(
      Id bigserial    not null,
      tracker_id varchar(500)  not null,
      dataset_id int NOT NULL,
      point_timestamp timestamp NOT NULL,
      historical_score decimal(15, 4) NULL,
      attribute_depth decimal(15, 4) NULL,
      attribute_importance numeric(18, 0) NULL,
      attribute_frequency int NOT NULL default 0,
      population decimal(15, 4) NULL default 0,
      cluster_id int NOT NULL,
      root_cause int NOT NULL,
      zscore numeric(15, 4) NULL,
      historical_score_scaled decimal(15, 4) NULL,
      attribute_depth_scaled decimal(15, 4) NULL,
      attribute_importance_scaled decimal(15, 4) NULL,
      attribute_frequency_scaled decimal(15, 4) NULL,
      granularity varchar(10)   NOT NULL,
      final_score decimal(15, 4) NULL,
      CONSTRAINT CI_IdentityAS_F PRIMARY KEY  (id, dataset_id) 
   ) 
   ;

   CREATE  INDEX ind_anomaly_summaries_filtered_search ON datagenie.anomaly_summaries_filtered
   (
      granularity ASC,
      point_timestamp ASC
   )
   INCLUDE(id,dataset_id,tracker_id,population,zscore,final_score)

   ;


   /*==============================================================*/
   /* Table: anomaly_sensitivity_distribution                      */
   /*==============================================================*/
   create table datagenie.anomaly_sensitivity_distribution (   
      dataset_id           integer              not null,
      granularity          varchar(10)   not null,
      sensitivity_level    integer              not null,
      final_score          decimal(15,4)        not null,
      constraint pk_anomaly_sensitivity_distribution primary key  (dataset_id, granularity, sensitivity_level)
   )
   ;

   /*==============================================================*/
   /* Table: attribute_profiles                                    */
   /*==============================================================*/
   create table datagenie.attribute_profiles (
      id                   varchar(500)          not null,
      dataset_id           integer              null,
      attribute_code       varchar(150)          null,
      profiling_timestamp  timestamp             null,
      datatype             varchar(150)          not null,
      sample_values        text                   null,
      distinct_count       integer              not null,
      null_percentage      numeric              not null,
      is_categorical       boolean                  not null,
      native               boolean                  not null default 'true',   
      constraint pk_attribute_profiles primary key  (id)
   )
   ;

   /*==============================================================*/
   /* Table: attribute_profiles_temp                               */
   /*==============================================================*/
   create table datagenie.attribute_profiles_temp (
      id                   varchar(500)           not null,
      dataset_id           integer              null,
      attribute_code       varchar(150)           null,
      profiling_timestamp  timestamp             null,
      datatype             varchar(150)           not null,
      sample_values        text                    null,
      distinct_count       integer              not null,
      null_percentage      numeric              not null,
      is_categorical       boolean                  not null,
      native               boolean                  not null default 'true'   
   )
   ;

   /*==============================================================*/
   /* Table: attribute_values                                      */
   /*==============================================================*/
   create table datagenie.attribute_values (
      id                   varchar(500)         not null,
      dataset_id           integer              not null,
      attribute_code       varchar(500)         not null,
      "value"              text                 not null,
      user_score           int                  null,
      constraint pk_attribute_values primary key  (id)
   )
   ;

   /*==============================================================*/
   /* Index: ind_attribute_values_attributes                       */
   /*==============================================================*/
   create index ind_attribute_values_attributes on datagenie.attribute_values (
   dataset_id asc,
   attribute_code asc
   )
   ;

   /*==============================================================*/
   /* Table: attribute_values_temp                                 */
   /*==============================================================*/
   create table datagenie.attribute_values_temp (
      id                   varchar(500)           not null,
      dataset_id           integer              not null,
      attribute_code       varchar(500)           not null,
      "value"                text                    not null
   )
   ;


   /*==============================================================*/
   /* Table: attributes                                            */
   /*==============================================================*/
   create table datagenie.attributes (
      dataset_id           integer              not null,
      code                 varchar(500)           not null,
      name                 varchar(150)           not null,
      description          varchar(500)           null,
      enabled              boolean                  not null default 'true',
      is_categorical       boolean                  not null default 'true',
      sql_expression       text                   null,
      constraint pk_attributes primary key  (dataset_id, code)
   )
   ;

   /*==============================================================*/
   /* Table: attributes_temp                                       */
   /*==============================================================*/
   create table datagenie.attributes_temp (
      dataset_id           integer              not null,
      code                 varchar(500)         not null,
      name                 varchar(150)         not null,
      description          varchar(500)         null,
      enabled              boolean              not null default 'true',
      is_categorical       boolean              not null default 'true',
      sql_expression       text                 null
   )
   ;

   /*==============================================================*/
   /* Table: clients                                               */
   /*==============================================================*/
   create table datagenie.clients (
      code                 varchar(50)            not null,
      name                 varchar(150)           not null,
      constraint pk_clients primary key  (code)
   )
   ;

   /*==============================================================*/
   /* Table: custom_aggregations                                   */
   /*==============================================================*/
   create table datagenie.custom_aggregations (
      id                   serial              not null,
      dataset_id           integer              not null,
      name                 varchar(150)         not null,
      sql_expression       text                  null,
      enabled              boolean                  not null default 'true',
      summary_enabled      boolean                  not null default 'true',
      constraint pk_custom_aggregations primary key  (id)
   )
   ;

   /*==============================================================*/
   /* Table: datasets                                              */
   /*==============================================================*/
   create table datagenie.datasets (
      id                   serial                 not null,
      client_code          varchar(50)            not null,
      name                 varchar(150)           not null,
      source_id            integer              not null,
      time_anchor_column   varchar(100)             null,
      status               varchar(50)            null
         constraint ckc_status_datasets check (status is null or (status in ('PROFILING_PENDING','PROFILING_DONE','PROFILING_FAILED','BACKLOG_PROCESSING_TRIGGERED','BACKLOG_PROCESSING_FAILED','BACKLOG_PROCESSING_COMPLETED','REGULAR_PROCESSING_FAILED','REGULAR_PROCESSING_COMPLETED','READY'))),
      type                 varchar(50)            not null default 'LIVE'
         constraint ckc_type_datasets check (type in ('LIVE','STALE')),
      backlog_end_date    timestamp            null,
      constraint pk_datasets primary key  (id)
   )
   ;

   /*==============================================================*/
   /* Table: job_runs                                              */
   /*==============================================================*/
   create table datagenie.job_runs (
      id                   varchar(150)          not null,
      name                 varchar(150)          not null,
      start_timestamp      timestamp             not null,
      end_timestamp        timestamp             null,
      status               varchar(50)           not null,
      dataset_id           integer               null,
      page_url             varchar(2048)         null,
      constraint pk_job_runs primary key  (id)
   )
   ;

   /*==============================================================*/
   /* Table: reference_values_config                               */
   /*==============================================================*/
   create table datagenie.reference_values_config (
      granularity          varchar(10)            not null,
      code                 varchar(10)            not null,
      label                text                    not null,
      constraint pk_reference_values_config primary key  (granularity, code)
   )
   ;

   /*==============================================================*/
   /* Table: severity_configs                                      */
   /*==============================================================*/
   create table datagenie.severity_configs (
      granularity          varchar(10)                  not null,
      code                 varchar(500)                 not null,
      name                 text                         not null,
      z_score_threshold    decimal(15,4)        null,
      show_band            boolean                  not null default 'false',
      constraint pk_severity_configs primary key  (granularity, code)
   )
   ;

   /*==============================================================*/
   /* Table: sources                                               */
   /*==============================================================*/
   create table datagenie.sources (
      id                   integer              not null,
      name                 text                  not null,
      constraint pk_sources primary key  (id)
   )
   ;

   /*==============================================================*/
   /* Table: tracker_points                                        */
   /*==============================================================*/
   CREATE TABLE datagenie.tracker_points(
      Id bigserial    not null,
      tracker_id varchar(500)  NOT NULL,
      dataset_id int NOT NULL,
      point_timestamp timestamp NOT NULL,
      point_value decimal(15, 4) NULL,
      y_hat decimal(15, 4) NULL,
      sigma decimal(15, 4) NULL,
      b1 decimal(15, 4) NULL,
      b2 decimal(15, 4) NULL,
      b3 decimal(15, 4) NULL,
      b4 decimal(15, 4) NULL,
      a1 decimal(15, 4) NULL,
      a2 decimal(15, 4) NULL,
      a3 decimal(15, 4) NULL,
      a4 decimal(15, 4) NULL,
      population decimal(15, 8) NULL,
      severity varchar(50)  NULL,
      zscore decimal(15, 4) NULL,
      CONSTRAINT CI_IdentityTP PRIMARY KEY  (id, dataset_id) 
   )
   ;

   CREATE  INDEX ind_tracker_pointstracker_idpoint_timestamp ON datagenie.tracker_points
   (
      tracker_id ASC,
      point_timestamp ASC
   );

   /*==============================================================*/
   /* Table: trackers                                              */
   /*==============================================================*/
   create table datagenie.trackers (
      id                   varchar(500)           not null,
      dataset_id           integer                not null,
      metric_on            varchar(500)           null,
      aggregation          varchar(200)           not null,
      granularity          varchar(10)            not null,
      enabled              boolean                not null default 'true',
      constraint pk_trackers primary key  (id, dataset_id)
   )
   ;

   -- create  index ind_trackers_search on datagenie.trackers 
   -- (  
   --    dataset_id ASC, 
   --    granularity ASC, 
   --    aggregation ASC, 
   --    metric_on ASC  
   -- )  
   -- include ( enabled , id )
   -- ;

   /*==============================================================*/
   /* Table: trackers_temp                                         */
   /*==============================================================*/
   create table datagenie.trackers_temp (
      id                   varchar(500)           not null,
      dataset_id           integer                not null,
      metric_on            varchar(500)           null,
      aggregation          varchar(100)           not null,
      granularity          varchar(10)            not null,
      enabled              boolean                not null default 'true'
   )
   ;

   /*==============================================================*/
   /* Index: ind_trackers_attributes                               */
   /*==============================================================*/
   -- create index ind_trackers_attributes on datagenie.trackers (
   -- dataset_id asc,
   -- metric_on asc
   -- )
   -- ;

   /*==============================================================*/
   /* Table: trackers_attribute_values                             */
   /*==============================================================*/
   create table datagenie.trackers_attribute_values (
      tracker_id           varchar(500)           not null,
      dataset_id           integer              not null,
      attribute_value_id   varchar(500)           not null,
      user_score           int                  not null default 3,
      constraint pk_trackers_attribute_values primary key  (tracker_id, dataset_id, attribute_value_id)
   )
   ;

   create  index ind_attribute_values_value_ids on datagenie.trackers_attribute_values (  
         attribute_value_id asc  
         , dataset_id asc
   )  
   include ( tracker_id )
   ;

   /*==============================================================*/
   /* Table: trackers_attribute_values_temp                        */
   /*==============================================================*/
   create table datagenie.trackers_attribute_values_temp (
      tracker_id           varchar(500)           not null,
      dataset_id           integer              not null,
      attribute_value_id   varchar(500)           not null
   )
   ;

   /*==============================================================*/
   /* Table: user_feedback                                         */
   /*==============================================================*/
   create table datagenie.user_feedback (
      tracker_id           varchar(500)           null,
      dataset_id           integer              null,
      up_voted             boolean                  not null,
      option_order         integer              null,
      user_id              varchar(100)           not null,
      feedback_timestamp   timestamp             not null,
      feedback_text        text                    null
   )
   ;

   /*==============================================================*/
   /* Table: user_feedback_options                                 */
   /*==============================================================*/
   create table datagenie.user_feedback_options (
      up_voted             boolean                  not null,
      "order"              integer              not null,
      label                text                    not null,
      constraint pk_user_feedback_options primary key  (up_voted, "order")
   )
   ;

   insert into datagenie.user_feedback_options(up_voted,"order",label) values (false,1,'Score too high')
   ;
   insert into datagenie.user_feedback_options(up_voted,"order",label) values (false,2,'Score too low')
   ;
   insert into datagenie.user_feedback_options(up_voted,"order",label) values (false,3,'Insight not important')
   ;
   insert into datagenie.user_feedback_options(up_voted,"order",label) values (false,4,'Duplicate insight')
   ;
   insert into datagenie.user_feedback_options(up_voted,"order",label) values (false,5,'Comes up too often')
   ;
   insert into datagenie.user_feedback_options(up_voted,"order",label) values (true,1,'Useful insight')
   ;

   /*==============================================================*/
   /* Table: aggregations                                          */
   /*==============================================================*/
   create table datagenie.aggregations (
      code                 varchar(50)          null,
      name                 varchar(500)         null,
      summary_enabled      boolean              not null default true,
      constraint pk_aggregations primary key (code)
   )
   ;

   create table datagenie.score_weights (
      dataset_id           integer              not null,
      granularity          varchar(10)                  not null,
      score_code           varchar(50)          not null,
      weight               numeric              not null,   
      constraint pk_score_weights primary key (dataset_id, granularity, score_code)
   )
   ;

   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'daily','ZSCORE',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'daily','HISTORICAL_SCORE',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'daily','ATTRIBUTE_DEPTH', 1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'daily','ATTRIBUTE_IMPORTANCE',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'daily','ATTRIBUTE_FREQUENCY',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'daily','POPULATION',1)
   ;

   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'weekly','ZSCORE',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'weekly','HISTORICAL_SCORE',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'weekly','ATTRIBUTE_DEPTH', 1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'weekly','ATTRIBUTE_IMPORTANCE',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'weekly','ATTRIBUTE_FREQUENCY',1)
   ;
   insert into datagenie.score_weights(dataset_id, granularity, score_code, weight) values (-1, 'weekly','POPULATION',1)
   ;


   create table datagenie.system_config (
      "key"                varchar(500)         not null,
      "value"                varchar(500)         not null,
      constraint pk_system_config primary key ("key")
   )
   ;

   insert into datagenie.system_config("key", "value") values ('summarization_zscore_min','4')
   ;
   insert into datagenie.system_config("key", "value") values ('summarization_population_min','5')
   ;
   insert into datagenie.system_config("key", "value") values ('summarization_historical_score_max','5')
   ;

   alter table datagenie.attribute_values
      add constraint fk_attribute_values_attributes foreign key (dataset_id, attribute_code)
         references datagenie.attributes (dataset_id, code)
   ;

   alter table datagenie.attributes
      add constraint fk_attribut_fk_attrib_datasets foreign key (dataset_id)
         references datagenie.datasets (id)
   ;

   alter table datagenie.custom_aggregations
      add constraint fk_custom_aggregations_datasets foreign key (dataset_id)
         references datagenie.datasets (id)
   ;

   alter table datagenie.datasets
      add constraint fk_datasets_clients foreign key (client_code)
         references datagenie.clients (code)
   ;

   alter table datagenie.datasets
      add constraint fk_datasets_sources foreign key (source_id)
         references datagenie.sources (id)
   ;

   alter table datagenie.trackers
      add constraint fk_trackers_attributes foreign key (dataset_id, metric_on)
         references datagenie.attributes (dataset_id, code)
   ;

   alter table datagenie.trackers
      add constraint fk_trackers_datasets foreign key (dataset_id)
         references datagenie.datasets (id)
   ;

   alter table datagenie.trackers_attribute_values
      add constraint fk_ts_attribute_values_attr_values foreign key (attribute_value_id)
         references datagenie.attribute_values (id)
   ;

   alter table datagenie.trackers_attribute_values
      add constraint fk_ts_attribute_values_trackers foreign key (tracker_id, dataset_id)
         references datagenie.trackers (id, dataset_id)
   ;

   alter table datagenie.user_feedback
      add constraint fk_user_feedback_options foreign key (up_voted, option_order)
         references datagenie.user_feedback_options (up_voted, "order")
   ;

   alter table datagenie.user_feedback
      add constraint fk_user_feedback_trackers foreign key (tracker_id, dataset_id)
         references datagenie.trackers (id, dataset_id)
   ;

