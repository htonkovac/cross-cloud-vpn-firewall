#!/bin/bash
wget https://raw.githubusercontent.com/leighmcculloch/looks.wtf/master/looks.yml -O looks.yml
LEN=$(cat looks.yml | yq e '. | length')
NUMBER=$(($RANDOM % $LEN ))
COMMIT_MESSAGE=$(cat looks.yml | yq e ".[$NUMBER].plain")
echo "Chosen commit message: $COMMIT_MESSAGE"
git add .
git commit -m "$COMMIT_MESSAGE"
git push