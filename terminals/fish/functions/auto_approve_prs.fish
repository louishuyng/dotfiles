function auto_approve_prs -d "auto approve the list PRs"
  for pr_url in (cat ~/Dev/auto_approve_prs.txt)
    echo "Approving PR: $pr_url"
    gh pr review $pr_url --approve
  end
end
