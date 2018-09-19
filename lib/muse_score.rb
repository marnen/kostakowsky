require 'rake'

class MuseScore
  include FileUtils

  COMMAND = 'mscore'

  def call!(*args)
    sh COMMAND, *options, *args
  end

  def convert!(from:, to:)
    sh COMMAND, *options, '-o', to, from
  end

  def options
    %w[--no-midi --no-synthesizer]
  end
end
