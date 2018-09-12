#!/bin/bash

# This needs to be called ones to create all the directories and symlinks
# to run the TopicExplorer Java binaries for different projects

# parameter $1 is the path to the directory with a distribution of the
# java binaries as build with maven from the topicexplorer project

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters: path to compiled topicexplorer distribution is needed"
    exit 1
fi
TE_DISTRIBUTION=$1

if [ ! -d "$TE_DISTRIBUTION" ]; then
    echo "$TE_DISTRIBUTION does not exists."
    exit 1
fi
if [ ! -d $TE_DISTRIBUTION/bin ]; then
    echo "$TE_DISTRIBUTION/bin does not exists."
    exit 1
fi
if [ ! -d $TE_DISTRIBUTION/lib ]; then
    echo "$TE_DISTRIBUTION/lib does not exists."
    exit 1
fi
if [ ! -d $TE_DISTRIBUTION/scripts ]; then
    echo "$TE_DISTRIBUTION/scripts does not exists."
    exit 1
fi

#check for te base directory
if [ ! -v TE_BASE_DIR ]; then
    echo "environment variable TE_BASE_DIR for the te base directory is not set: example TE_BASE_DIR=/te_production"
    exit 1
fi

#check for te base directory
if [ ! -v TE_VERSION ]; then
    echo "environment variable TE_VERSION for the version of TopicExplorer is not set: example TE_VERSION=te-1.4-SNAPSHOT"
    exit 1
fi

# Create directories and sym links for the binaries of te distribution and a template project
mkdir -p "$TE_BASE_DIR"/{config,distribution/{standard,"$TE_VERSION"/{bin,lib,scripts}},project,helper/template/{resources,logs,etc,data,webapp/{nlp,te}}}
ln -s ../"$TE_VERSION"/bin ../"$TE_VERSION"/lib ../"$TE_VERSION"/scripts "$TE_BASE_DIR"/distribution/standard
ln -s ../../distribution/standard/bin ../../distribution/standard/lib ../../distribution/standard/scripts "$TE_BASE_DIR/helper/template"

# Copy the binary distribution into the right places
cp "$TE_DISTRIBUTION"/bin/* "$TE_BASE_DIR/distribution/$TE_VERSION/bin/".
cp "$TE_DISTRIBUTION"/lib/* "$TE_BASE_DIR/distribution/$TE_VERSION/lib/".
cp "$TE_DISTRIBUTION"/scripts/* "$TE_BASE_DIR/distribution/$TE_VERSION/scripts/".


# Copy template tar files for the webapps into the right places
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -e "$SOURCE"/webapp_prototype_te.tar ]; then
    echo "$SOURCE/webapp_prototype_te.tar does not exists."
    exit 1
fi
cp "$SOURCE"/webapp_prototype_te.tar "$TE_BASE_DIR"/helper/template/webapp/te/.

if [ ! -e "$SOURCE"/webapp_prototype_nlp.tar ]; then
    echo "$SOURCE/webapp_prototype_nlp.tar does not exists."
    exit 1
fi
cp "$SOURCE"/webapp_prototype_nlp.tar "$TE_BASE_DIR"/helper/template/webapp/nlp/.

# Create the general project directory to run the te-computations
cp -R "$TE_BASE_DIR"/helper/template "$TE_BASE_DIR"/helper/tmp
