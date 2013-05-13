# Leonidas

leonidas.js handles generalized web application multi-client concurrency through basic command operations. 

Leonidas.rb is an integration built to support Leonidas commands on the server-side. There are also two default Sinatra endpoints provided at Leonidas::Routes::SyncApp for an immediate integration with leonidas.js.

## Key Features

* AJAX synchronization
* Long-running app support in memory on the server side
* Persistence layer wrappers to support resuming an application that has been closed in memory
* Default behavior to losslessly resume application following browser failure or crash (unimplemented)
* Default behavior to losslessly resume application following server failure or crash (unimplemented)

## Terminology

### General

* Command - Any granular action taken within an application
* Command Handler - An class representing an action taken on the application state in response to a command 
* Stable Timestamp - The minimum timestamp of all client connections to the app
* Stable Command - A command that was generated at or before the stable timestamp

### Javascript

* Client - A wrapper around the client-side application state, representing a single client connection to the server
* Commander - The command abstraction, used to start and stop syncing, and issue commands
* Local Command - A command that originated on this client
* External Command - A command that came from the server

### Ruby

* App - A server side application which keeps track of state and client connections
* Connection - The server side implementation of a client containing a list of commands 
* Repository - The mechanism for retrieving an active application
* Persister - A class responsible for providing the methods necessary to persist an app in a particular system
* State Builder - A class responsible for rebuilding the state of a persisted application to be loaded into memory

## Configuration

### Javascript

No configuration is needed on the client side.

### Ruby

Persistence of commands in your system will be handled in the server side command handlers, but if your application details need to be persisted, there are only two functions necessary to configure Leonidas:

* persister\_class\_is(persister\_class) - The class responsible for handling persisting the application will be passed into this function

* add\_app\_state\_builder(builder\_class) - For every application you need to support, you will likely need a custom state builder to generate the appropriate state for that application

And example config would resemble the following:

    persister_class_is SaveMyTransgressions

    add_app_state_builder Builders::PeasantStateBuilder
    add_app_state_builder Buidlers::AristocraticStateBuilder

## Usage

### Javascript

First, create at least one handler for commands in your system (I'm going to use Coffeescript, because it's so nice):

    Handler = require "leonidas/commands/handler" # require() is provided by this library

    class PeasantHitHandler extends Handler # gives you automatic testing by command name

      constructor: (@state)-> # this is temporary - I would much rather be passing in @peasants
        @name = "peasant-hit" # this will be tested against by #handles - for more customized conditions, override handles

      run: (command)->
        peasantName = command.data.peasantName
        ... find peasant in @state by peasantName
        peasant.status = "humbled"

      rollback: (command)->
        peasantName = command.data.peasantName
        ... find peasant in @state by peasantName
        peasant.status = "blissful"

Then, create a client for your app (this represents a single command source, with it's own id and state):

    Client = require "leonidas/client"
    var client = new Client("clientId", { peasants: [ ... ] })

Now you can create a Commander (I would suggest using the default configuration, unless you need custom functionality in the nitty gritty):

    Commander = require "leonidas/commander"
    var supremeRuler = Commander.default(client, [ new PeasantHitHandler(client.state) ], "http://mydomain.com/my/sync/url")

With the commander you can start and stop syncing and issue commands to your heart's content:

    supremeRuler.startSync() # not the funniest line... oh well
    supremeRuler.issueCommand("peasant-hit", { peasantName: "Semmi" })

This will automatically be handled and synced with your server, most importantly so that you will know if any ruthless rulers from other clients have been hitting your peasants.

### Ruby

As always, the server side is a bit more complicated.

First, you should create at least one command handler. Note that the handler will have the logic necessary to persist your changes - the mechanism for running commands is agnostic, so all persistence options are supported:
    
    class PeasantHitHandler < ::Leonidas::Commands::Handler

      def initialize(app) # similar problem - have to make sure object references work properly
        @app = app
        @name = "peasant-hit"
      end

      def run(command)
        peasant_name = command.data[:peasantName] # probably camel-cased - it came from js, after all
        ... # find peasant in @app.current_state.peasants by peasant_name
        peasant.status = :humbled
      end

      def persist(command)
        ... # persistence logic - up to you, homie
      end

      def rollback(command)
        peasant_name = command.data[:peasantName]
        ... # find peasant in @app.current_state.peasants by peasant_name
        peasant.status = :blissful
      end
    end

Then, you can create an App:

    class PeasantSubjugationApp
      include Leonidas::App::App # this is the neat part that gives you a Leonidas App

      def initialize
        @name = "Kingdom-Zamunda" # this name must be unique amongst all your apps
        @persist_state = true # this means that commands with be persisted when they are run
        @state = { peasants: [ ... ] } # this is what handlers will be affecting
      end

      def handlers # this is provided for the processor to initialize itself upon invocation
        [
          PeasantHitHandler.new(self)
        ]
      end

    end

This is enough to have a functioning Leonidas app - of course, it's likely you will need customization to handle the semantic details of your state.

Now you want to run your app and rule your kingdom (from an endpoint in Sinatra):

    include Leonidas::App::AppRepository # I recommend using the mixin, it makes the function available

    get "/rule-zamunda" do
      app = PeasantSubjugationApp.new
      app_repository.watch app # now the app is being stored and referenced from memory
      ...
    end

Eventually you need to load your app:
    
    ...
    get "/i-want-to-rule-zamunda-too" do
      app = app_repository.find "Kingdom-Zamunda"
      ...
      haml :see_your_kingdom
    end

Great! We now have an app running in memory, updating state, and if you did well, communicating to the client(s) at regular intervals.

But what if you (a) need to restart the machine and lose all of your state from memory, or (b) want to revive an old closed application? This is where a persistent application comes into play. A persistent application means simply that you have stored your application details, active connections, and commands in some sort of database. In order to reopen an application that has been closed, or restore an application to memory from disk, we need to be able to load the app from the database via a generalized solution. 

Enter the persister:

    class SaveMyTransgressions
      include Leonidas::PersistenceLayer::AppPersister # this guarantees that the static Persister can use your class

      def load(app_name)
        ... # your read / build logic (note that you don't need to worry hear about app state)
      end

      def persist(app_name)
        ... # your write logic
      end

      def delete(app)
        ... # your remove logic
      end
    end

The gist of filling out this class is to allow communication between your database and code to read / write app details (name, persist_state, connections) and connection details (id, last_update, active / inactive commands).

Once you have created your app persister, your application skeleton can be loaded - this just leaves catching the state up with whatever was current. All you need to do in this case is make sure you build the previous locked state of the application. All commands that happened after that locked state will be run again in memory to return your application to a live state.

Create your application's state builder:

    module Builders

      class PeasantStateBuilder
        include Leonidas::PersistenceLayer::StateBuilder # this lets the state factory use this builder

        def handles?(app)
          app.is_a? PeasantSubjugationApp
        end

        def build_stable_state(app)
          ... # return the peasants to the fields, so to speak
        end

      end

    end

Lastly, if you want to use the Sinatra endpoints provided by Leonidas for automatically syncing between your clients and server, the Rack app is available:

    map "/path/you/like" do
      run Leonidas::Routes::SyncApp
    end

This will mean the frontend syncUrl you pass in Commander.default would look something like "http://yourdomain.com/path/you/like/[your-app-name]"

Voilá, your app should be good to go.

## If (and when) it isn't

Please feel free to contribute, or submit issues to the tracker!











