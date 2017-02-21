#!/usr/bin/env bash

aws s3 sync . s3://beta.cncfdemo.io --region us-west-2 --delete --exclude "search*" --exclude ".*" --exclude "*.sh" && \
aws s3 sync . s3://beta.cncfdemo.io --region us-west-2 --delete --exclude "*" --include "search" --no-guess-mime-type --content-type text/html
