require 'spec_helper'

describe FasterThanLight::Game do
  let!(:graph) { FasterThanLight::Graph::Graph.new }
  let!(:ship) { FasterThanLight::Ship.new(sector_graph: graph, graph_id: 123) }

  describe ".run!" do
    it "runs the game" do
      # described_class.new(ship).run!
    end
  end

end
