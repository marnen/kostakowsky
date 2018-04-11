require 'chunky_png'
require 'grim'
require 'tmpdir'

ALL_TUNES = 'source/tunes/**/*.mscx'

desc 'Convert all tunes to all output formats'
task convert_tunes: 'build:all'

task :guard, [:paths] do |_, args|
  paths = Array(args.paths) - ['Rakefile']
  @source_files = Rake::FileList.new(paths.empty? ? ALL_TUNES : paths)
  Rake::Task['convert_tunes'].invoke
end

namespace :build do
  task all: [:mscz, :musicxml, :abc, :pdf, :thumbnail]

  task :set_files do
    @source_files ||= Rake::FileList.new(ALL_TUNES)
    @output_dir = ENV['OUTPUT_DIR'] || 'source'
    @output_files = @source_files.pathmap("%{^source,#{@output_dir}}p")
  end

  rule '.abc' => '.xml' do |abc|
    Dir.mktmpdir do |tmp|
      sh 'xml2abc.py', '-o', tmp, abc.source
      File.write abc.name, `iconv -f iso-8859-1 -t utf-8 '#{tmp}/#{File.basename abc.name}'`
    end
  end

  rule '.xml' => '.mscz' do |xml|
    mkdir_for xml.name
    muse_score '-S', 'source/default.mss', '-o', xml.name, xml.source
  end

  rule '.mscz' => ->(mscz) { source_for mscz } do |mscz|
    mkdir_for mscz.name
    muse_score '-o', mscz.name, mscz.source
  end

  rule '.pdf' => '.mscz' do |pdf|
    mkdir_for pdf.name
    muse_score '-o', pdf.name, pdf.source
  end

  rule '.thumb.png' => '.pdf' do |png|
    Dir.mktmpdir do |tmp|
      tmp_name = "#{tmp}/page1.png"
      pdf = Grim.reap png.source
      pdf[0].save tmp_name
      screen = ChunkyPNG::Image.from_file tmp_name
      scale = 0.5
      thumb = screen.resample((screen.width * scale).to_i, (screen.height * scale).to_i)
      thumb.save png.name
    end
  end

  {
    abc: '.abc',
    musicxml: '.xml',
    mscz: '.mscz',
    pdf: '.pdf',
    thumbnail: '.thumb.png'
  }.each do |name, extension|
    task(name => :set_files) do
      @output_files.ext(extension).each {|file| Rake::Task[file].invoke }
    end
  end

  private

  def mkdir_for(filename)
    mkdir_p filename.pathmap('%d')
  end

  def muse_score(*args, synthesizer: false, midi: false)
    defaults = [:synthesizer, :midi].map do |option|
      binding.local_variable_get(option) ? nil : "--no-#{option}"
    end.compact
    sh 'mscore', *defaults, *args
  end

  def source_for(filename, extension: '.mscx')
    filename.pathmap("%{^#{@output_dir},source}X#{extension}")
  end
end
