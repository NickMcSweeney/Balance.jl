function init_sync(url::String)
    current_path = pwd()
    cd(filedir)
    run(git(["init"]))
    run(git(["branch", "-m", "main"]))
    run(git(["remote", "add", "origin", url]))
    run(git(["add", "."]))
    run(git(["commit", "-m", "\"initial sync commit\""]))
    run(git(["push", "-u", "origin", "main"]))
    cd(current_path)
end

function push_changes(;note="backup data")
    current_path = pwd()
    cd(filedir)
    run(git(["add", "."]))
    run(git(["commit", "-m", "\"Balance_jl Auto Sync: $note\""]))
    run(git(["push", "-u", "origin", "main"]))
    cd(current_path)
end


function pull_changes()
    current_path = pwd()
    cd(filedir)
    run(git(["push", "-u", "origin", "main"]))
    cd(current_path)
end