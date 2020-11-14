# frozen_string_literal: true

require 'spec_helper'

# require 'rollbar'
module Rollbar
end

RSpec.describe Stoplight::Notifier::Rollbar do
  it 'is a class' do
    expect(described_class).to be_a(Class)
  end

  it 'is a subclass of Base' do
    expect(described_class).to be < Stoplight::Notifier::Base
  end

  describe '#formatter' do
    it 'is initially the default' do
      expect(described_class.new(nil, nil).formatter)
        .to eql(Stoplight::Default::FORMATTER)
    end

    it 'reads the formatter' do
      formatter = proc {}
      expect(described_class.new(nil, formatter).formatter)
        .to eql(formatter)
    end
  end

  describe '#options' do
    it 'is initially the default' do
      expect(described_class.new(nil, nil).options)
        .to eql(Stoplight::Notifier::Rollbar::DEFAULT_OPTIONS)
    end

    it 'reads the options' do
      options = { key: :value }
      expect(described_class.new(nil, nil, options).options)
        .to eql(Stoplight::Notifier::Rollbar::DEFAULT_OPTIONS.merge(options))
    end
  end

  describe '#rollbar' do
    it 'reads the Rollbar client' do
      client = Rollbar
      expect(described_class.new(client, nil).rollbar)
        .to eql(client)
    end
  end

  describe '#notify' do
    let(:light) { Stoplight::Light.new(name, &code) }
    let(:name) { ('a'..'z').to_a.shuffle.join }
    let(:code) { -> {} }
    let(:from_color) { Stoplight::Color::GREEN }
    let(:to_color) { Stoplight::Color::RED }
    let(:notifier) { described_class.new(rollbar) }
    let(:rollbar) { Rollbar }

    subject(:result) do
      notifier.notify(light, from_color, to_color, error)
    end

    before do
      status_change = described_class::StoplightStatusChange.new(message)
      expect(rollbar).to receive(:info).with(status_change)
    end

    context 'when no error given' do
      let(:error) { nil }

      it 'logs message' do
        expect(result).to eq(message)
      end
    end

    context 'when message with an error given' do
      let(:error) { ZeroDivisionError.new('divided by 0') }

      it 'logs message' do
        expect(result).to eq(message)
      end
    end

    def message
      notifier.formatter.call(light, from_color, to_color, error)
    end
  end
end
