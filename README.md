# ElixirAMQP

## Requirements

You landed your new job at Totally Reliable Code TM and you have been asked to create the following application.
Our client asked for storing three different datasets that should be able to be queried from an API.
( datasets given on the zip file)
Our client is a bit picky and asked us to develop the following requirements:
  1. All data must be published to RabbitMQ and it must be separated by topics. (Topics are the three different datasets) must be async and should be as fast as possible.
  2. All RabbitMQ messages for each topic must be consumed asynchronously.
  3. Consumed data should be stored to PostgreSQL in any way you like
  4. REST API that is capable of filtering data by topic and can be paginated.
  Extra:
  1. A Redis server for catching API data.
  2. Create a docker container for building the application.
  3. REST API only reads data from Redis.
Create High performance when publishing/consuming (RabbitMQ) and storing to PostgreSQL is highly desired.
Any library can be used.

## Setup

  **Steps**
  1. Build and start a docker container :-
  
  ```console
  * docker-compose build
  * docker-compose up
  ```

  2. Publish data:

  ```elixir

      @doc """
        This function call ElixirAMQP.DataHandler and read the files from
        the priv/data path and publish the data to RabbitMQ topic.

        ## Examples

        iex>  ElixirAMQP.dispatch_data
      """
    ```

## Docker
  1. **Phoenix Application**
    To start your Phoenix server:

      * Install dependencies with `mix deps.get`
      * Create and migrate your database with `mix ecto.setup`
      * Start Phoenix endpoint with `mix phx.server`

    Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

  2. **PostgreSQL**
    `psql postgresql://postgres:postgres@localhost:5433/postgres`

  3. **RabbitMQ**
    version: `3.8`
    configs: `/docker/rabbitmq/`
    Port: 5672

  4. **Redis**
    version: `4.0`
    Port: 6379

## Insights

  1. **Architecture**
      FileName                  TableName          TopicName
    a) dielectron.csv           `dielectrons`      `dielectrons`
    b) memegenerator.csv        `memes`            `mems`
    c) twitchdata-update.csv    `twitches`         `twitches`

  2. **Libraries**
    a) amqp -> RabbitMQ client.(I also read about using `broadway_rabbitmq`.)
    b) redix -> Redis client.
    c) scrivener_ecto -> Pagination.

## APIs

  * `POST /api/data?topic=dielectrons`
  * `POST /api/data?topic=dielectrons&page=1&page_size=30`

  * `POST /api/data?topic=memes`
  * `POST /api/data?topic=memes&page=1&page_size=30`

  * `POST /api/data?topic=twitches`
  * `POST /api/data?topic=twitches&page=1&page_size=30`

