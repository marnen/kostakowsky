require 'rake'

class MuseScore
  include FileUtils

  COMMAND = 'mscore'

  def initialize(*args)
    @args = args
  end

  def call!
    sh COMMAND, '--no-midi', '--no-synthesizer', *@args
  end
end
