# Data Mesh docker compose based environment

## Docker compose

The environment consists of 6 docker containers. 
In this document the complete setup and configuration is described per container.

### s3server

The s3server is a container based on the [localstack](https://localstack.cloud/) cloud stack.
In our setup we only start the S3 service.

#### Environment

The environment is configured from the .s3.env file.  The S3 service is configured to be exposed on port 4563.  
The AWS Access Key and secret are also set.  

#### Volumes

There are 3 volume mounts for the s3 server:

| Directory | Mountpoint | Description |
| :-------- | :--------- | :---------- |
| ./aws.setup.d | /docker-entrypoint-initaws.d | Initialization scripts. Creating buckets and adding demo datasets on startup | 
| ./data | /initdata | Demo datasets |
| ./.s3-mount | /tmp/localstack | Internal localstack directory |

### Azure

#### SSL setup

##### Create certificate and key
```bash
openssl req -newkey rsa:2048 -x509 -nodes -keyout private_key.pem -new -out server.pem -sha256 -days 365 -addext "subjectAltName=IP:127.0.0.1,DNS.1:devstoreaccount1,DNS.2:devstoreaccount1.azserver,DNS.3:devstoreaccount1.blob.azserver,DNS.4:devstoreaccount1.dfs.azserver" -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Datamesh workshop Ltd/OU=OU/CN=azserver"
```

##### Check private key
```bash
openssl rsa -in private_key.pem -check
```

##### Check cert

```bash
openssl x509 -in server.pem -text -noout
```

##### Add to Java keystore
```bash
keytool -importcert -alias azure_storage_cert -file server.pem -keystore azure_truststore
password: `changeit`
```

copy this file (`azure_truststore`) to the docker build directory of the almond-with-azurite-certs container

#### Environment

No special environment settings are used.

#### Volumes

| Directory | Mountpoint | Description |
| :-------- | :--------- | :---------- |
|  ./.az-mount/workspace | /workspace | Data storage |
|  ./config | /ssl | SSL certs |

The server.pem and private_key.pem config are mounted here.  

### delta

The delta container is the reference implementation server for the Delt sharing protocol.

#### Environment

The environment is configured from the .delta.env file.  
Only some logging configuration for the hadoop libraries is done here.

#### Volumes

| Directory | Mountpoint | Description |
| :-------- | :--------- | :---------- |
|  ./config/delta/ | /opt/docker/conf/ | Config files |
|  ./config/ssl/ | /opt/docker/ssl | SSL certificate | 

The delta-sharing.yml config is mounted here.  
This is the static configuration of shares, schemas and tables.

The core-site.xml is a Hadoop core configuration file.  
With this configuration the delta sharing server knows how to connect to the S3 server.

The server.pem SSL certificate is used to connect to secure Azure storage

### sparkprepare

The sparkprepare container is a spark container with the AWS SDK and hadoop libraries pre-installed.

#### Environment

The environment is configured from the .s3.env file. The AWS Access Key and secret are also set.  
This way the sparkprepare container can directly connect to the datasets on S3.  
The container is only used to prepare the demo datasets in the delta lake format.

### sparkshell

The sparkshell container is a spark container with the AWS SDK and hadoop libraries pre-installed.

#### Environment

No extra environment settings.  
This container cannot connect to the data in S3 directly.

#### Volumes

| Directory | Mountpoint | Description |
| :-------- | :--------- | :---------- |
| ./config/sharing/ | /opt/delta/conf/ | Mounting the delta.profile file | 
| ./config/ssl | /opt/spark/ssl | SSl certificate |

With the delta.profile file spark understands how to connect to the delta sharing server.

The ssl certificate is needed to connect to Azure blob storage. The certificate is stored in the azure_trustore so the spark connector can read the files stored there.

### python

The python container is a container based on the Python base image with the delta-sharing package pre-installed.

#### Environment

No extra environment settings.  
This container cannot connect to the data in S3 directly.

#### Volumes

| Directory | Mountpoint | Description |
| :-------- | :--------- | :---------- |
| ./config/sharing/ | /opt/delta/conf/ | Mounting the delta.profile file | 
| ./config/ssl | /opt/spark/ssl | SSl certificate |

With the delta.profile file python understands how to connect to the delta sharing server.

The ssl certificate is needed to connect to Azure blob storage.

### jupyter

The jupyter container is a Jupyter notebook container with the [Almond](https://almond.sh/) scala kernel installed.

#### Environment

No special environment settings are done.

#### Volumes

| Directory | Mountpoint | Description |
| :-------- | :--------- | :---------- |
| ./notebooks/ | /home/jovyan/work/notebooks/ | Mounting the notebooks |
| ./config/sharing/ | /opt/delta/conf/ | Mounting the delta.profile file |
| ./config/spark/ | /opt/spark/conf/ | Mounting the spark default configs |
| ./config/ssl | /opt/spark/ssl | SSl certificate |
