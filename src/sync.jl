function init_sync(url::String)
    const current_path = pwd()
    const git = Git.git()
    cd(filedir)
    run(git(["init"]))
    run(git(["branch", "-m", "main"]))
    run(git(["remote", "add", "origin", url]))
    run(git(["add", "."]))
    run(git(["commit", "-m", "\"initial sync commit\""]))
    run(git(["push", "-u", "origin", "main"]))
    cd(current_path)
end

function push_changes()
    const current_path = pwd()
    cd(filedir)
    run(git(["add", "."]))
    run(git(["commit", "-m", "\"backup data\""]))
    run(git(["push", "-u", "origin", "main"]))
    cd(current_path)
end


function pull_changes()
    const current_path = pwd()
    cd(filedir)
    run(git(["push", "-u", "origin", "main"]))
    cd(current_path)
end