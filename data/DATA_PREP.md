# Data Mesh data preparation

Data preparation for the Data Mesh presentation at GoDataFest 2021


## Setup Preparation

```bash
docker-compose up --build
```

### Use spark to prepare a delta table

We have the world cities data available in csv format. To enable delta-sharing to share data we first need to convert this csv to the delta format.

```bash
docker exec -ti datamesh_sparkprepare_1 /bin/bash
```

```bash
spark-shell --packages io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0 --conf spark.hadoop.fs.s3a.access.key=${AWS_ACCESS_KEY_ID} --conf spark.hadoop.fs.s3a.secret.key=${AWS_SECRET_ACCESS_KEY} --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem --conf spark.hadoop.fs.s3a.endpoint="${AWS_SERVER}:${AWS_PORT}" --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false --conf spark.hadoop.fs.s3a.path.style.access=true --conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem
```

```spark
val citiesDF = spark.read.options(Map("header"->"true", "inferSchema"->"true")).csv("s3://demodata/rawdata/world/cities/sample.csv")
citiesDF.show(truncate=false)
citiesDF.printSchema()
citiesDF.write.format("delta").save("s3://demodata/silver/world/cities")
```

To extract this delta table to the local file system we can copy it from s3 to a mounted volume

```bash
docker exec -ti datamesh_s3server_1 /bin/bash
```

```bash
awslocal s3 cp s3://demodata/silver/world/cities /initdata/cities --recursive
```

#### Sales data preparation

```spark
val salesDF = spark.read.options(Map("header"->"true", "inferSchema"->"true")).csv("s3://demodata/rawdata/sales/sample.csv")
salesDF.show(truncate=false)
salesDF.printSchema()

val partitionedSalesDF = (salesDF
  .withColumn("ORDER_TIMESTAMP", to_timestamp(col("ORDERDATE"), "M/d/yyyy H:mm"))
  .withColumn("year", date_format(col("ORDER_TIMESTAMP"), "yyyy"))
  .withColumn("month", date_format(col("ORDER_TIMESTAMP"), "MM"))
  .withColumn("day", date_format(col("ORDER_TIMESTAMP"), "dd"))
)

partitionedSalesDF.write.partitionBy("year", "month", "day").format("delta").save("s3://demodata/silver/sales/")
```

##### Update data so we have multiple versions available

```spark
import io.delta.tables._
import org.apache.spark.sql.functions._

val updatedDF = spark.read.format("delta").load("s3://demodata/silver/sales/").where("month=5").where("day=28").withColumn("CONTACTFIRSTNAME", lit("Martin"))

(
DeltaTable.forPath(spark, "s3://demodata/silver/sales/")
  .as("sales")
  .merge(
    updatedDF.as("updates"),
    "sales.ORDERNUMBER = updates.ORDERNUMBER AND sales.ORDERLINENUMBER = updates.ORDERLINENUMBER")
  .whenMatched
  .updateExpr(
    Map("CONTACTFIRSTNAME" -> "updates.CONTACTFIRSTNAME"))
  .execute()
)

spark.read.format("delta").load("s3://demodata/silver/sales/").where("month=5").where("day=28").show()
```

To extract also this delta table to the local file system we can copy it from s3 to a mounted volume

```bash
docker exec -ti datamesh_s3server_1 /bin/bash
```

```bash
awslocal s3 cp s3://demodata/silver/sales /initdata/sales --recursive
```

### Copy data also to Azurite

#### Create the blob containers

```bash
az storage container create -n world --connection-string "DefaultEndpointsProtocol=https;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=https://devstoreaccount1.blob.azserver:10000;QueueEndpoint=https://devstoreaccount1.blob.azserver:10001;"
```

```bash
az storage container create -n sales --connection-string "DefaultEndpointsProtocol=https;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=https://devstoreaccount1.blob.azserver:10000;QueueEndpoint=https://devstoreaccount1.blob.azserver:10001;"
```

### Upload the files

```bash
az storage blob upload-batch -d world --connection-string "DefaultEndpointsProtocol=https;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=https://devstoreaccount1.blob.azserver:10000;QueueEndpoint=https://devstoreaccount1.blob.azserver:10001;" -s /initdata/cities/ --destination-path cities/cities/
```

```bash
az storage blob upload-batch -d sales --connection-string "DefaultEndpointsProtocol=https;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=https://devstoreaccount1.blob.azserver:10000;QueueEndpoint=https://devstoreaccount1.blob.azserver:10001;" -s /initdata/sales/ --destination-path sales/
```