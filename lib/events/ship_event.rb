module FasterThanLight
  module Events
    class ShipEvent < BaseEvent

      include Helpers::Math

      attr_reader :name, :description, :weapon, :engine, :health

      def initialize
        @name = generate_name
        @description = generate_description
        @weapon = Components::Weapon.new(weapon_type: "Torpedo", weapon_str: random(3))
        @engine = Components::Engine.new(engine_type: "Nuclear", engine_str: random(5))
        @health = random(5)
      end

      def perform_event_actions(ship:)
        input = display(
          phrase: "Fight or avoid?",
          choices: ["F", "A"],
        )

        outcome = case input
                  when "F"
                    ActionResolvers::CombatResolver.call(ship: ship, event: self)
                  when "A"
                    ActionResolvers::AvoidanceResolver.call(ship: ship, event: self)
                  end

        EventResponse.new(ship_damage: outcome.ship_damage, fuel_loss: outcome.fuel_loss, scrap_gain: outcome.scrap_gain)
      end

      private

      def generate_name
        names = [
          'Galactica',
          'Zembulon',
          'Antiqon'
        ]

        names[rand(names.length)]
      end

      def generate_description
        descriptions = [
          'A big sturdy ship with gleaming weapons aimed at you',
          'Stealthy bomber from an unknown sector',
          'Small but dangerous-looking spacecraft'
        ]

        descriptions[rand(descriptions.length)]
      end

    end
  end
end