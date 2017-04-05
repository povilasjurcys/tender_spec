class TransactionalFile
  attr_reader :original_content, :file_path

  def initialize(file_path)
    @original_content = File.read(file_path)
    @file_path = file_path
  end

  def read
    File.read(file_path)
  end

  def write(content)
    File.write(file_path, content)
  end

  def sub(*args)
    write(read.sub(*args))
  end

  def restore
    write(original_content)
  end
end

def file_with_transaction(file_path)
  file = TransactionalFile.new(file_path)
  begin
    yield(file)
  ensure
    file.restore
  end
end
