desc 'Convert all tunes to all output formats'
task convert_tunes: 'build:pdf'

namespace :build do
  source_files = Rake::FileList.new('source/tunes/**/*.xml')
  output_dir = ENV['OUTPUT_DIR'] || 'source'

  rule '.pdf' do |pdf|
    source = output_dir ? pdf.name.pathmap("%{^#{output_dir},source}X.xml") : pdf.name.ext('.xml')
    mkdir_p pdf.name.pathmap('%d')
    sh 'mscore', '-o', pdf.name, source
  end

  task pdf: source_files.ext('.pdf').pathmap("%{^source,#{output_dir}}p")
end
