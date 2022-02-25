---
slug: read-python-terminal
id: uspcxvnnpuik
type: challenge
title: Read delta sharing data with python
teaser: Read delta sharing data in python
notes:
- type: text
  contents: |
    # Learn about Delta Sharing
    Delta Sharing is the open protocol for sharing data from your Data Mesh!

    We will read data with python.
tabs:
- title: Terminal
  type: terminal
  hostname: instruqt-datamesh-multicloud
difficulty: basic
timelimit: 600
---

Start a python interpreter from within the python docker container

```
docker exec -ti instruqt-datamesh-multicloud-vm_python_1 /bin/bash
```

```
python
```

```
import delta_sharing
profile_file = "file:///opt/delta/conf/delta.profile"

client = delta_sharing.SharingClient(profile_file)
client.list_all_tables()

s3_table_url = profile_file + "#demo.world.cities"
s3_sharingDF = delta_sharing.load_as_pandas(s3_table_url)
s3_sharingDF.head()

az_table_url = profile_file + "#azurite_demo.azworld.cities"
az_sharingDF = delta_sharing.load_as_pandas(az_table_url)
az_sharingDF.head()
```

To finish the challenge, press **Check**.
