FROM almondsh/almond:latest

USER root

COPY datamesh_truststore /tmp/datamesh_truststore

RUN keytool -importkeystore -destkeystore /etc/ssl/certs/java/cacerts -srckeystore /tmp/datamesh_truststore -srcstoretype PKCS12 -deststoretype jks -srcstorepass changeit -deststorepass changeit

USER $NB_UID
