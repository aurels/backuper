def backup_profile(name)
  runner "Backuper.perform_profile('#{name}')"
end