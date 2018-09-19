require 'chunky_png'
require 'grim'
require 'json'
require 'tmpdir'
require File.join File.dirname(__FILE__), 'lib/muse_score'
require 'middleman/firebase/tasks'

ALL_TUNES = 'source/tunes/**/*.mscx'
STYLE_FILE = 'source/default.mss'

desc 'Convert all tunes to all output formats'
task convert_tunes: 'build:all'

desc 'Update all tunes with default style'
task :update_style do
  Dir.mktmpdir do |tmp|
    job = Dir[ALL_TUNES].map {|tune| {in: tune, out: tune} }
    job_file = "#{tmp}/update_style.json"

    File.open job_file, mode: 'a' do |file|
      puts JSON.dump(job).inspect
      file.write JSON.dump job
    end
    MuseScore.convert! style: STYLE_FILE, job: job_file
  end
end

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
    MuseScore.convert! from: xml.source, to: xml.name, style: STYLE_FILE
  end

  rule '.mscz' => ->(mscz) { source_for mscz } do |mscz|
    mkdir_for mscz.name
    MuseScore.convert! from: mscz.source, to: mscz.name
  end

  rule '.pdf' => '.mscz' do |pdf|
    mkdir_for pdf.name
    MuseScore.convert! from: pdf.source, to: pdf.name
  end

  rule '.thumb.png' => '.pdf' do |png|
    Dir.mktmpdir do |tmp|
      tmp_name = "#{tmp}/page1.png"
      pdf = Grim.reap png.source
      pdf[0].save tmp_name, alpha: 'remove'
      screen = ChunkyPNG::Image.from_file tmp_name
      scale = 0.5
      crop_height = 135
      thumb = screen.resample((screen.width * scale).to_i, (screen.height * scale).to_i)
      thumb.crop! 0, 0, thumb.width, crop_height
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

  def source_for(filename, extension: '.mscx')
    filename.pathmap("%{^#{@output_dir},source}X#{extension}")
  end
end
