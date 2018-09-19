require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/muse_score')
require 'faker'

describe MuseScore do
  let(:command) { MuseScore::COMMAND }

  context 'instance methods' do
    let(:muse_score) { MuseScore.new }

    describe '#call!' do
      let(:strings) { Faker::Lorem.words rand(1..5) }
      let(:call!) { muse_score.call! *strings }

      it 'passes the strings to MuseScore, possibly with some other arguments before' do
        expect(muse_score).to receive(:sh).with command, any_args, *strings
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
end
