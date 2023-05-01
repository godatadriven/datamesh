# Handson part of the Datamesh Workshop

## Start a session in the sparkshell docker container

```bash
docker exec -ti datamesh_sparkshell_1 /bin/bash
```

## Prepare the SSL certificates

We need to add our azure ssl certificates to a java keystore. we do this by combining our azure_keystore with the default java keystore

```bash
cp /opt/spark/ssl/datamesh_truststore /tmp/combined_truststore
```

```bash
keytool -importkeystore \
-srckeystore /usr/local/openjdk-11/lib/security/cacerts \
-destkeystore /tmp/combined_truststore \
-srcstoretype JKS \
-deststoretype PKCS12 \
-srcstorepass changeit \
-deststorepass changeit \
-v
```

## Start a spark shell

Depending if we want to use plain spark en delta
or spark and delta sharing we need to provide different configuration to our spark shell

### Spark and Delta

```bash
spark-shell --packages "io.delta:delta-core_2.12:2.3.0"    --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.hadoop.fs.azure.account.key.devstoreaccount1.blob.azserver:10000=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw== --conf spark.driver.extraJavaOptions="-Djavax.net.ssl.trustStore=/tmp/combined_truststore -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=pkcs12" --conf spark.executor.extraJavaOptions="-Djavax.net.ssl.trustStore=/tmp/combined_truststore -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=pkcs12"
```

```scala
val df = spark.read.format("delta").load("wasbs://world@devstoreaccount1.blob.azserver:10000/cities/cities")

df.show()

val dfs = spark.read.format("delta").load("wasbs://sales@devstoreaccount1.blob.azserver:10000/sales")

dfs.show()
```

### Spark and Deltasharing

```bash
spark-shell --packages "io.delta:delta-core_2.12:2.3.0,io.delta:delta-sharing-spark_2.12:0.6.3" --conf spark.driver.extraJavaOptions="-Djavax.net.ssl.trustStore=/tmp/combined_truststore -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=pkcs12" --conf spark.executor.extraJavaOptions="-Djavax.net.ssl.trustStore=/tmp/combined_truststore -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=pkcs12"
```  

```scala
val profile_file = "file:///opt/delta/conf/delta.profile"

val az_table_url = profile_file + "#azurite_demo.azworld.cities"

val sharedAzDF = spark.read.format("deltaSharing").load(az_table_url)
sharedAzDF.show()

val aws_table_url = profile_file + "#demo.world.cities"

val sharedAwsDF = spark.read.format("deltaSharing").load(aws_table_url)
sharedAwsDF.show()
```
