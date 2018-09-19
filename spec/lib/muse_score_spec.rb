require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/muse_score')
require 'faker'

describe MuseScore do
  describe 'constructor' do
    let(:filename) { Faker::File.file_name }

    it 'takes some strings and a hash' do
      expect(MuseScore.new '-o', filename, synthesizer: true).to be_a_kind_of MuseScore
    end

    it 'also works without the hash' do
      expect(MuseScore.new '-o', filename).to be_a_kind_of MuseScore
    end
  end

  describe '#call!' do
    let(:strings) { Faker::Lorem.words rand(1..5) }
    let(:muse_score) { MuseScore.new *strings }
    let(:call!) { muse_score.call! }

    it 'passes the strings to MuseScore, possibly with some other arguments before' do
      expect(muse_score).to receive(:sh).with MuseScore::COMMAND, any_args, *strings
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
end
