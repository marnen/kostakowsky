require 'grim'

desc 'Convert all tunes to all output formats'
task convert_tunes: ['build:pdf', 'build:screen_png']

namespace :build do
  source_files = Rake::FileList.new('source/tunes/**/*.xml')
  output_dir = ENV['OUTPUT_DIR'] || 'source'
  output_files = source_files.pathmap("%{^source,#{output_dir}}p")

  rule '.pdf' do |pdf|
    source = output_dir ? pdf.name.pathmap("%{^#{output_dir},source}X.xml") : pdf.name.ext('.xml')
    mkdir_p pdf.name.pathmap('%d')
    sh 'mscore', '-o', pdf.name, source
  end

  rule '.screen.png' => '.pdf' do |png|
    pdf = Grim.reap png.source
    pdf[0].save png.name
  end

  task screen_png: output_files.ext('.screen.png')
  task pdf: output_files.ext('.pdf')
end
