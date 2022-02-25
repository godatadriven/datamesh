FROM almondsh/almond:latest

USER root

COPY azure_truststore /tmp/azure_truststore

RUN keytool -importkeystore -destkeystore /etc/ssl/certs/java/cacerts -srckeystore /tmp/azure_truststore -srcstoretype PKCS12 -deststoretype jks -srcstorepass changeit -deststorepass changeit

USER $NB_UID
