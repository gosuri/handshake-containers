# handshake-containers

handshake-containers contains docker and kubernetes configuration files for handshake binaries `hsd` and `hnsd` and deploying them on a kubernetes cluster. I wrote this to deploy handshake testnet on the [Akash TestNet](http://akash.network), currently running at:


```
Authoritative Servers
=====================
147.75.100.181 (Amsterdam)  
147.75.101.29  (Amsterdam) 
147.75.66.225  (New Jersey) 
147.75.199.23  (New Jersey)
147.75.70.213  (San Jose)
147.75.201.51  (San Jose)
147.75.92.159  (Tokyo)
147.75.93.187  (Tokyo)

Recursive Servers
=================
147.75.100.147 (Amsterdam)
147.75.32.169  (Amsterdam)
147.75.74.41   (New Jersey)
147.75.199.1   (New Jersey)
147.75.201.9   (San Jose)
147.75.201.45  (San Jose)
147.75.93.181  (Tokyo)
147.75.93.185  (Tokyo)
```

Verify using dig for any of the IPs above:

```
$ dig @147.75.100.181 com NS
$ dig @147.75.100.147 google.com A +short
```

To check all the servers are responding, run the below:

```
$ curl -s https://raw.githubusercontent.com/gosuri/handshake-docker/master/scripts/test-akash | bash

```

## hsd

[hsd](https://github.com/handshake-org/hsd) is handshake daemon & full node, an implementation of the [handshake](https://handshake.org/) protocol.

### Running

`hsd` binary supports authoritative and recursive modes.

#### Authoritative server

To start handshake authoritative server on port `5301` locally execute the below. Alternatively, you could also use `make runns` if you have this repo cloned locally.

```sh
$ docker run --rm -it -p 5301:53/udp quay.io/ovrclk/hsd --ns-host 0.0.0.0 --ns-port 53
```

Verify using using dig:

```sh
$ dig @localhost -p 5301 com NS

; <<>> DiG 9.10.6 <<>> @localhost -p 5301 com NS
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17451
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 13, ADDITIONAL: 28
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;com.				IN	NS

;; AUTHORITY SECTION:
com.			172800	IN	NS	a.gtld-servers.net.
com.			172800	IN	NS	b.gtld-servers.net.
com.			172800	IN	NS	c.gtld-servers.net.
...
```

#### Recursive server

To start handshake recursive server on port `5302` locally execute the below:

```sh
$ docker run --rm -it -p 5302:53/udp quay.io/ovrclk/hsd --rs-host 0.0.0.0 --rs-port 53
```

Alternatively, you could also use `make hsd.runrs` if you have this repo cloned locally.

Verify using using dig:

```sh
$ dig @localhost -p 5302 +short google.com

173.194.175.100
173.194.175.139
173.194.175.102
173.194.175.113
173.194.175.101
173.194.175.138
```

### Building locally

```
$ make hsd.build
```

Note: The hsd container will be tagged as `quay.io/ovrclk/hsd`, you can change that by running `make build HSD_IMAGE=whatever` or update in the `Makefile`

## Deploying on a Kubernetes cluster

### Create config map for hsd

Create a config map from the provided config:

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/config.yml
```

Alternatively, you could also create the config map from literal

```sh
$  kubectl create configmap hsd-config \
  --from-literal=hsd.nshost=0.0.0.0    \
  --from-literal=hsd.nsport=53         \
  --from-literal=hsd.rshost=0.0.0.0    \
  --from-literal=hsd.rsport=53         \
```

### Create Deployments

#### Authoritative Server

Create a kubernetes deployment by running:

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-ns.yml
```

#### Recursive Server

Create a kubernetes deployment by running:
```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-rs.yml

```

#### Resolve Port Conflicts

Both authoritative and recursive servers use port `53` which causes a conflict while running on the same server. A solution is run them of seperate machines and use node selectors to ensure kubernetes runs the containers on the assigned nodes.

First, pick a node you'd like to assign by listing nodes:

```sh
$ kubectl get node

NAME            STATUS    ROLES     AGE       VERSION
master.sjc.ix   Ready     master    2d        v1.11.2
worker.sjc.ix   Ready     <none>    2d        v1.11.2
```

We'll use `master.sjc.ix` for authoritative and `worker.sjc.ix` for recursive.

##### Authoritative Server

Label the node for authoritative server, the below examples uses `master.sjc.ix` for authoritative server, replace `master.sjc.ix` with your node name

```sh
$ kubectl label nodes master.sjc.ix hsd_role=ns --overwrite=true
node/master.sjc.ix labeled
```

Create the deployment

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-ns-nodesel.yml
```

##### Recursive Server

Label the node for recursive server, the below examples uses `worker.sjc.ix` for recursive server, replace `worker.sjc.ix` with your node name

```sh
$ kubectl label nodes worker.sjc.ix hsd_role=rs --overwrite=true
node/worker.sjc.ix labeled
```

Create the deployment

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-rs-nodesel.yml
```

## hnsd

[hnsd](https://github.com/handshake-org/hnsd) is the handshake light resolver.

## Running

To start handshake SPV resolve on port `5302` locally execute the below. Alternatively, you could also use `make hnsd.run` if you have this repo cloned locally.

```sh
$ docker run --rm -it -p 5302:53/udp quay.io/ovrclk/hnsd --rs-host 0.0.0.0:53 --pool-size 4
```

Verify using using dig:

```sh
$ dig @localhost -p 5302 +short google.com

173.194.175.100
173.194.175.139
173.194.175.102
173.194.175.113
173.194.175.101
173.194.175.138
```

## Building locally

```
$ make hnsd.build
```

## Deploying on a Kubernetes cluster

### Create config map for hnsd

Create a config map from the provided config:

```sh
$ kubectl apply -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hnsd/k8s/config.yml
```

### Create Deployment

Create a kubernetes deployment by running:

```sh
$ kubectl apply -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hnsd/k8s/deploy.yml
```
