require 'rake'

module MuseScore
  COMMAND = 'mscore'
  OPTIONS = %w[--no-midi --no-synthesizer]

  class << self
    def call!(*args)
      shell COMMAND, *OPTIONS, *args
    end

    def convert!(from: nil, to: nil, job: nil, style: nil)
      filenames = [job, from, to]
      raise ArgumentError, 'Either :job or (:from and :to) is required' if filenames.compact.empty?
      raise ArgumentError, 'Either :job or (:from and :to) may be given, not both' if filenames.none?(&:nil?)
      raise ArgumentError, ':from and :to are both required, unless :job is given' if from.nil? != to.nil?

      params = job ? ['-j', job] : ['-o', to, from]
      params.unshift('-S', style) if style
      call! *params
    end

    private

    def shell(*args)
      @shell ||= Class.new { include FileUtils }.new
      @shell.sh *args
    end
  end
end
