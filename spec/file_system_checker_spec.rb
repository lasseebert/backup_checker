require 'spec_helper'

describe FileSystemChecker do

  let(:tmp_folder) { File.join(__dir__, '..', 'tmp') }
  let(:old_time) { Time.now - 14*24*60*60 } # 14 days

  describe 'check_folder' do

    let(:new_folder_path) { dir = File.join(tmp_folder, 'new_folder') ; FileUtils.mkdir_p dir ; FileUtils.touch dir ; dir }
    let(:old_folder_path) { dir = File.join(tmp_folder, 'old_folder') ; FileUtils.mkdir_p dir ; File.utime old_time, old_time, dir ; dir }

    subject { FileSystemChecker.check_folder(folder: folder, days: 7) }

    context 'when folder is new' do
      let(:folder) { new_folder_path }
      it { should be_true }
    end

    context 'when folder is old' do
      let(:folder) { old_folder_path }
      it { should be_false }
    end

    context 'when folder is non-existing' do
      let(:folder) { "foo" }
      it { should be_false }
    end

  end

  describe 'check_file' do

    let(:new_file_path) { file = File.join(tmp_folder, 'new_file') ; FileUtils.mkdir_p tmp_folder ; FileUtils.touch file ; file }
    let(:old_file_path) { file = File.join(tmp_folder, 'old_file') ; FileUtils.mkdir_p tmp_folder ; FileUtils.touch file ; File.utime old_time, old_time, file ; file }

    subject { FileSystemChecker.check_file(file: file, days: 7) }

    context 'when file is new' do
      let(:file) { new_file_path }
      it { should be_true }
    end

    context 'when file is old' do
      let(:file) { old_file_path }
      it { should be_false }
    end

    context 'when file is non-existing' do
      let(:file) { "foo" }
      it { should be_false }
    end

  end
end
