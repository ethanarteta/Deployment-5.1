#!/bin/bash

# Update package list and install required packages
sudo apt update
sudo apt install -y default-jre software-properties-common

# Add the deadsnakes PPA for Python 3.7
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# Install Python 3.7 and Python 3.7 virtual environment
sudo apt install -y python3.7 python3.7-venv

# Print the installed Python version
python3.7 --version

