function k7s -d 'My Kubernetes k9s wrapper'
  set K9S_CONFIG_DIR "/Users/louishuyng/Library/Application Support/k9s/skins"

  # Store current directory
  set current_dir (pwd)

  # Navigate to the k9s skins directory
  cd "$K9S_CONFIG_DIR"

  # Check if dark mode is enabled
  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"
    # Dark mode is enabled
    ln -sf skin-dark.yaml skin.yaml
  else
    # Light mode is enabled
    ln -sf skin-light.yaml skin.yaml
  end
  
  # Go back to the original directory
  cd "$current_dir"
  
  k9s $argv
end
