# Leonidas

leonidas.js handles generalized web application concurrency through basic command operations. It handles synchronizing application state by sending serialized lists of local commands and retrieving commands processed on external commands to and from a server with AJAX. 

Leonidas.rb is an integration built to support Leonidas commands on the server-side, in both memory and persistent states. There are also two default Sinatra endpoints provided at Leonidas::Routes::SyncApp for an immediate integration with leonidas.js.

## Terminology

### General

* Command - Any granular action taken within an application
* Command Handler - An class representing an action taken on the application state in response to a command 

### Javascript

* Client - A wrapper around the client-side application state, representing a single client connection to the server
* Commander - The command abstraction, used to start and stop syncing, and issue commands

### Ruby

* App - A server side application which keeps track of state and client connections
* Connection - The server side implementation of a client containing a list of commands 
* Repository - The mechanism for retrieving an active application
* Persister - A class responsible for providing the methods necessary to persist an app in a particular system
* State Builder - A class responsible for rebuilding the state of a persisted application to be loaded into memory

## Configuration




## Usage

