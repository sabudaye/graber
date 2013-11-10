require 'spec_helper'

describe Graber do
  before do
    @graber = Graber.new
    @graber.stub(:get_extension).and_return('png')
    # TODO use fakefs
    @graber.make_dir('test')
    @graber.stub(:read_uri).and_return(open('spec/support/test.html').read)
  end

  after do
    FileUtils.rm_rf('test', secure: true)
  end

  it 'should make url' do
    expect(@graber.to_url("http://localhost.ru", "test").to_s =~ URI::regexp(%w(http https))).to be_true
  end

  it 'should make dir' do
    expect(Dir.exist?('test')).to be_true
  end

  it 'should open file' do
    @graber.should_receive(:open).with('http://localhost.ru/test.png').and_return('File succesfully saved')
    expect(@graber.download('http://localhost.ru/test.png', 'test')).to eq('File succesfully saved')
  end

  it 'should save file' do
    expect(@graber.save_file('test', 'http://localhost.ru/test.png',
      open('spec/support/test.png'))).to be_true
  end

  it 'should grab images' do
    @graber.stub(:download)
    expect(@graber.grab('http://localhost.ru','test')).to be_true
  end
end