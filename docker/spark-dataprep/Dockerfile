ARG SPARK_VERSION=3.3.2
FROM godatadriven/spark:${SPARK_VERSION}

ENV SDK_AWS_VERSION=1.12.459
ENV HADOOP_AWS_VERSION=3.3.5
ENV HADOOP_AZURE_VERSION=3.3.5
ENV SDK_AZURE_VERSION=8.6.6
ENV HADOOP_GCP_VERSION=2.2.12

ENV SDK_AWS_CHECKSUM=34153241a1005d6753421b4e3ac5a9ec4d8828a4a07ca41a07238c56dc9be1f4
ENV HADOOP_AWS_CHECKSUM=7df91421fd5ae8cab7d7a3a254c7513d252c52ebc1dd04f2ed819fe5fafc93e1
ENV SDK_AZURE_CHECKSUM=f53ae279808287bbe779b43cc0aa0f781ace0129f169572cb6bf311115ece8e1
ENV HADOOP_AZURE_CHECKSUM=c688f28249b359b70a2cf279310d18771dd10c41e049061ec4832bedb5be2298
ENV POSTGRES_JDBC_CHECKSUM=7ffa46f8c619377cdebcd17721b6b21ecf6659850179f96fec3d1035cf5a0cdc
ENV HADOOP_GCP_CHECKSUM=c30eb4b92353541c09f594716bbb2ca6e792f0835487a195ce48d226d25d1c9d

RUN apt-get update && \
    apt-get install -y curl ca-certificates curl apt-transport-https lsb-release gnupg && \
    apt-get clean

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null


RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update && apt-get install -y azure-cli

RUN curl -o /usr/spark/jars/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/$SDK_AWS_VERSION/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar && \
  echo "$SDK_AWS_CHECKSUM /usr/spark/jars/aws-java-sdk-bundle-$SDK_AWS_VERSION.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/hadoop-aws-$HADOOP_AWS_VERSION.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar && \
  echo "$HADOOP_AWS_CHECKSUM /usr/spark/jars/hadoop-aws-$HADOOP_AWS_VERSION.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/azure-storage-$SDK_AZURE_VERSION.jar https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage/$SDK_AZURE_VERSION/azure-storage-$SDK_AZURE_VERSION.jar && \
  echo "$SDK_AZURE_CHECKSUM /usr/spark/jars/azure-storage-$SDK_AZURE_VERSION.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/hadoop-azure-$HADOOP_AZURE_VERSION.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/$HADOOP_AZURE_VERSION/hadoop-azure-$HADOOP_AZURE_VERSION.jar && \
  echo "$HADOOP_AZURE_CHECKSUM /usr/spark/jars/hadoop-azure-$HADOOP_AZURE_VERSION.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/jetty-util-11.0.7.jar https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/11.0.7/jetty-util-11.0.7.jar && \
  echo "2daef5e5740622b1fc9922804dc4c1fba78d7d0930ac5714722309b6395bd710 /usr/spark/jars/jetty-util-11.0.7.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/jetty-util-ajax-11.0.7.jar https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util-ajax/11.0.7/jetty-util-ajax-11.0.7.jar && \
  echo "096f2d236e239741ebcf42dedfc66794f75ddd5973f75e0ea3ca827583dddb47 /usr/spark/jars/jetty-util-ajax-11.0.7.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/gcs-connector-hadoop3-$HADOOP_GCP_VERSION-shaded.jar https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/hadoop3-$HADOOP_GCP_VERSION/gcs-connector-hadoop3-$HADOOP_GCP_VERSION-shaded.jar && \
  echo "$HADOOP_GCP_CHECKSUM /usr/spark/jars/gcs-connector-hadoop3-$HADOOP_GCP_VERSION-shaded.jar" | sha256sum -c -

RUN curl -o /usr/spark/jars/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
  echo "$POSTGRES_JDBC_CHECKSUM /usr/spark/jars/postgresql-42.2.5.jar" | sha256sum -c -

RUN echo "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" > ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.connection.ssl.enabled=false" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.path.style.access=true" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.s3a.multipart.size=104857600" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.wasbs.impl=org.apache.hadoop.fs.azure.NativeAzureFileSystem" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
  echo "spark.hadoop.fs.AbstractFileSystem.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS" >> ${SPARK_HOME}/conf/spark-defaults.conf
