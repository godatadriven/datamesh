#!/usr/bin/env bash

set -euo pipefail

OPENSSL=${1:-/usr/local/opt/openssl/bin/openssl}
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SSL_DIR=${SCRIPT_DIR}/config/ssl
DOCKER_BASE_DIR=${SCRIPT_DIR}/docker
GOOGLE_CERT_PATH=com/google/api/client/googleapis/

echo "Generating new SSL certificates"

echo "Generating new certificate and key for Azure blob storage"
${OPENSSL} req -newkey rsa:2048 -x509 -nodes -keyout ${SSL_DIR}/az_private_key.pem -new -out ${SSL_DIR}/az_server.pem -sha256 -days 365 -addext "subjectAltName=IP:127.0.0.1,DNS.1:devstoreaccount1,DNS.2:devstoreaccount1.azserver,DNS.3:devstoreaccount1.blob.azserver,DNS.4:devstoreaccount1.dfs.azserver" -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Datamesh workshop Ltd/OU=OU/CN=azserver"

echo "Creating java truststore with Azure cert"
rm -f ${SSL_DIR}/datamesh_truststore
keytool -importcert -alias azure_storage_cert -file ${SSL_DIR}/az_server.pem -keystore ${SSL_DIR}/datamesh_truststore -storetype PKCS12 -storepass changeit -noprompt

echo "Generating new certificate and key for GCS storage"
${OPENSSL} req -newkey rsa:2048 -x509 -nodes -keyout ${SSL_DIR}/gcs_private_key.pem -new -out ${SSL_DIR}/gcs_server.pem -sha256 -days 365 -addext "subjectAltName=IP:127.0.0.1,DNS.1:gcsserver,DNS.2:storage.googleapis.com" -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Datamesh workshop Ltd/OU=OU/CN=gcsserver"

echo "Combine the 2 server certificates into a single pem file"
cat ${SSL_DIR}/az_server.pem ${SSL_DIR}/gcs_server.pem > ${SSL_DIR}/server.pem

echo "Add GCS certificate to the java truststore"
keytool -importcert -alias gcs_storage_cert -file ${SSL_DIR}/gcs_server.pem -keystore ${SSL_DIR}/datamesh_truststore -storetype PKCS12 -storepass changeit -noprompt

cp ${SSL_DIR}/datamesh_truststore ${DOCKER_BASE_DIR}/almond-with-storage-certs/

echo "Generate special keystore for the Hadoop Google library
since the Hadoop Google libray uses 'google.p12' as keystore 
and we need to trick the library into using our truststore by 
renaming it and packing it into a jar that we put first on 
the classpath of the delta sharing server"

mkdir -p ${SSL_DIR}/${GOOGLE_CERT_PATH}
cp ${SSL_DIR}/datamesh_truststore ${SSL_DIR}/${GOOGLE_CERT_PATH}/google.p12

keytool -storepasswd -keystore ${SSL_DIR}/${GOOGLE_CERT_PATH}/google.p12 -storepass changeit -new notasecret -noprompt
jar cf ${SSL_DIR}/fake-gcs-server-cert.jar -C ${SSL_DIR} com

echo "Build GCS service-account json"
PRIVATE_KEY=$(cat ${SSL_DIR}/gcs_private_key.pem | tr '\n' '#' | sed -e 's#\##\\n#g')
PRIVATE_KEY_ID=$(shasum ${SSL_DIR}/gcs_private_key.pem | awk '{print $1}')
cat > ${SSL_DIR}/service-account-dummy.json <<-EOF
{
  "type": "service_account",
  "project_id": "test-project",
  "private_key_id": "${PRIVATE_KEY_ID}",
  "private_key": "${PRIVATE_KEY}",
  "client_email": "dummykeys@example.com",
  "client_id": "123456789123456000000",
  "auth_uri": "https://gcsserver/o/oauth2/auth",
  "token_uri": "https://gcsserver/token",
  "auth_provider_x509_cert_url": "https://gcsserver/oauth2/v1/certs",
  "client_x509_cert_url": "https://gcsserver/robot/v1/metadata/x509/dummykeys%40example.com"
}

EOF
exit 0