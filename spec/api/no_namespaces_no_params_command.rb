# frozen_string_literal: true

class NoNamespacesNoParamsCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def call
    true
  end
end
