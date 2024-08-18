# frozen_string_literal: true

require_relative '../support/command_callable'

class NoNamespacesNoParamsCommand
  prepend CommandCallable

  def call
    true
  end
end
