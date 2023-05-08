# Balance.jl

## Configuring
ENV config variables can be set in the `.env` file in run location

```sh
BALANCE_STORE="/home/myusername/.balance_jl"
```
## How to run

#### Add work item
`julia --project="." -e 'using Balance; log_hours()'

#### Print invoice to PDF
`julia --project="." -e 'using Balance; generate_invoice()'