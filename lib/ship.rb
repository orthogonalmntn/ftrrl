module FasterThanLight
  class Ship

    attr_reader :fuel, :health, :scrap, :weapon, :engine,
      :position, :graph_id, :current_node_id, :next_nodes,
      :event_producer

    def initialize(sector_graph:, graph_id:)
      @fuel = 10.0
      @health = 10
      @scrap = 10
      @weapon = Components::Weapon.new
      @engine = Components::Engine.new
      @current_node = sector_graph.start_node
      @previous_nodes = [@current_node]
      @graph_id = graph_id
      @event_producer = ::Events::Messaging::Producer.new
    end

    def move_ship_to_new_position!(input)
      return if final_position?

      if input == 0
        if first_position?
          puts "Can't go back any further!"
          return
        else
          # go back one node
          @current_node = @previous_nodes.last
          @previous_nodes -= [@previous_nodes.last]
        end
      else
        @previous_nodes << @current_node
        @current_node = @current_node.nodes[(input - 1)]
      end

      @fuel -= 1
      @fuel = @fuel.round(2)
    end

    def event!
      generate_event_if_necessary

      if event = @current_node.event
        event_response = event.resolve_event!(ship: self)
        handle_event_response(event_response)

        # destroy already-passed event:
        #   -> maybe we should allow some events to exist a while longer (e.g. planets?)
        @current_node.event = nil
      else
        puts "There seems to be nothing here."
      end
    end

    def position
      @current_node.position
    end

    def current_node_id
      @current_node.id
    end

    def next_nodes
      @current_node.nodes.map(&:id)
    end

    def final_position?
      @current_node.last?
    end

    def first_position?
      position == 1
    end

    def empty_fuel?
      @fuel <= 0
    end

    def destroyed?
      @health <= 0
    end

    def handle_event_response(event_response)
      return unless event_response

      @fuel += inc_based_on_engines(event_response.fuel_gain) if event_response.fuel_gain
      @fuel -= dec_based_on_engines(event_response.fuel_loss) if event_response.fuel_loss
      @fuel = @fuel.round(2)

      @scrap += event_response.scrap_gain if event_response.scrap_gain
      @scrap -= event_response.scrap_loss if event_response.scrap_loss

      @health += event_response.health_gain if event_response.health_gain
      @health -= event_response.ship_damage if event_response.ship_damage
    end
    alias_method :handle_outcome, :handle_event_response

    private

    def inc_based_on_engines(val)
      (val + val * (engine.str.to_f / 100)).round(3)
    end

    def dec_based_on_engines(val)
      val - val * (engine.str.to_f / 10)
    end

    def generate_event_if_necessary
      if @current_node.event.is_a?(String)
        real_event = @current_node.generator.send("generate_real_#{@current_node.event.downcase}")
        @current_node.event = real_event
      end
    end
  end
end
