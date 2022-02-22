---
slug: the-protocol-terminal
id: 83wygu92vzm6
type: challenge
title: The delta sharing protocol with curl
teaser: Explore the delta sharing protocol in a terminal.
notes:
- type: text
  contents: |
    # Learn about Delta Sharing
    Delta Sharing is the open protocol for sharing data from your Data Mesh!

    We will explore the Delta Sharing protocol from a terminal.
tabs:
- title: Terminal
  type: terminal
  hostname: instruqt-datamesh-multicloud
difficulty: basic
timelimit: 600
---

Open the terminal tab

Try this example curl request to explore the protocol:
```
curl -s \
     -X GET \
     -H 'Authorization: Bearer authTokenDeltaSharing432' \
     localhost:38080/delta-sharing/shares \
  | jq
```

Other example paths:
- shares/demo/schemas
- shares/demo/schemas/world/tables
- shares/demo/schemas/world/tables/cities/query (POST)

To finish the challenge, press **Check**.
