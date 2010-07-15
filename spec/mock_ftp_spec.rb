require 'spec_helper'

describe MockFTP do
  describe '#nlst' do
    it 'should list mocked files' do
      mock_ftp do |f|
        f.file 'file 1'
        f.file 'file 2'
        
        open_ftp do |ftp|
          ftp.nlst.should == [ 'file 1', 'file 2' ]
        end
      end
    end
    
    context 'within a folder' do
      it 'should list mocked files with prefixed folder name' do
        mock_ftp do |f|
          f.folder 'folder' do |f|
            f.file 'file 1'
            f.file 'file 2'
          end
          
          open_ftp do |ftp|
            ftp.nlst('/folder').should == [ '/folder/file 1', '/folder/file 2' ]
          end
        end
      end
    end
    
    context 'without a folder' do
      it 'should raise an error' do
        mock_ftp do |f|
          open_ftp do |ftp|
            expect {
              ftp.nlst('blah')
            }.to raise_error(Net::FTPPermError)
          end
        end
      end
    end
  end
end
