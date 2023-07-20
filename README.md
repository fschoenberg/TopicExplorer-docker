# TopicExplorer-docker multiuser build

## Description
[TopicExplorer](http://topicexplorer.informatik.uni-halle.de) integrates all services neccessary for topic-modeling into a single web-application.
TopicExplorer-Docker provides containers for simplified installation of TopicExplorer on a local computer based on docker-compose.
This version supports multiple user to work on a single database instance. So far it is developed for usage on Linux based servers.

## Installation

#### Step 1: prerequisites
Install [docker](https://docs.docker.com/install/) at least version 23.0 and [docker-compose](https://docs.docker.com/compose/install/) at least version v2.16.0 at your local machine.

#### Step 2: download and set configuration
Download or clone this repository [green button on github] to your local computer. Navigate to the folder `TopicExplorer-docker\multiuser_config`. Rename the file `config.ini.change-me` to `config.ini` and configure your system to your needs.


#### Step 3: start the web-application
Run the file `TopicExplorer-docker\multiuser_config\config.sh` as root. You only have to do this once after changing parameters in your 'config.ini'.
The TopicExplorer will restart after each reboot automatically. Changig a password is not supportet at the moment.

## Use TopicExplorer
Go to the URL `http(s)://%YOUR_SERVER_NAME%/%USERNAME%/`
You will find there a description of the workflow.
Additionally you will find a phpMyAdmin instance on Port 8003. 
The import of data, the NLP preprocessing and the generation of topic models is described for different languages [en, de, jp] and NLP tools [treetagger, mecab].

#### Prepare the corpus and create a topic model
The workflow page links to different TopicExplorer creator interfaces.
A creator shows the list of available corpora.
Pick a corpus and enter an identifier string, e.g. `1` for a new topic model, then click the Create-button.
A number of natural language processing (NLP) methods are run,
the results are written back into the database and
a small web-application to configure the topic model is deployed.

Open the NLP web-application and follow the instructions to select the vocabulary and choose the number of topics.
When the configuration of the topic model is submitted, the computation of the topic model is started.
When the topic model is ready, a TopicExplorer (TE) link appears in the creator.
This link opens the TopicExplorer web-application, which can be used to explore topics derived from the corpus.

The creator allows to configure and compute additional topic models for the same corpus.
This may help to find other topics or to verify the robustness of derived topics.
