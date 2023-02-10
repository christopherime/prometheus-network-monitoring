# prometheus-network-monitoring

This is a simple network monitoring setup using Prometheus and Grafana.

## TODO

- [ ] create `run.sh` for Linux and Mac

## Pre-requisites

- Windows Host (so far)
- Target to monitor compatible with SNMP
  - Default SNMP configuration:
    - community: public
    - version: 2c
    - If you want another configuration, please check the project [snmp_exporter](https://github.com/prometheus/snmp_exporter), use the generator and change the `snmp.yml` file in `config/snmp-exporter/`
- [Docker desktop](https://www.docker.com/) installed on your machine with Docker compose (comes with Docker desktop as default installation)
- Host machine with access to the internet or before running the containers download the following images:
  - Do:
    - `docker compose pull` to download all the images needed
  - Or:
    - `docker pull prom/prometheus`
    - `docker pull prom/snmp-exporter`
    - `docker pull grafana/grafana`

## How to run

- Run the power shell script `run.ps1` (Windows), follow the prompt
- Access Grafana interface on `http://localhost:3000`
  - Default credentials:
    - user: admin
    - password: admin
