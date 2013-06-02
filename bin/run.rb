#!/usr/bin/env ruby

require_relative '../config/settings'
require_relative '../lib/file_system_checker'
require 'net/smtp'

def run
  all_good = true

  SETTINGS.folders.each do |folder_path|
    unless Dir.exists?(folder_path) && (folder = Dir.new folder_path).entries.any?
      puts "[ NON EXISTING ] #{folder_path} - sending email alert"
      send_email_alert folder_path
      all_good = false
      next
    end

    paths = folder.entries.map{ |path| File.join folder, path }
    newest_child = paths.max_by{ |path| File.mtime(path) }
    all_good &= check_file(newest_child)
  end

  SETTINGS.files.each do |file|
    all_good &= check_file(file)
  end

  send_success_mail if all_good

end

def check_file(path)
  if !File.exists? path
    puts "[ NON EXISTING ] #{path} - sending email alert"
    send_email_alert(path)
    false
  elsif FileSystemChecker.check_file file: path, days: SETTINGS.max_days
    puts "[ OK ] #{path}"
    true
  else
    puts "[ OLD! ] #{path} - sending email alert"
    send_email_alert(path)
    false
  end
end

def send_email_alert(path)
  send_mail "Backup alert - #{path}", "There seems to be a problem with the backup at #{path}"
end

def send_success_mail
  send_mail 'Backup success', "All backups are good!"
end


def send_mail(subject, body)
  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start('gmail.com', 'lasseebert@gmail.com', ENV['LASSEEBERT_AT_GMAIL_PASSWORD'], :login) do
    smtp.send_message("Subject: #{subject}\n\n#{body}", 'lasseebert@gmail.com', 'lasseebert@gmail.com')
  end
end

run
