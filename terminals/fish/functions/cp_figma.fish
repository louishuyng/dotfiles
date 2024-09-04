function cp_figma -d "Copy Figma Resources to Target Folder"
  set -l target_folder $argv[1]

  mv ~/Downloads/Figma\ Resources/* $target_folder
end
