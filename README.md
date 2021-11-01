# datamesh
Material for the DataMesh presentation at GoDataFest 2021


## Setup Preparation

```bash
docker-compose up --build
```

### Use spark to prepare a delta table

We have the world cities data available in csv format. To enable delta-sharing to share date we first need to convert this csv to the delta format.

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

## Setup Demo

```bash
docker-compose  --profile demo up --build
```

### Use spark to read a delta table through delta-sharing

```bash
docker exec -ti datamesh_sparkshell_1 /bin/bash
```

```bash
spark-shell --packages io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0
```

```spark
val profile_file = "file:///opt/delta/conf/delta.profile"

val table_url = profile_file + "#demo.shareddata.cities"

val sharedDF = spark.read.format("deltaSharing").load(table_url)
sharedDF.show()
```

### Use python to read a delta table through delta-sharing

```bash
docker exec -ti datamesh_python_1 /bin/bash
```

```bash
python
```

```python
import delta_sharing

profile_file = "file:///opt/delta/conf/delta.profile"

client = delta_sharing.SharingClient(profile_file)
print(client.list_all_tables())

table_url = profile_file + f"#demo.shareddata.cities"

sharingDF = delta_sharing.load_as_pandas(table_url)
print(sharingDF.head())
```
