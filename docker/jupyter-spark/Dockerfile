ARG SPARK_VERSION=3.3.2
FROM jupyter/pyspark-notebook:spark-${SPARK_VERSION}

RUN pip install toree
RUN jupyter toree install --spark_home=/usr/local/spark --sys-prefix

USER root

COPY datamesh_truststore /tmp/datamesh_truststore

RUN keytool -importkeystore -destkeystore /etc/ssl/certs/java/cacerts -srckeystore /tmp/datamesh_truststore -srcstoretype PKCS12 -deststoretype jks -srcstorepass changeit -deststorepass changeit

USER $NB_UID

