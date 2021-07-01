# Webapp and API using Haskell

This project aims at building a web app and API using Haskell. The project is built using [cabal](https://www.haskell.org/cabal/#install-upgrade) and [Spock](https://www.spock.li/), so make sure you have cabal installed before using this (Spock will be installed during the process). Lets dive into the installation process (I am assumiung you have already installed cabal)

## Installation
The process is pretty simple, you need to follow the following steps to get started:
### Steps:
1. Clone the repo using the following command:
``` bash
git clone git@github.com:paritosh-08/personkeeper.git
```
2. Install using the following command:
``` bash
cd personkeeper
cabal update
cabal new-install
```

## Run the program
Run the following command to run the program:
``` bash
cabal new-run :personkeeper
```
Now open your browser and go to http://localhost:3000/ for the webapp, here you can view the people in the database and can add new person into the database using the form.

For API, go to http://localhost:3000/api, here you will get a json output of all the people in the database, you can get specific people on the endpoint: http://localhost:3000/api/[ID]. Also you can add new people by a post request on the API url:
``` bash
curl -H "Content-Type: application/json" -d '{ "name": "New Person", "age": 31 }' localhost:3000/api
```

## References
1. https://www.spock.li/tutorials/rest-api
2. https://haskell-at-work.com/episodes/2018-04-09-your-first-web-application-with-spock.html
