---
slug: read-spark-terminal
id: ph9hukuc5vmf
type: challenge
title: Read delta sharing data with spark
teaser: Read delta sharing data in spark
notes:
- type: text
  contents: |
    # Learn about Delta Sharing
    Delta Sharing is the open protocol for sharing data from your Data Mesh!

    We will read data with spark.
tabs:
- title: Terminal
  type: terminal
  hostname: instruqt-datamesh-multicloud
difficulty: basic
timelimit: 600
---

Start a spark shell from within the spark docker container

```
docker exec -ti instruqt-datamesh-multicloud-vm_sparkshell_1 /bin/bash
```

We need to add our azure ssl certificates to the java keystore. We do this by combining our azure_keystore with the default java keystore

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

```
spark-shell --packages io.delta:delta-core_2.12:1.0.1,io.delta:delta-sharing-spark_2.12:0.4.0 --conf spark.driver.extraJavaOptions="-Djavax.net.ssl.trustStore=/tmp/combined_truststore -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=pkcs12" --conf spark.executor.extraJavaOptions="-Djavax.net.ssl.trustStore=/tmp/combined_truststore -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=pkcs12"
```

```
val profile_file = "file:///opt/delta/conf/delta.profile"
val s3_table_url = profile_file + "#demo.world.cities"

val s3_sharedDF = spark.read.format("deltaSharing").load(s3_table_url)
s3_sharedDF.show()

val az_table_url = profile_file + "#azurite_demo.azworld.cities"

val az_sharedDF = spark.read.format("deltaSharing").load(az_table_url)
az_sharedDF.show()
```

To finish the challenge, press **Check**.
