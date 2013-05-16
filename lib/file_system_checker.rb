class FileSystemChecker

  def self.check_file(options = {})
    file = options.fetch(:file, ".")
    days = options.fetch(:days, 14)
    return false unless File.exists?(file)
    File.mtime(file) > Time.now - days*24*3600
  end

  def self.check_folder(options = {})
    # This just copies to check_file
    options[:file] = options[:folder]
    options[:folder] = nil
    check_file options
  end

end
