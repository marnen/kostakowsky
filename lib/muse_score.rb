require 'rake'

class MuseScore
  include FileUtils

  COMMAND = 'mscore'

  def call!(*args)
    sh COMMAND, *options, *args
  end

  def convert!(from: nil, to: nil, job: nil, style: nil)
    filenames = [job, from, to]
    raise ArgumentError, 'Either :job or (:from and :to) is required' if filenames.compact.empty?
    raise ArgumentError, 'Either :job or (:from and :to) may be given, not both' if filenames.none?(&:nil?)
    raise ArgumentError, ':from and :to are both required, unless :job is given' if from.nil? != to.nil?

    params = job ? ['-j', job] : ['-o', to, from]
    params.unshift('-S', style) if style
    sh COMMAND, *options, *params
  end

  def options
    %w[--no-midi --no-synthesizer]
  end
end
