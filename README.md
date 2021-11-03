# Data Mesh

Material for the Data Mesh presentation at GoDataFest 2021

## Presentation

[Keynote presentation for he workshop](./presentation/delta-sharing-workshop.pdf)

## Setup

Instruqt is used to publish this material as a track with different challenges. 
The docker containers and notebooks can also be run locally with docker-compose

### Run local

```bash
docker-compose up --build
```

Go to [Jupyter Lab](http://localhost:10000) to see the notebooks.

#### Data preparation

The prepared datasets are described in [data/DATA_PREP.md](./data/DATA_PREP.md)

### Run on instruqt

#### Build instruqt virtual machine

```bash
cd packer-compose-vm
make PROJECT=instruqt-godatadriven IMAGE_NAME=instruqt-datamesh-vm force-build
```

#### Publish the track

```bash
instruqt track validate && instruqt track publish
```