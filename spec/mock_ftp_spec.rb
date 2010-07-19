require 'spec_helper'

describe MockFTP do
  describe '#abort' do
    it 'should be successful' do
      mock_ftp do |f|
        open_ftp do |ftp|
          ftp.abort.should == "226 Abort successful\n"
        end
      end
    end
      
    context 'when the connection is closed' do
      it 'should raise an IOError' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            expect {
              ftp.abort
            }.to raise_error(IOError, 'closed stream')
          end
        end
      end
    end
  end
  
  describe '#chdir' do
    it 'should change the current working directory' do
      mock_ftp do |f|
        f.folder 'folder' do |f|
          f.file 'file1'
          f.file 'file2'
        end
        
        open_ftp do |ftp|
          ftp.chdir 'folder'
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
            ftp.chdir 'folder'
            ftp.chdir '..'
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
              ftp.chdir 'blah'
            }.to raise_error(Net::FTPPermError, '550 blah: No such file or directory')
          end
        end
      end
    end
      
    context 'when the connection is closed' do
      it 'should raise an IOError' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            expect {
              ftp.chdir '..'
            }.to raise_error(IOError, 'closed stream')
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
    end
  end
  
  describe '#connect' do
    it 'should return nil' do
      mock_ftp do |f|
        open_ftp do |ftp|
          ftp.connect('hostname', 100).should be_nil
        end
      end
    end
  end
  
  describe '#login' do
    it 'should return a successful login message' do
      mock_ftp do |f|
        open_ftp do |ftp|
          ftp.login('username', 'password').should == "230 User username logged in.\n"
        end
      end
    end
      
    context 'when the connection is closed' do
      it 'should raise an IOError' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            expect {
              ftp.login 'username', 'password'
            }.to raise_error(IOError, 'closed stream')
          end
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
              ftp.nlst 'blah'
            }.to raise_error(Net::FTPPermError, '550 Directory not found')
          end
        end
      end
    end
      
    context 'when the connection is closed' do
      it 'should raise an IOError' do
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
  
  describe '#noop' do
    it 'should return nil' do
      mock_ftp do |f|
        open_ftp do |ftp|
          ftp.noop.should be_nil
        end
      end
    end
      
    context 'when the connection is closed' do
      it 'should raise an IOError' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            expect {
              ftp.noop
            }.to raise_error(IOError, 'closed stream')
          end
        end
      end
    end
  end
  
  describe '#pwd' do
    it 'should return the current path' do
      mock_ftp do |f|
        f.folder 'folder'
        
        open_ftp do |ftp|
          ftp.chdir 'folder'
          ftp.pwd.should == '/folder'
        end
      end
    end
    
    context 'in the root directory' do
      it "should return '/'" do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.pwd.should == '/'
          end
        end
      end
    end
      
    context 'when the connection is closed' do
      it 'should raise an IOError' do
        mock_ftp do |f|
          open_ftp do |ftp|
            ftp.close
            expect {
              ftp.pwd
            }.to raise_error(IOError, 'closed stream')
          end
        end
      end
    end
  end
end
