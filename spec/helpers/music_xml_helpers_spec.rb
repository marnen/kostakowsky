require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../helpers/music_xml_helpers')
require 'faker'
require 'tmpdir'

describe MusicXmlHelpers do
  let(:host_class) { Class.new { include MusicXmlHelpers } }
  let(:helpers) { host_class.new }

  describe '#id' do
    let(:words) { Faker::Lorem.words(rand(3..10)) }
    let(:filename) { words.join('_') }

    it 'returns the last element of the filename' do
      expect(helpers.id filename).to be == words.last
    end

    it 'ignores extensions on the filename' do
      extension = Faker::File.extension
      expect(helpers.id "#{filename}.#{extension}").to be == words.last
    end
  end

  context 'XML parsing' do
    let(:partwise_headers) do
      strip_heredoc <<-"XML"
      <?xml version='1.0' encoding='utf-8'?>
      <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.0 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
      XML
    end

    let(:xml) do
      strip_heredoc <<-"XML"
        #{partwise_headers}
        <score-partwise>
          #{body}
        </score-partwise>
      XML
    end

    let(:tmpdir) { Dir.mktmpdir }
    let(:filename) { Faker::File.file_name tmpdir, nil, 'xml' }

    before(:each) { File.write filename, xml}
    after(:each) { FileUtils.remove_entry tmpdir }

    describe '#key' do
      let(:body) do
        strip_heredoc <<-"XML"
          <part-list><score-part id="P1"><part-name /></score-part></part-list>
          <part id="P1">
            <measure number="1">
              <attributes>
                <key>
                  <fifths>#{fifths}</fifths>
                  <mode>#{mode}</mode>
                </key>
              </attributes>
            </measure>
          </part>
        XML
      end
      subject { helpers.key filename }

      context 'major' do
        let(:mode) { 'major' }

        {
          -7 => 'Cb',
          -6 => 'Gb',
          -5 => 'Db',
          -4 => 'Ab',
          -3 => 'Eb',
          -2 => 'Bb',
          -1 => 'F',
          0 => 'C',
          1 => 'G',
          2 => 'D',
          3 => 'A',
          4 => 'E',
          5 => 'B',
          6 => 'F#',
          7 => 'C#'
        }.each do |fifths, key|
          context "#{fifths} fifth#{fifths == 1 ? nil : 's'}" do
            let(:fifths) { fifths }
            it { is_expected.to be == key }
          end
        end
      end
    end

    describe '#title' do
      let(:title) { Faker::Lorem.sentence }
      let(:subtitle) { Faker::Lorem.sentence }
      let(:body) do
        strip_heredoc <<-"XML"
          <work>
            <work-title>#{title}</work-title>
            #{subtitle ? "<work-number>#{subtitle}</work-number>" : ''}
          </work>
        XML
      end
      it 'returns the title of the score' do
        expect(helpers.title filename).to be == title
      end

      context ':full' do
        subject { helpers.title filename, full: true }

        it 'returns the title and subtitle' do
          expect(subject).to be == [title, subtitle].join(' ')
        end

        context 'no subtitle' do
          let(:subtitle) { nil }

          it 'just returns the title' do
            expect(subject).to be == title
          end
        end
      end
    end
  end

  private

  def strip_heredoc(string)
    indent = string.match(/^\s*/)[0]
    string.gsub /^#{indent}/, ''
  end
end
