#!/bin/bash

PROJECT=$1
USER=ansible

ssh-keygen -t rsa -C "$USER" -f "./$PROJECT/${USER}_rsa" -P ""
