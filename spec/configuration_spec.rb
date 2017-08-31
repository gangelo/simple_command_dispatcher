require "spec_helper"

describe SimpleCommand::Dispatcher do
	before(:each) do
		SimpleCommand::Dispatcher.configuration.reset
	end

	context "configuration" do
		describe "#allow_custom_commands=" do
			it "should use simple commands by default" do
				result = SimpleCommand::Dispatcher.configuration.allow_custom_commands
				expect(result).to eq(false)
			end

			it "should be able to use custom commands" do
		   	SimpleCommand::Dispatcher.configure do |config|
		     		config.allow_custom_commands = true
		   	end
				result = SimpleCommand::Dispatcher.configuration.allow_custom_commands
				expect(result).to eq(true)
			end

			it "should be able to use simple commands" do
		   	SimpleCommand::Dispatcher.configure do |config|
		     		config.allow_custom_commands = false
		   	end
				result = SimpleCommand::Dispatcher.configuration.allow_custom_commands
				expect(result).to eq(false)
			end
		end

		describe "#reset" do
			it "should be able to reset to use simple commands" do
				SimpleCommand::Dispatcher.configure do |config|
		     		config.allow_custom_commands = true
		   	end
				SimpleCommand::Dispatcher.configuration.reset
				result = SimpleCommand::Dispatcher.configuration.allow_custom_commands
				expect(result).to eq(false)
			end
		end
	end
end