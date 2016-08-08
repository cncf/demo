# Complex Deployments on Kubernetes

Non-trivial deployments sometimes require more advanced kubernetes primitives.  
Two such neccessary building blocks have been recently released as alphas. 

A third, Jobs, has shipped. Kubernetes Jobs are a crucial feature for complex deployments and the pattern is described below.

##  PetSets

PetSets are a special type of deployment/replication-controller in that they create (and name) pods in an ordinal and therefore predictable manner.
PetSets allow some state to be sprinkled in, as long as this is done in an idempotent manner.

### MongoDB Cluster Example using Kubernetes PetSets

Mongo ReplicaSets map very conveniently to Kubernetes PetSets.

Process to [https://docs.mongodb.com/manual/tutorial/deploy-shard-cluster/](Deploy a Sharded Mongo Cluster) is as follows:

- Create the Config Server Replica Set
- Initiate the Config Server Replica Set 
- Repeat this process for the regular Replica Sets independently
- Create a mongos server (pointed at the Config Server Replica Set)
- Via the mongos server configure the cluster to use the regular Replica Sets as shards
- Expose mongos as a service to apps

#### Create and Initiate Replica Sets

Using the official Mongo docker image we launch 3 pods running the command:        

> mongod --configsvr --replSet rs0 --bind_ip 0.0.0.0

Each pod now knows about itself that it is a special type of replica set (config server) and the name of the set is rs0.
However, to initiate the replica set the members must be made aware of each other and reach a quorum. 

```
rs.initiate(
   {
     _id: "<replSetName>",
     configsvr: true,
     members: [
       { _id : 0, host : "rs0-0.example.net:27017" },
       { _id : 1, host : "rs0-1.example.net:27017" },
       { _id : 2, host : "rs0-2.example.net:27017" }
     ]
   }
 )
```

<sub>Fig 1: config document example from the official mongo docs</sub> 

Above shows that the host names of all members of a replica must be deducible.
The usefulness of PetSets now becomes obvious. At the Kubernetes abstraction level, if we name our PetSet "cfg" of size 3 we get pods: cfg-0, cfg-1, cfg-2.

Unlike a regular Kubernetes deployment where the pods would be named in cfg-<randomstring> and created in a none deterministic order.

#### Kubernetes Jobs as One Shot steps of complex deployments

We now know the neccessary mongo Replica Set Initialization command ahead of time, we don't yet know _when_ to run it, and what should execute it.

## InitContainers
