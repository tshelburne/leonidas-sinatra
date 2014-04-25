# Leonidas

Leonidas is an integration built to support concurrent commands on the server-side.

## Key Features

* Long-running app support in memory on the server side
* Persistence layer wrappers to support resuming an application that has been closed in memory
* Default behavior to losslessly resume application following browser failure or crash (unimplemented)
* Default behavior to losslessly resume application following server failure or crash

## Terminology

### General

* Command - Any granular action taken within an application
* Command Handler - An class representing an action taken on the application state in response to a command 
* Stable Timestamp - The minimum timestamp of all client connections to the app
* Stable Command - A command that was generated at or before the stable timestamp

* App - A server side application which keeps track of state and client connections
* Client - The server side implementation of a client containing a list of commands 
* Repository - The mechanism for retrieving an active application
* Persister - A class responsible for providing the methods necessary to persist an app in a particular system
* State Builder - A class responsible for rebuilding the state of a persisted application to be loaded into memory

## Configuration

Persistence of commands in your system will be handled in the server side command handlers, but if your application details need to be persisted, there are only two functions necessary to configure Leonidas:

* persister\_class\_is(persister\_class) - The class responsible for handling persisting the application will be passed into this function

* add\_app\_state\_builder(builder\_class) - For every application you need to support, you will likely need a custom state builder to generate the appropriate state for that application

And example config would resemble the following:

    persister_class_is SaveMyTransgressions

    add_app_state_builder Builders::PeasantStateBuilder
    add_app_state_builder Buidlers::AristocraticStateBuilder

## Usage

First, you should create at least one command handler. Note that the handler will have the logic necessary to persist your changes - the mechanism for running commands is agnostic, so all persistence options are supported:
    
    class PeasantHitHandler < ::Leonidas::Commands::Handler

      def initialize(peasants)
        @peasants = peasants
        @name = "peasant-hit"
      end

      # note that if you need a property from data to be anything other than a string, you will likely have to type-cast it before using it
      def run(command) 
        peasant_name = command.data[:peasantName] # probably camel-cased - it came from js, after all
        ... # find peasant in @peasants by peasant_name
        peasant.status = :humbled
      end

      def persist(command)
        ... # persistence logic - up to you, homie
      end

      def rollback(command)
        peasant_name = command.data[:peasantName]
        ... # find peasant in @peasants by peasant_name
        peasant.status = :blissful
      end

      def rollback_persist(command)
        ... # more persistence logic
      end

    end

Then, you can create an App (note that #initialize must be able to take no arguments in order for your app to work with reconciliation in the event of server failure):

    class PeasantSubjugationApp
      include Leonidas::App::App # this is the neat part that gives you a Leonidas App

      def initialize(name="Kingdom-Zamunda")
        @name = "#{name}-#{SecureRandom.uuid}" # this name must be unique amongst all instances of apps
        @persist_commands = true # this means that commands with be persisted when they are run
        @peasants = [ ... ] # this is what handlers will be affecting
      end

      def handlers # this is provided for the processor to initialize itself upon invocation
        [
          PeasantHitHandler.new(@peasants)
        ]
      end

    end

This is enough to have a functioning Leonidas app - of course, it's likely you will need customization to handle the semantic details of your state.

#### In memory

Now you want to run your app and rule your kingdom (from an endpoint in Sinatra):

    include Leonidas::App::AppRepository # I recommend using the mixin, it makes the function available

    get "/rule-zamunda" do
      app = PeasantSubjugationApp.new
      app_repository.watch app # now the app is being stored and referenced from memory
      ...
    end

Eventually you need to find your app in memory:
    
    ...
    get "/look-how-pretty-zamunda-is" do
      app = app_repository.find "Kingdom-Zamunda-[somenumbers]"
      ...
      haml :see_your_kingdom
    end

This is enough to display the state of your app, but we don't have any clients that can issue commands to actually manipulate the app.

    ...
    get "/i-want-to-rule-zamunda-too" do
      app = app_repository.find "Kingdom-Zamunda-[somenumbers]"
      @client_id = app.create_client! # pass this client id to your front end to allow leonidas.js to auto-sync with it
      ...
      haml :rule_your_kingdom
    end

Great! We now have an app running in memory, updating state, and if you did well, communicating to the client(s) at regular intervals.

#### Persistence 

But what if you want to revive an old closed application? This is where a persistent application comes into play. A persistent application means simply that you have stored your application details, active connections, and commands in some sort of database. In order to reopen an application that has been closed, or restore an application to memory from disk, we need to be able to load the app from the database via a generalized solution. 

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

Now when you need to load an app that has been archived:
    
    ...
    get '/i-was-overthrown-but-now-i-am-back-to-rule-again' do
      app = app_repository.load "Kingdom-Zamunda-[somenumbers]"
      @client_id = app.create_client!
      ...
      haml :rule_your_kingdom
    end

Lastly, if you want to use the Sinatra endpoints provided by Leonidas for automatically syncing between your clients and server, the Rack app is available. This will handle all command syncing, plus the automatic reconciliation should your server go down or need to be restarted while an app is live:

    map "/path/you/like" do
      run Leonidas::Routes::SyncApp
    end

This will mean the frontend syncUrl you pass in Commander.default would look something like "http://yourdomain.com/path/you/like"

Voilá, your app should be good to go.

## Managing your apps

Along with creating an app, you might like to be able to view general stats on what is running, or even force close certain apps and / or clients. To view the Leonidas Console, you can mount the Sinatra app below (I recommend using HTTP Authentication at bare minimum, since these routes do provide some basic control over applications in your system):

    Leonidas::Routes::ConsoleApp.use Rack::Auth::Basic do |username, password|
      username == 'username' and password == "password"
    end
    map '/leonidas-console' do
      run Leonidas::Routes::ConsoleApp
    end

## If (and when) it isn't

Please feel free to contribute, or submit issues to the tracker!











