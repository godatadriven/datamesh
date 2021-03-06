# Data Mesh

Material for the Data Mesh presentation at GoDataFest 2021 and the Codebreakfast handson session in March 2022

## Presentation

[Presentation for the workshop](./presentation/delta-sharing-workshop.pdf)

## Setup

Instruqt is used to publish this material as a track with different challenges. 
The docker containers and notebooks can also be run locally with docker-compose

### Run local

#### SSL certificates

Both Azure Blob storage and GCS need a SSL connection enabled. Several certificates, keys and java truststores are needed for the diversity of libraries and programming languages used. 

See SSL_README.md how to (re)generate those certificates

#### Start demo environment

```bash
docker-compose up --build
```

Go to [Jupyter Lab](http://localhost:18888) to see the notebooks.

#### Data preparation

The prepared datasets are described in [data/DATA_PREP.md](./data/DATA_PREP.md)

### Run on instruqt

#### Build instruqt virtual machine

```bash
cd packer-compose-vm
make PROJECT=instruqt-godatadriven IMAGE_NAME=instruqt-datamesh-multicloud-vm force-build
```

#### Publish the track

```bash
instruqt track validate && instruqt track push
```