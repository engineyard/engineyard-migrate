module AppcloudRestoreFolder
  # In scenarios like 'I remove AppCloud application "my_app_name" folder'
  # a folder is removed from AppCloud; but it is required for all other scenarios
  # unless explicitly deleted
  # This helper ensures that the folder is restored
  def remove_from_appcloud(path, environment)
    @stdout  = File.expand_path(File.join(@tmp_root, "eyssh.remove.out"))
    @stderr  = File.expand_path(File.join(@tmp_root, "eyssh.remove.err"))
    path     = path.gsub(%r{/$}, '')
    path_tmp = "#{path}.tmp"
    @restore_paths ||= []
    @restore_paths << [path_tmp, path, environment]
    cmd = "mv #{Escape.shell_command(path)} #{Escape.shell_command(path_tmp)}"
    system "ey ssh #{Escape.shell_command(cmd)} -e #{environment} > #{@stdout.inspect} 2> #{@stderr.inspect}"
  end
end
World(AppcloudRestoreFolder)

After do
  if @restore_paths
    @restore_paths.each do |path_tmp, path, environment|
      cmd = "mv #{Escape.shell_command(path_tmp)} #{Escape.shell_command(path)}"
      system "ey ssh #{Escape.shell_command(cmd)} -e #{environment} > #{@stdout.inspect} 2> #{@stderr.inspect}"
    end
  end
end