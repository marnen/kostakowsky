require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/muse_score')
require 'faker'

describe MuseScore do
  let(:command) { MuseScore::COMMAND }

  context 'instance methods' do
    let(:muse_score) { MuseScore.new }
    let(:options) { muse_score.options }

    describe '#call!' do
      let(:strings) { Faker::Lorem.words rand(1..5) }
      let(:call!) { muse_score.call! *strings }

      it 'passes the strings to MuseScore, prepended with the command options' do
        expect(muse_score).to receive(:sh).with command, *options, *strings
        call!
      end

      it 'disables MIDI' do
        expect(muse_score).to receive(:sh) {|*args| expect(args).to include '--no-midi' }
        call!
      end

      it 'disables the synthesizer' do
        expect(muse_score).to receive(:sh) {|*args| expect(args).to include '--no-synthesizer' }
        call!
      end
    end

    describe '#convert!' do
      let(:from) { Faker::File.file_name }
      let(:to) { Faker::File.file_name }
      let(:call!) { muse_score.convert! from: from, to: to }

      it 'calls MuseScore with the default options and specified filenames for conversion' do
        expect(muse_score).to receive(:sh).with command, *options, '-o', to, from
        call!
      end
    end

    describe '#options' do
      it 'disables MIDI and synthesizer' do
        expect(muse_score.options).to match_array ['--no-midi', '--no-synthesizer']
      end
    end
  end
end
