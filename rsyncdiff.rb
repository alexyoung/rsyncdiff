#!/usr/bin/env ruby

# This script uses rsync to compare remote and local files.
# It will display new files that would have been uploaded
# and displays a diff for ones that have changes.

begin
  remote_path = ARGV[0] 
  path = ARGV[1]
  host, remote_path = remote_path.split(':')
  path = path + '/' if path[-1].chr != '/'
rescue
  puts "Provide two arguments: [remote path] [local path]\n\n"
  puts "For example:"
  puts "\trsyncdiff server:/u/apps/myapp/current/app app/"
  exit 1
end

def colorize(text, color_code)
  "#{color_code}#{text}#{27.chr}[0m"
end

def red(text); colorize(text, "#{27.chr}[31m"); end
def green(text); colorize(text, "#{27.chr}[32m"); end

def use_colordiff?
  not `which colordiff`.empty?
end

class RemoteChange
  attr_reader :file

  def initialize(string, file)
    @string = string
    @file = file
  end

  def to_s
    change_type = if new?
      "[#{green 'CREATE'}]"
    elsif include?('new')
      "[#{green 'CREATE'}] #{output.first}"
    elsif change?
      "[#{green 'UPDATE'}] #{output[1]}"
    elsif delete?
      "[#{red 'DELETE'}] #{output[1]}"
    end

    "#{change_type}\t#{@file}"
  end

  def new?
    include?('uploaded') and include?('new')
  end

  def change?
    include?('uploaded') and include?('size')
  end

  def delete?
    include? 'deleted'
  end

  def output
    @results ||= parse
  end

  def include?(item)
    output.include? item
  end

  def interesting_deletion?
    @string.match /^\*deleting/ and !@string.match /\.svn/
  end

  def parse
    return @results unless @results.nil?
    @string ||= ''

    @results = if interesting_deletion?
      ['deleted']
    else
      @string.split('').collect do |c|
        identify c
      end
    end
    @results.compact
  end

  def identify(c)
    case c
      when '<'
        'uploaded'
      when '>'
        'downloaded'
      when 'c'
        'local change/creation'
      when 'h'
        'hard link'
      when '*'
      when 'f'
        'file'
      when 'L'
        'symlink'
      when '+'
        'new'
      when '.'
        'no change'
      when 's'
        'size'
    end
  end
end

rsync_command = "rsync -rvv --itemize-changes --delete --dry-run #{path} #{host}:#{remote_path}"
rsync_output = %x(#{rsync_command})

items = {}
items[:creations] = []
items[:updates] = []
items[:deletions] = []

rsync_output.split("\n").each do |line|
  changes, file = line.gsub(/[ ]+/, ' ').split(' ')

  # ignore dot files
  next if file.nil? or file[0].chr == '.' or file.match('/\.')

  item = RemoteChange.new changes, file

  if item.change?
    items[:updates] << item
  elsif item.new?
    items[:creations] << item
  elsif item.delete?
    items[:deletions] << item
  end
end

items[:deletions].each do |item|
  puts item
end

puts

items[:creations].each do |item|
  puts item
end

puts

items[:updates].each do |item|
  puts item
  ssh_diff_command = "ssh #{host} cat \"#{File.join(remote_path, item.file)}\" | diff \"#{path}#{item.file}\" -"

  if use_colordiff?
    ssh_diff_command += ' | colordiff'
  end

  system(ssh_diff_command)
  puts
end
