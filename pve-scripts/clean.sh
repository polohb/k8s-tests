#!/bin/bash


fn_clean () {
    
    status=$(qm status "$1")

    if [ "$status" == "status: running" ]; then
        echo "Stopping $1"
        qm stop "$1"
        echo "wait ..."
        sleep 15
    fi

    echo "Destroying $1"
    qm destroy "$1"
}

fn_clean 201
fn_clean 202
fn_clean 203

fn_clean 3000