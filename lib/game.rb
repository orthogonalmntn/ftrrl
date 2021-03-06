require "memoist"

module FasterThanLight
  class Game
    extend Memoist

    include Helpers::UserInput,
      Helpers::Display

    def initialize(ship)
      @ship = ship
      @map = Map.new
      @engineering_bay = EngineeringBay.new(@ship)
      @score = 0
    end

    def run!
      display_dashboard

      # main game loop
      loop do
        @ship.event!
        display_dashboard

        if game_result_check = game_over?
          puts game_result_check
          puts "Your score is: #{in_green calculated_user_score}"

          Operations::StoreUserScoreToDb.call(score: calculated_user_score, at_time: at_time_of_completion)
          scores = Operations::FetchHighScores.call(top: 5)
          display_high_scores scores
          break
        end

        nodes_to_check = [@ship.current_node_id] | @ship.next_nodes
        infected_nodes = Operations::CheckInfectedNodes.call(graph_id: @ship.graph_id, node_ids: nodes_to_check)
        puts in_red "YOU ARE ON AN INFECTED NODE" if infected_nodes.include?(@ship.current_node_id)

        @map.display_map(@ship.position, infected_nodes)

        input = get_user_input
        break if input == "quit"

        if input == "E"
          action_outcome = @engineering_bay.visit!
          @ship.handle_outcome(action_outcome)
          next
        end

        if input == "M"
          @map.display_entire_map(current_position: @ship.position)
          next
        end

        input = input.to_i
        @map.add_next_node(@ship.position, input)
        @ship.move_ship_to_new_position!(input)
        @score += 10
      end
    end

    private

    def game_over?
      if @ship.final_position? && !@ship.empty_fuel? && !@ship.destroyed?
        return in_green "Game won!"
      elsif @ship.empty_fuel? || @ship.destroyed? || @ship.final_position?
        return in_red "Game over! :-("
      end

      return false
    end

    def get_user_input
      get_input(
        phrase: "Which position to move to [1, 2, 3, 0 (Go Back), E (Engineering)]?",
        choices: ["0", "1", "2", "3", "E", "M", "quit"]
      )
    end

    def display_dashboard
      wrap_with_chars do
        puts in_light_blue "CURRENT POSITION: #{@ship.position}"
        print "FUEL: #{based_on_amount @ship.fuel} / "
        print "HEALTH: #{based_on_amount @ship.health} / "
        puts "SCRAP: #{based_on_amount @ship.scrap}"
      end
    end

    def display_high_scores(scores)
      puts "\nHIGH SCORES:"
      scores.each do |res|
        if res["score"] == calculated_user_score && res["created_at"] == at_time_of_completion
          puts "#{in_green res["score"]} | #{in_green res["created_at"]}"
        else
          puts "#{res["score"]} | #{res["created_at"]}"
        end
      end
    end

    memoize def at_time_of_completion
      Time.now.to_s
    end

    memoize def calculated_user_score
      final_score = @score +
        (@ship.scrap * 0.8) +
        (@ship.fuel > 0 ? @ship.fuel * 2 : 0) +
        (@ship.health > 0 ? @ship.health * 2 : 0)

      final_score.round(2)
    end

  end
end