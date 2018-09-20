require 'spec_helper'
require File.join(File.dirname(__FILE__), '../matchers/execute')
require File.join(File.dirname(__FILE__), '../../lib/muse_score')
require 'faker'

describe MuseScore do
  subject { MuseScore }
  let(:command) { MuseScore::COMMAND }
  let(:options) { MuseScore::OPTIONS }

  context 'method hiding' do
    [:sh, :shell].each do |method|
      it { is_expected.not_to respond_to method }
    end
  end

  describe '.call!' do
    let(:strings) { Faker::Lorem.words rand(1..5) }
    let(:call!) { MuseScore.call! *strings }

    it 'passes the strings to MuseScore, prepended with the command options' do
      expect(MuseScore).to execute command, *options, *strings
      call!
    end
  end

  describe '.convert!' do
    let(:call!) { MuseScore.convert! args }
    let(:expected_command_line) { [command, *options, *sh_params] }

    shared_examples 'style file argument' do
      context 'style' do
        let(:style_file) { Faker::File.file_name }
        let(:args) { super().merge style: style_file }
        let(:sh_params) { super().unshift '-S', style_file }

        it 'adds the style file to the command line' do
          expect(MuseScore).to execute *expected_command_line
          call!
        end
      end
    end

    context 'single file' do
      let(:from) { Faker::File.file_name }
      let(:to) { Faker::File.file_name }
      let(:args) { {from: from, to: to} }
      let(:sh_params) { ['-o', to, from] }

      context 'no style' do
        it 'calls MuseScore with the default options and specified filenames for conversion' do
          expect(MuseScore).to execute *expected_command_line
          call!
        end
      end

      include_examples 'style file argument'
    end

    context 'batch job' do
      let(:job_file) { Faker::File.file_name }
      let(:args) { {job: job_file} }
      let(:sh_params) { ['-j', job_file] }

      context 'no style' do
        it 'calls MuseScore with the default options and specified job file' do
          expect(MuseScore).to execute *expected_command_line
          call!
        end
      end

      include_examples 'style file argument'
    end

    context 'error conditions' do
      after(:each) { expect { call! }.to raise_error ArgumentError }

      context 'neither single file nor batch job' do
        let(:args) { {} }
        it('raises an error') { }
      end

      context 'both single file and batch job' do
        let(:args) { {from: Faker::File.file_name, to: Faker::File.file_name, job: Faker::File.file_name} }
        it('raises an error') { }
      end

      [:from, :to].each do |field|
        context "only :#{field}" do
          let(:args) { {"#{field}": Faker::File.file_name} }
          it('raises an error') { }
        end
      end
    end
  end

  describe 'OPTIONS' do
    it 'disables MIDI and synthesizer' do
      expect(MuseScore::OPTIONS).to match_array ['--no-midi', '--no-synthesizer']
    end
  end
end
