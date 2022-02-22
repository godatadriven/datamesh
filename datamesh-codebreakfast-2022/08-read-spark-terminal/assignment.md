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

```
spark-shell --packages io.delta:delta-core_2.12:1.0.0,io.delta:delta-sharing-spark_2.12:0.1.0
```

```
val profile_file = "file:///opt/delta/conf/delta.profile"
val table_url = profile_file + "#demo.world.cities"

val sharedDF = spark.read.format("deltaSharing").load(table_url)
sharedDF.show()
```

To finish the challenge, press **Check**.
