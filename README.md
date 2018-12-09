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
When docker-compose is running, open the Html-file `start-topicexplorer-workflow.html` in your browser. The import of data, the NLP preprocessing and the generation of topic models is described for different languages and NLP tools.

#### Prepare the corpus and create a topic model
The workflow page links to different TopicExplorer creator interfaces.
A creator shows the list of available corpora.
Pick a corpus and enter an identifier string, e.g. `1` for a new topic model, then click the Create-button.
A number of natural language processing (NLP) methods are run, the results
are written back into the database and a small web-application to configure
the topic model is deployed.

Open the NLP web-application and follow the instructions to select the vocabulary and choose the number of topics.
When the configuration of the topic model is submitted, the computation of the topic model is started.
When the topic model is ready, a TopicExplorer (TE) link appears in the creator.
This link opens the TopicExplorer web-application, which can be used to explore topics derived from the corpus.

The creator allows to configure and compute additional topic models for the same corpus.
This may help to find other topics or to verify the robustness of derived topics.
