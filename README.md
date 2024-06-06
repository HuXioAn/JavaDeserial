# Query on Java Deserialization Vulnerability 

In this repo, there're scripts for getting and querying opensource Java projects on Github with CodeQL. The scripts are in Shell, Python and CodeQL. The results of 550 Java projects are in the archive [results](./queryReport.zip).

## Usage

The scripts are a set of utilities that is used to perform the query on hundreds of projects, in parallel.

### Prepare the target projects

Place the Github url of the target projets in a text file, one line an url, like this:

```
https://github.com/apache/hertzbeat
https://github.com/OpenTSDB/opentsdb
https://github.com/Devlight/NavigationTabBar
https://github.com/deathmarine/Luyten
https://github.com/traex/RippleEffect
```

Or use the [getRepo](./getRepo/getRepoList.py) Python script to search the Github with some options like language or stars:

``` shell
# change the github token in the script
python3 ./getRepo/getRepoList.py ./repoList.txt
cat ./repoList.txt
```

Now we have the list of the target projects' url, their CodeQL databases can be downloaded with the script [getDatabase](./getRepo/getDataBase.py):

``` shell
# try to download the databases of projects 0 - 100 in ./repoList.txt from github
python3 ./getRepo/getDataBase.py ./database/ ./repoList.txt 0 100
ls ./database
# now the databases should be in the folder with names like Owner_repoName_Index.zip
```

### Query the databases

The query on hundreds of databases can be time consuming, it's better to make it parallel.

``` shell
# query the pack or query on all the databases in the folder, with 5 threads, start from 0. The report will be in ./database/report as assigned.
./codeql/queryAllPara.sh ./database ./codeql/deserial/idDeserial.ql report 5 0

# It can take lone time, use the index to resume from the breaking point.
# By changing the second argument, any CodeQL pack or script can be performed 
```



