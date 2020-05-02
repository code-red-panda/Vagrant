#!/bin/bash

USER=ansible
SSH_DIR=/home/$USER/.ssh
PUB_KEY=/vagrant/${USER}_rsa.pub
PRIV_KEY=/vagrant/${USER}_rsa

if test ! $(id -u $USER)
  then
    useradd $USER
    mkdir -p $SSH_DIR
    cp $PUB_KEY $SSH_DIR/authorized_keys
    cp $PRIV_KEY $SSH_DIR/id_rsa
    chown $USER.$USER -R $SSH_DIR
    chmod 700 $SSH_DIR
    chmod 600 $SSH_DIR/*
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
fi
