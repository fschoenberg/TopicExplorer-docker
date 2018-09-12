# TopicExplorer-docker

## Description
[TopicExplorer](http://topicexplorer.informatik.uni-halle.de) integrates all services neccessary for topic-modeling into a single web-application. TopicExplorer-Docker provides containers to ease the installation of TopicExplorer on a local computer based on docker-compose.

## Installation
#### Step 1: prerequisites
Install [docker](https://docs.docker.com/install/) at least version 18.0 and [docker-compose](https://docs.docker.com/compose/install/) at least version 3.4 at your local machine.
Both software packages are available for Windows, Mac and Linux.
#### Step 2: download and set password
Download or clone this repository to your local computer. Navigate to the folder `TopicExplorer-docker`. Rename the file `te_mysql_password.change-me` to `te_mysql_password` and change the password inside it.
#### Step 3: build containers
Build the containers for the services of the web-application by running in the folder `TopicExplorer-docker`
```
docker-compose build
```
This takes some time depending on the speed of your internet connection and your computer.

## Use TopicExplorer
### Start the web-application
The services of the web-application, e.g. local web-server and database, are started by running
```
docker-compose up
```
For the first time, the volume directories are initialized, e.g. database `TE_MANAGEMENT` is created. This takes some time, but this steps are skiped at subsequent restarts.
### Use the TopicExplorer-Workflow
When docker-compose is running, open the Html-file `start-topicexplorer-workflow.html` in your browser.

#### Create a Corpus for Topic-Modelling
The initial step is not automized yet, but very flexible to fit many scenarios.
Start to create a corpus of documents in the `TE_MANAGEMENT` database by following the [link to adminer](http://localhost:8002/?server=topicexplorer-db&username=root&db=TE_MANAGEMENT&sql=) in the Html-file. Login into the database as root with the password you selected earlier. Choose the SQL-Command link in adminer and create two tables by copy-paste the sql-code below into adminer and replace `<CORPUS-NAME>` with the corpus name in upper case.
```
CREATE TABLE CORPUS_<CORPUS-NAME> (
    DOCUMENT_ID    INTEGER(11) NOT NULL,
    TITLE          VARCHAR(255) CHARACTER SET utf8mb4 NOT NULL,
    URL            VARCHAR(255) CHARACTER SET utf8mb4 NOT NULL,
    DOCUMENT_DATE  DATETIME NOT NULL,
    CONSTRAINT DOCUMENT_ID_PK PRIMARY KEY ( DOCUMENT_ID )
    )
    ENGINE = ARIA DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin,
    TRANSACTIONAL = 1,
    COMMENT = 'meta data of corpus'
;

CREATE TABLE CORPUS_<CORPUS-NAME>_TEXT (
    DOCUMENT_ID    INTEGER(11) NOT NULL,
    DOCUMENT_TEXT  MEDIUMTEXT CHARACTER SET utf8mb4 NOT NULL,
    CONSTRAINT DOCUMENT_ID_PK PRIMARY KEY ( DOCUMENT_ID )
    )
    ENGINE = ARIA DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin,
    TRANSACTIONAL = 1,
    COMMENT = 'text data of corpus'
;
```
Import the corpus content from csv files that match the columns into the tables.
Click select next to table name and then chose the import link at the bottom.
Further, insert a row into each of the tables `SEARCH_STRING` and `CRAWL` that decribe the corpus by copy-paste the sql code below.
Replace `<UNIQUE INTERGER>` with some id number not yet in the table `SEARCH_STRING`.
Take care that this number is the same in the first and the second line.
When you collected the corpus by issuing a search query into some search engine,
replace `<UNIQUE SEARCH STRING>` with this query, otherwise replace it with some other unique string.
Last `<CORPUS-NAME>` with the same string chosen as part of the table names.
Also take care that the strings are the same in both lines.
```
insert into SEARCH_STRING VALUES(<UNIQUE INTERGER>,'<UNIQUE SEARCH STRING>','<CORPUS-NAME>');
insert into CRAWL values(<UNIQUE INTERGER>,now(),'CORPUS_<CORPUS-NAME>',0,now(),'root');
```
An example for a corpus about	bicycling for holiday in Germany could be
```
insert into SEARCH_STRING VALUES(1,'bicycle AND germany AND holiday','BICYCLE');
insert into CRAWL values(1,now(),'CORPUS_BICYCLE',0,now(),'root');
```
Alternatively, a corpus can be imported as mysqldump-file with adminer.
#### Prepare the corpus and create a topic model
These steps are supported by the web-application of TopicExplorer.
Open the creator-link that leads to an overview page.
It shows the list of available corpora.
Pick a corpus and enter an identifier string, e.g. `1` for a new topic model, then click the Create-button.
A number of natural langage processing (NLP) methods are run, the results
are written back into the database and a small web-application to configure
the topic model is deployed.

Open the NLP web-application and follow the instructions to select the vocabulary and choose the number of topics.
When the configuration of the topic model is submitted, go back to the  overview page of the creator and wait and update until the topic model is readily computed.
When the topic model is ready, a TopicExplorer (TE) link appears.
This link opens the TopicExplorer web-application, which can be used to explore topics derived from the corpus.

From the overview page of the creator, other configurations can be used to compute additional topic models for the same corpus.
This may help to find other topics or to verfify the robustness of derived topics.
