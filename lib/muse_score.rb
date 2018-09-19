require 'rake'

class MuseScore
  include FileUtils

  COMMAND = 'mscore'

  def initialize
    @defaults = ['--no-midi', '--no-synthesizer']
  end

  def call!(*args)
    sh COMMAND, *@defaults, *args
  end
end
