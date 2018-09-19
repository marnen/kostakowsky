require 'rake'

class MuseScore
  include FileUtils

  COMMAND = 'mscore'

  def call!(*args)
    sh COMMAND, *options, *args
  end

  def convert!(from:, to:, style: nil)
    params = ['-o', to, from]
    params.unshift('-S', style) if style
    sh COMMAND, *options, *params
  end

  def options
    %w[--no-midi --no-synthesizer]
  end
end
