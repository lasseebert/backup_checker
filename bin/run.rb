#!/usr/bin/env ruby

require_relative '../lib/file_system_checker'
require 'net/smtp'

MAX_DAYS = 1

def run
  folders = [
    '/home/pulver/backups/lasseebert-xps/hourly',
    '/home/pulver/backups/gmail/new',
    '/home/remote_backup/backups/barndomsfoto_backup',
    '/home/remote_backup/backups/hvidtfeldt_larsen',
    '/home/remote_backup/backups/madtavlen_backup',
    '/home/remote_backup/backups/skindstad_backup',
    '/home/remote_backup/backups/skindstadebert_backup'
  ]

  files = [
    '/home/pulver/backups/checkvist/checkvist_daily.tar.gz'
  ]

  all_good = true

  folders.each do |folder_path|
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

  files.each do |file|
    all_good &= check_file(file)
  end

  send_success_mail if all_good

end

def check_file(path)
  if !File.exists? path
    puts "[ NON EXISTING ] #{path} - sending email alert"
    send_email_alert(path)
    false
  elsif FileSystemChecker.check_file file: path, days: MAX_DAYS
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
