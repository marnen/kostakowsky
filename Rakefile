require 'chunky_png'
require 'grim'

desc 'Convert all tunes to all output formats'
task convert_tunes: 'build:all'

namespace :build do
  task all: ['build:abc', 'build:pdf', 'build:thumbnail']

  source_files = Rake::FileList.new('source/tunes/**/*.xml')
  output_dir = ENV['OUTPUT_DIR'] || 'source'
  output_files = source_files.pathmap("%{^source,#{output_dir}}p")

  rule '.abc' do |abc|
    source = music_xml abc.name, output_dir
    Dir.mktmpdir do |tmp|
      sh 'xml2abc.py', '-o', tmp, source
      File.write abc.name, `iconv -f iso-8859-1 -t utf-8 '#{tmp}/#{File.basename abc.name}'`
    end
  end

  rule '.pdf' do |pdf|
    source = music_xml pdf.name, output_dir
    mkdir_p pdf.name.pathmap('%d')
    sh 'mscore', '-o', pdf.name, source
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

  task abc: output_files.ext('.abc')
  task pdf: output_files.ext('.pdf')
  task thumbnail: output_files.ext('.thumb.png')

  private

  def music_xml(filename, output_dir)
    filename.pathmap("%{^#{output_dir},source}X.xml")
  end
end
