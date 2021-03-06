# Faster Than (Ruby-Refracted) Light

Faster Than (Ruby-Refracted) Light is a textual space adventure game written in Ruby.

The player is at the helm of a ship and roams a randomly-generated galactic sector, whose planets, enemy ships, and service shops are generated by pre-trained ML language models, all while trying to avoid a star plague spreading in the background.

The ML generated content ensures that every play session is unique, and the ML models are all swappable in the background, making for a highly-customizable experience.

## Running the Game

The game is composed of three separate components. At the center of it all, is a Ruby application (the game itself), which is acompanied by two additional services:

- a [Python Generator](https://github.com/orthogonalmntn/generator_service) for original game content with pre-trained ML language models
- a [Rack+Grape app](https://github.com/orthogonalmntn/stats-service) which consumes game events and gathers statistics about each play session

Both services are optional, but make for a better experience.

### Setting up

Set up your env vars:

`cp .env.dev .env`

Start the game:

`ruby faster_than_light.rb`

### Background Work

Start Sidekiq: `bundle exec sidekiq -r ./lib/workers/star_plague_worker.rb`

Make sure that MongoDB is running locally and configured properly in the dotenv file.

To clear all queues from Ruby:

`Sidekiq::Queue.all.each &:clear`

## How to Play

The player controls a ship, which has upgradable weapons and engines, and jumps from node to node in a world graph.

At each node, the player may encounter one of three game "events":

- Planets
- Enemy Ships
- Service Shop

Planets are explorable and can be mined for resources, Enemy Ships can be avoided or fought, and Service Shops are a place to buy fuel or repair ship.

When the player has gathered enough resources, they can go into the Engineering Bay, and upgrade components of the ship. Better weapons lead to winning more fights with enemy ships, and better engines result in lower fuel consumption.

At each node in the game world, the player has the option to chose to move to one of three child nodes. They could also go back and pursue a different path. A map is always available for consultation.

The game is lost when the ship is destroyed. The game is won when the player reaches the end of the galaxy sector (10th level).

High scores are calculated at the end of the game and displayed to the player.

## Additional Notes

### Components Needed

- Redis is required for Sidekiq
- MongoDB is the database used to store the game graph and high scores
- RabbitMQ is the message broker the game uses to publish game events, consumed by the StatsService

## License

*This is a hobby project and an exploration in building Ruby + ML systems, and it's meant for non-commerical, educational purposes only!*