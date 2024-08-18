# frozen_string_literal: true

require_relative '../support/command_callable'

class NoNamespacesOneParamCommand
  prepend CommandCallable

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
