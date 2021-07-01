# Notekeeper using Haskell

This project aims at building a web app [notekeeper](https://haskell-at-work.com/episodes/2018-04-09-your-first-web-application-with-spock.html) problems using Haskell. The project is built using [cabal](https://www.haskell.org/cabal/#install-upgrade), so make sure you have cabal installed before using this. Lets dive into the installation process (I am assumiung you have already installed cabal)

## Installation
The process is pretty simple, you need to follow the following steps to get started:
### Steps:
1. Clone the repo using the following command:
``` bash
git clone git@github.com:paritosh-08/notekeeper.git
```
2. Install using the following command:
``` bash
cd notekeeper
cabal update
cabal new-install
```

## Run the program
Run the following command to run the program:
``` bash
cabal new-run :notekeeper
```
Now open your browser and go to http://localhost:8080/