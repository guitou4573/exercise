#!/bin/bash

echo "Installing NodeExporter"
mkdir /home/ubuntu/node_exporter
cd /home/ubuntu/node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xzf node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
./node_exporter &