# Balance.jl

## Configuring
ENV config variables can be set in the `.env` file in run location

```sh
BALANCE_STORE="/home/myusername/.balance_jl"
```
## How to run

#### Add work item

`julia --project="." -e 'using Balance; log_hours()`

#### Print invoice to PDF

`julia --project="." -e 'using Balance; export_invoice()`

#### WIP: setup sync with git

`julia --project="." -e 'using Balance; init_sync("https://git_url_for_balance_files.git")`

#### TODO: sync using git

`julia --project="." -e 'using Balance; sync_balance()`