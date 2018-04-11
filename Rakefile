require 'chunky_png'
require 'grim'
require 'tmpdir'

ALL_XML = 'source/tunes/**/*.musicxml'

desc 'Convert all tunes to all output formats'
task convert_tunes: 'build:all'

task :guard, [:paths] do |_, args|
  paths = Array(args.paths) - ['Rakefile']
  @source_files = Rake::FileList.new(paths.empty? ? ALL_XML : paths)
  Rake::Task['convert_tunes'].invoke
end

namespace :build do
  task all: [:abc, :pdf, :thumbnail]

  task :set_files do
    @source_files ||= Rake::FileList.new(ALL_XML)
    @output_dir = ENV['OUTPUT_DIR'] || 'source'
    @output_files = @source_files.pathmap("%{^source,#{@output_dir}}p")
  end

  rule '.abc' => ->(abc) { music_xml abc } do |abc|
    puts abc.name
    Dir.mktmpdir do |tmp|
      sh 'xml2abc.py', '-o', tmp, abc.source
      File.write abc.name, `iconv -f iso-8859-1 -t utf-8 '#{tmp}/#{File.basename abc.name}'`
    end
  end

  rule '.pdf' => ->(pdf) { music_xml pdf } do |pdf|
    puts pdf.name
    mkdir_p pdf.name.pathmap('%d')
    sh 'mscore', '-S', 'source/default.mss', '-o', pdf.name, pdf.source
  end

  rule '.thumb.png' => '.pdf' do |png|
    puts png.name
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

  task(abc: :set_files) { puts @output_files.inspect; @output_files.ext('.abc').each {|file| Rake::FileTask[file].invoke } }
  task(pdf: :set_files) { @output_files.ext('.pdf').each {|file| Rake::FileTask[file].invoke } }
  task(thumbnail: :set_files) { @output_files.ext('.thumb.png').each {|file| Rake::FileTask[file].invoke } }

  private

  def method_name

  end

  def music_xml(filename)
    filename.pathmap("%{^#{@output_dir},source}X.musicxml")
  end
end
