# TopicExplorer-docker

## Description
[TopicExplorer](http://topicexplorer.informatik.uni-halle.de) integrates all services neccessary for topic-modeling into a single web-application.
TopicExplorer-Docker provides containers for simplified installation of TopicExplorer on a local computer based on docker-compose.

## Installation

#### Step 1: prerequisites
Install [docker](https://docs.docker.com/install/) at least version 18.0 and [docker-compose](https://docs.docker.com/compose/install/) at least version 3.4 at your local machine.
Both software packages are available for Windows, Mac and Linux.
Many tutorials explain installing docker step by step.

Important note for Windows 10: after install, open docker-settings from the task bar and enable sharing for the drive that contains the TopicExplorer-docker project.
#### Step 2: download and set password
Download or clone this repository [green button on github] to your local computer. Navigate to the folder `TopicExplorer-docker`. Rename the file `te_mysql_password.change-me` to `te_mysql_password` and change the password inside it.
#### Step 3: start the web-application
Start the services of the web-application,
e.g. local web-server and database,
by clicking the `start-topicexplorer-windows10.bat` on Windows 10 Professional or `start-topicexplorer-linux.sh` on Linux.
Allow docker to access  locally created networks through personal firewalls on your machine.
TopicExplorer can be also manually started from the project folder in a shell with the command:
```
docker-compose up --no-build
```
For the first time,
docker pulls the container images,
which takes a while depending on the speed of your Internet connection and your computer.
Then the volume directories are initialized and databases are created.
This steps are skipped on subsequent restarts.

#### Step 4: stop the web-application
After you finished working with TopicExplorer,
stop the services of the web-application by clicking the `stop-topicexplorer-windows10.bat` on Windows 10 Professional or `stop-topicexplorer-linux.sh` on Linux.
Stopping manually is done from project folder in a shell with the command:
```
docker-compose down
```

## Use TopicExplorer
When docker-compose is running, open the HTML-file `start-topicexplorer-workflow.html` in your browser.
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
