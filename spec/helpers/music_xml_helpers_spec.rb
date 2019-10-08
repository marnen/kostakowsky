require 'spec_helper'
require_relative '../../helpers/music_xml_helpers'
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
      let(:key) do
        strip_heredoc <<-"XML"
          <key>
            <fifths>#{fifths}</fifths>
            <mode>#{mode}</mode>
          </key>
        XML
      end

      let(:body) do
        strip_heredoc <<-"XML"
          <part-list><score-part id="P1"><part-name /></score-part></part-list>
          <part id="P1">
            <measure number="1">
              <attributes>
                #{key}
              </attributes>
            </measure>
          </part>
        XML
      end
      subject { helpers.key filename }

      context 'major' do
        let(:mode) { 'major' }

        {
          -7 => 'C♭',
          -6 => 'G♭',
          -5 => 'D♭',
          -4 => 'A♭',
          -3 => 'E♭',
          -2 => 'B♭',
          -1 => 'F',
          0 => 'C',
          1 => 'G',
          2 => 'D',
          3 => 'A',
          4 => 'E',
          5 => 'B',
          6 => 'F♯',
          7 => 'C♯'
        }.each do |fifths, key|
          context "#{fifths} fifth#{fifths == 1 ? nil : 's'}" do
            let(:fifths) { fifths }
            it { is_expected.to be == key }
          end
        end

        context 'null mode' do
          let(:key) { "<key><fifths>2</fifths></key>" }

          it 'is treated as major' do
            expect(subject).to be == 'D'
          end
        end
      end

      context 'minor' do
        let(:mode) { 'minor' }

        {
          -7 => 'A♭',
          -6 => 'E♭',
          -5 => 'B♭',
          -4 => 'F',
          -3 => 'C',
          -2 => 'G',
          -1 => 'D',
          0 => 'A',
          1 => 'E',
          2 => 'B',
          3 => 'F♯',
          4 => 'C♯',
          5 => 'G♯',
          6 => 'D♯',
          7 => 'A♯'
        }.each do |fifths, key|
          context "#{fifths} fifth#{fifths == 1 ? nil : 's'}" do
            let(:fifths) { fifths }
            it { is_expected.to be == "#{key}m" }
          end
        end
      end

      context 'dorian' do
        let(:mode) { 'dorian' }

        {
          -7 => 'D♭',
          -6 => 'A♭',
          -5 => 'E♭',
          -4 => 'B♭',
          -3 => 'F',
          -2 => 'C',
          -1 => 'G',
          0 => 'D',
          1 => 'A',
          2 => 'E',
          3 => 'B',
          4 => 'F♯',
          5 => 'C♯',
          6 => 'G♯',
          7 => 'D♯'
        }.each do |fifths, key|
          context "#{fifths} fifth#{fifths == 1 ? nil : 's'}" do
            let(:fifths) { fifths }
            it { is_expected.to be == "#{key}dor" }
          end
        end
      end

      context 'mixolydian' do
        let(:mode) { 'mixolydian' }

        {
          -7 => 'G♭',
          -6 => 'D♭',
          -5 => 'A♭',
          -4 => 'E♭',
          -3 => 'B♭',
          -2 => 'F',
          -1 => 'C',
          0 => 'G',
          1 => 'D',
          2 => 'A',
          3 => 'E',
          4 => 'B',
          5 => 'F♯',
          6 => 'C♯',
          7 => 'G♯'
        }.each do |fifths, key|
          context "#{fifths} fifth#{fifths == 1 ? nil : 's'}" do
            let(:fifths) { fifths }
            it { is_expected.to be == "#{key}mix" }
          end
        end
      end

      context 'multiple keys' do
        let(:body) do
          strip_heredoc <<-"XML"
            <part-list><score-part id="P1"><part-name /></score-part></part-list>
            <part id="P1">
              <measure number="1">
                <attributes>
                  <key>
                    <fifths>0</fifths>
                    <mode>major</mode>
                  </key>
                </attributes>
              </measure>
              <measure number="2">
                <attributes>
                  <key>
                    <fifths>3</fifths>
                    <mode>minor</mode>
                  </key>
                </attributes>
              </measure>
            </part>
          XML
        end

        it 'returns all key names, comma-separated' do
          expect(subject).to be == 'C, F♯m'
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
