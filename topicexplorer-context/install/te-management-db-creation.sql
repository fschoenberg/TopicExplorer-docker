CREATE DATABASE <TE_MANAGEMENT_DB_NAME> DEFAULT CHARACTER SET utf8mb4;

USE <TE_MANAGEMENT_DB_NAME>;

CREATE TABLE SEARCH_STRING
    (
     SEARCH_STRING_ID       INTEGER UNSIGNED NOT NULL,
     SEARCH_STRING          VARCHAR(100) CHARACTER SET utf8mb4 NOT NULL,
     DESCRIPTIVE_IDENTIFIER VARCHAR(50)  CHARACTER SET utf8 NOT NULL,
     CONSTRAINT SEARCH_STRING_PK PRIMARY KEY ( SEARCH_STRING_ID ),
     CONSTRAINT DESCRIPTIVE_IDENTIFIER_UNIQUE UNIQUE( SEARCH_STRING_ID )
    )
    ENGINE = ARIA,
    TRANSACTIONAL = 1,
    COMMENT = 'Describes a corpus'
;

CREATE TABLE CRAWL
    (
     SEARCH_STRING_ID       INTEGER UNSIGNED NOT NULL,
     CRAWL_DATE             DATETIME NOT NULL,
     TABLE_NAME             VARCHAR(50)  CHARACTER SET utf8 NOT NULL,
     ACTIVE                 INTEGER UNSIGNED NOT NULL,
     LAST_MODIFIED_DATE     DATETIME NOT NULL ,
     LAST_MODIFIED_USER     VARCHAR(50)  CHARACTER SET utf8 NOT NULL,
     CONSTRAINT CRAWL_PK PRIMARY KEY ( SEARCH_STRING_ID, CRAWL_DATE ),
     CONSTRAINT CRAWL_ALTERNATIVE_KEY UNIQUE ( TABLE_NAME ),
     CONSTRAINT CRAWL_FK1 FOREIGN KEY ( SEARCH_STRING_ID ) REFERENCES SEARCH_STRING( SEARCH_STRING_ID )
    )
    ENGINE = ARIA,
    TRANSACTIONAL = 1,
    COMMENT = 'Describes all parts of a corpus'
;

CREATE TABLE TOPIC_EXPLORER_DEFINITION
    (
     TE_IDENTIFIER VARCHAR(50)  CHARACTER SET utf8 NOT NULL,
     SEARCH_STRING_ID           INTEGER UNSIGNED NOT NULL,
     FILTER_START_DATETIME      DATETIME NOT NULL, -- default min date of corpus
     FILTER_END_DATETIME        DATETIME NOT NULL, -- default max date of corpus
     FILTER_TEXT_QUERY          MEDIUMTEXT CHARACTER SET utf8mb4,-- max 64kb, logic expression by the user
     FILTER_TEXT_SQL            MEDIUMTEXT CHARACTER SET utf8mb4,-- max 64kb, equiv. SQL where condition
     INITIALIZE_PENDING         DATETIME NOT NULL,
     INITIALIZE_RUNNING         DATETIME,
     INITIALIZE_FINISHED        DATETIME,
     TE_COMPUTATION_PENDING     DATETIME,
     TE_COMPUTATION_RUNNING     DATETIME,
     TE_COMPUTATION_FINISHED    DATETIME,
     TOPIC_EXPLORER_ID          INTEGER UNSIGNED,
     CONSTRAINT TOPIC_EXPLORER_DEFINITION_PK PRIMARY KEY ( TE_IDENTIFIER ),
     CONSTRAINT TE_COMPUTATION_JOB_FK1 FOREIGN KEY ( TOPIC_EXPLORER_ID ) REFERENCES TOPIC_EXPLORER( TOPIC_EXPLORER_ID ),
     -- time stamps can be inserted in specific ordering
     -- this will be enforced in MariaDB >=10.2.1
     -- in older versions of MariaDB the constraint is ignored
     constraint OrderingOfTimes    check
       (
         (   INITIALIZE_RUNNING      is null 
         and INITIALIZE_FINISHED     is null 
         and TE_COMPUTATION_PENDING  is null
         and TE_COMPUTATION_RUNNING  is null
         and TE_COMPUTATION_FINISHED is null
         ) or
         (   INITIALIZE_RUNNING      is not null 
         and INITIALIZE_FINISHED     is null 
         and TE_COMPUTATION_PENDING  is null
         and TE_COMPUTATION_RUNNING  is null
         and TE_COMPUTATION_FINISHED is null
         ) or
         (   INITIALIZE_RUNNING      is not null 
         and INITIALIZE_FINISHED     is not null 
         and TE_COMPUTATION_PENDING  is null
         and TE_COMPUTATION_RUNNING  is null
         and TE_COMPUTATION_FINISHED is null
         ) or
         (   INITIALIZE_RUNNING      is not null 
         and INITIALIZE_FINISHED     is not null 
         and TE_COMPUTATION_PENDING  is not null
         and TE_COMPUTATION_RUNNING  is null
         and TE_COMPUTATION_FINISHED is null
         ) or
         (   INITIALIZE_RUNNING      is not null 
         and INITIALIZE_FINISHED     is not null 
         and TE_COMPUTATION_PENDING  is not null
         and TE_COMPUTATION_RUNNING  is not null
         and TE_COMPUTATION_FINISHED is null
         ) or
         (   INITIALIZE_RUNNING      is not null 
         and INITIALIZE_FINISHED     is not null 
         and TE_COMPUTATION_PENDING  is not null
         and TE_COMPUTATION_RUNNING  is not null
         and TE_COMPUTATION_FINISHED is not null
         )
       )
    )
    ENGINE = ARIA,
    TRANSACTIONAL = 1,
    COMMENT = 'Describes a TE for a Corpus'
;

CREATE TABLE TOPIC_EXPLORER
    (
     TOPIC_EXPLORER_ID      INTEGER UNSIGNED NOT NULL auto_increment,
     TE_IDENTIFIER VARCHAR(50)  CHARACTER SET utf8 DEFAULT NULL,
     ZIPPED_CONFIGS         LONGBLOB NOT NULL,
     PENDING                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
     RUNNING                DATETIME,
     FINISHED               DATETIME,
     CONSTRAINT TOPIC_EXPLORER_PK PRIMARY KEY ( TOPIC_EXPLORER_ID ),
     CONSTRAINT TE_DEFINITION_FK FOREIGN KEY ( TE_IDENTIFIER ) REFERENCES TOPIC_EXPLORER_DEFINITION( TE_IDENTIFIER )
    )
    ENGINE = ARIA,
    TRANSACTIONAL = 1,
    COMMENT = 'Stores the job for TE computations send by webapp-preprocessing nlp'
;
