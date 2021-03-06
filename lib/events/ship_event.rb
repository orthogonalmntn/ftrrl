module FasterThanLight
  module Events
    class ShipEvent < BaseEvent

      attr_reader :name, :description, :weapon, :engine, :health

      def initialize(name, description)
        @name = name
        @description = description
        @weapon = Components::Weapon.new # make random / more difficult down the tree
        @engine = Components::Engine.new # make random / more difficult down the tree
        @health = random(5)
      end

      def perform_event_actions(ship:)
        input = get_input(
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

    end
  end
end