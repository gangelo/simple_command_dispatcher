# frozen_string_literal: true

class NoNamespacesOneParamCommand
  prepend SimpleCommandDispatcher::Commands::CommandCallable

  def initialize(param)
    @param = param
  end

  def call
    execute
  end

  private

  attr_accessor :param

  def execute
    return true if param == :param

    errors.add :invalid_parameter, 'Parameter is invalid'

    nil
  end
end
