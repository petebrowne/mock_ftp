require 'spec_helper'

describe MockFTP do
  describe '#chdir' do
    it 'should change the current working directory' do
      mock_ftp do |f|
        f.folder 'folder' do |f|
          f.file 'file1'
          f.file 'file2'
        end
        
        open_ftp do |ftp|
          ftp.chdir('folder')
          ftp.nlst.should == %w( file1 file2 )
        end
      end
    end
    
    context 'within a folder' do
      it "should go back using '..'" do
        mock_ftp do |f|
          f.folder 'folder' do |f|
            f.file 'file 1'
            f.file 'file 2'
          end
          
          open_ftp do |ftp|
            ftp.chdir('folder')
            ftp.chdir('..')
            ftp.nlst.should == %w( folder )
          end
        end
      end
    end
    
    context 'without a folder' do
      it 'should raise an error' do
        mock_ftp do |f|
          open_ftp do |ftp|
            expect {
              ftp.chdir('blah')
            }.to raise_error(Net::FTPPermError, '550 blah: No such file or directory')
          end
        end
      end
    end
  end
  
  describe '#closed?' do
    context 'when the connection is open' do
      it 'should return false' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.should_not be_closed
          end
        end
      end
    end
    
    context 'when the connection is closed' do
      it 'should return true' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            ftp.should be_closed
          end
        end
      end
      
      it 'should raise an IOError when attempting to connect' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            expect {
              ftp.nlst
            }.to raise_error(IOError, 'closed stream')
          end
        end
      end
    end
  end
  
  describe '#login' do
    it 'should return a successful login message' do
      mock_ftp do |f|
        open_ftp do |ftp|
          ftp.login('username', 'password').strip.should == '230 User username logged in.'
        end
      end
    end
  end
  
  describe '#nlst' do
    it 'should list mocked files' do
      mock_ftp do |f|
        f.file 'file1'
        f.file 'file2'
        
        open_ftp do |ftp|
          ftp.nlst.should == %w( file1 file2 )
        end
      end
    end
    
    context 'within a folder' do
      it 'should list mocked files with prefixed folder name' do
        mock_ftp do |f|
          f.folder 'folder' do |f|
            f.file 'file1'
            f.file 'file2'
          end
          
          open_ftp do |ftp|
            ftp.nlst('/folder').should == %w( /folder/file1 /folder/file2 )
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
            }.to raise_error(Net::FTPPermError, '550 Directory not found')
          end
        end
      end
    end
  end
end
