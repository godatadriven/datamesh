# SSL setup

Al the below commands are gathered into the `generate-ssl-cets.sh` script and explained here

## Azure Blob storage

##### Create certificate and key

We need a certificate for the azurite docker container that is also valid for the alternative DNS names of the storage account `devstoreaccount1`

```bash
openssl req -newkey rsa:2048 -x509 -nodes -keyout az_private_key.pem -new -out az_server.pem -sha256 -days 365 -addext "subjectAltName=IP:127.0.0.1,DNS.1:devstoreaccount1,DNS.2:devstoreaccount1.azserver,DNS.3:devstoreaccount1.blob.azserver,DNS.4:devstoreaccount1.dfs.azserver" -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Datamesh workshop Ltd/OU=OU/CN=azserver"
```

##### Check private key
```bash
openssl rsa -in az_private_key.pem -check
```

##### Check cert

```bash
openssl x509 -in az_server.pem -text -noout
```

##### Add to Java keystore
```bash
keytool -importcert -alias azure_storage_cert -file az_server.pem -keystore datamesh_truststore -storetype PKCS12 -storepass changeit
```

copy this file (`datamesh_truststore`) to the docker build directory of the almond-with-storage-certs container
