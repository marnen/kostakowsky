require 'chunky_png'
require 'grim'

desc 'Convert all tunes to all output formats'
task convert_tunes: ['build:pdf', 'build:thumbnail']

namespace :build do
  source_files = Rake::FileList.new('source/tunes/**/*.xml')
  output_dir = ENV['OUTPUT_DIR'] || 'source'
  output_files = source_files.pathmap("%{^source,#{output_dir}}p")

  rule '.pdf' do |pdf|
    source = output_dir ? pdf.name.pathmap("%{^#{output_dir},source}X.xml") : pdf.name.ext('.xml')
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

  task thumbnail: output_files.ext('.thumb.png')
  task pdf: output_files.ext('.pdf')
end
