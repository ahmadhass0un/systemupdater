#!/bin/bash

sudo apt update
UPDATE=$?

if [[ $UPDATE -eq 0 ]]; then
    echo " "
    echo "The package list has been updated."
    echo ""
else
    echo ""
    echo "Update failed. The package list was not updated."
    echo ""
fi

sudo apt upgrade -y
UPGRADE=$?

if [[ $UPGRADE -eq 0 ]]; then
    echo ""
    echo "The system has been updated."
    echo ""
else
    echo ""
    echo "Update failed. The system was not updated."
    echo ""
fi

sudo apt autoclean
CLEAN=$?

if [[ $CLEAN -eq 0 ]]; then
    echo ""
    echo "The system has been cleaned."
    echo ""
else
    echo ""
    echo "Cleaning failed. The system was not cleaned."
    echo ""
fi

sudo apt autoremove -y
REMOVE=$?

if [[ $REMOVE -eq 0 ]]; then
    echo ""
    echo "The unnecessary packages have been removed."
    echo ""
else
    echo ""
    echo "The unnecessary packages have not been removed."
    echo ""
fi
