require 'spec_helper'

describe Oober::CefLogger do
  let(:spec_taxii) {'spec/fixtures/spec-taxii.json'}
  let(:spec_cef)   {'spec/fixtures/spec-cef.json'}
  context 'intializing instances' do
    describe '.intialize' do
      it 'returns an instance when cef and taxii configs are supplied' do
        oob=Oober::CefLogger.new(cef_config: spec_cef, taxii_config: spec_taxii)
        expect(oob).to be_a(Oober::CefLogger)
      end
      it 'raises an error if no cef config is supplied' do
        expect{ Oober::CefLogger.new(taxii_config: spec_taxii)}.to raise_error(
          ArgumentError, /The property 'cef_config' needs to point to a valid/ )
      end
      it 'raises an error if no taxii config is supplied' do
        expect{ Oober::CefLogger.new(cef_config: spec_cef)}.to raise_error(
          ArgumentError, /The property 'taxii_config' needs to point to a valid/ )
      end
    end
  end
  context 'accessing embedded clients' do
    let(:oob) { Oober::CefLogger.new(cef_config: spec_cef, taxii_config: spec_taxii)}
    describe '#cef' do
      it 'memoizes an instance of a CEF Logger' do
        expect(oob.cef).to be_a(CEF::Loggers::SyslogUdp)
      end
    end
    describe '#taxii' do
      it 'memoizes an instance of a Taxii::PollClient' do
        expect(oob.taxii).to be_a(Taxii::PollClient)
      end
    end
  end
end
