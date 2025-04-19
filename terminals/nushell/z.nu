def "nu-complete zoxide path" [context: string] {
  let parts = $context | split row " " | skip 1
  {
    options: {
      sort: false
      completion_algorithm: prefix
      positional: false
      case_sensitive: false
    }
    completions: (zoxide query --list --exclude $env.PWD -- ...$parts | lines)
  }
}

def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
  __zoxide_z ...$rest
}
