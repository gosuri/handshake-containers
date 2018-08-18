# handshake-containers

handshake-containers contains docker and kubernetes configuration files for handshake binaries `hsd` and `hnsd` and deploying them on a kubernetes cluster

## Usage

### hsd

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

Alternatively, you could also use `make runrs` if you have this repo cloned locally.

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

### Building

```
$ cd hsd
$ make build
```

Note: The hsd container will be tagged as `quay.io/ovrclk/hsd`, you can change that by running `make build IMAGE=whatever` or update in the `Makefile`

### Deploying on a Kubernetes cluster

#### Create a config map

```sh
$  kubectl create configmap hsd-config \
  --from-literal=hsd.nshost=0.0.0.0    \
  --from-literal=hsd.nsport=53         \
  --from-literal=hsd.rshost=0.0.0.0    \
  --from-literal=hsd.rsport=53         \
```

#### Create Deployments

#### Authoritative Server

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-ns.yml
```

#### Recursive Server

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-ns.yml

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

#### Authoritative Server

Label the node for authoritative server, the below examples uses `master.sjc.ix` for authoritative server, replace `master.sjc.ix` with your node name

```sh
$ kubectl label nodes master.sjc.ix hsd_role=ns --overwrite=true
node/master.sjc.ix labeled
```

Create the deployment

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-ns-nodesel.yml
```

#### Recursive Server

Label the node for recursive server, the below examples uses `worker.sjc.ix` for recursive server, replace `worker.sjc.ix` with your node name

```sh
$ kubectl label nodes worker.sjc.ix hsd_role=rs --overwrite=true
node/worker.sjc.ix labeled
```

Create the deployment

```sh
$ kubectl create -f https://raw.githubusercontent.com/gosuri/handshake-docker/master/hsd/k8s/deploy-rs-nodesel.yml
```
