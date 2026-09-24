# Filesystem VS object store

The goal of this project is to compare execution time of filesystem and object store in multiples operations :
- Import single big file of 10 Mo
- Import 100 small files of 500 o
- Rename folder/bucket
- List files/objects of a folder/bucket
- Read the middle of a file (1 Mo in 10 Mo)


## How it work ?
The `run.sh` file is used to launch minIO object storage in a Docker container.

The `benchmark.sh` file is used to compare your local filesystem with minIO (object store), it will create several files used for tests and it will cleaning them after.


## Requirements
To run this benchmark, you must have minIO client, to install it, run :

```
sudo wget -O /usr/local/bin/mc https://dl.min.io/aistor/mc/release/linux-amd64/mc
sudo chmod +x /usr/local/bin/mc
```


## Run benchmark
To launch minIO Docker container :

```
./run.sh
```

To run benchmark :

```
./benchmark.sh
```

I files are not executable, run :

```
chmod +777 ./run.sh
chmod +777 ./benchmark.sh
```