module Balance
using DotEnv
using Dates, UUIDs
using Crayons, TerminalMenus, ImageInTerminal
using BSON: @save, @load
import Git

DotEnv.config()
const git = Git.git()

filedir = haskey(ENV, "BALANCE_STORE") ? ENV["BALANCE_STORE"] : joinpath(ENV["HOME"],".balance_jl")
personal_details_path = joinpath(filedir, "personal-details.bson")

if !ispath(filedir)
    mkdir(filedir)
end

struct AddressBlock
    name::String # human name
    buisness::String # buisness name (leave as "" to ignore)
    contact::String # email, phone, etc
    adr_l1::String # street and building number
    adr_l2::String # postcode, city, state/provice, country
end

abstract type EntityDetails end
struct PersonalDetails <: EntityDetails
  title::String # job title, ie. High Wizard and Chief Chef
  full_name::String # your full legal name
  contact::AddressBlock # contact information
end

struct ClientDetails <: EntityDetails
  work::String # Description of work performed , ie. duck wrangling
  billing_rate::Number # how much does this pay
  contact::AddressBlock # contact information
end

abstract type Record end

struct WorkItem <: Record
  client_id::String
  date::Date
  hours::Float64
  description::String
end

struct Reciept
  name::String
  extension::String
  data::Vector{UInt8}
  function Reciept(path)
    d = read(path)
    filename = split(path,"/")[end]
    n,ext = split(filename,".")
    new(n,ext,d)
  end
end

struct Expense <: Record
  date::Date
  cost::Float64
  description::String
  reciept::Reciept
end

mutable struct Log
  records::Vector{Record}
  cost::Float64
  month::Int64
  function Log(month)
    new(Vector{Record}(), 0, rate, month)
  end
end

include("markdown.jl")
include("sync.jl")

get_client_id(client) = client.contact.buisness != "" ? client.contact.buisness :  client.contact.name

function get_clients()
  files = filter(x->contains(x,"client-details"),readdir(filedir))
  clients = Dict()
  for f in files
    @load f client_details
    id = get_client_id(client_details)
    clients[id] = f
  end
  return clients
end


function update_logs(client_id, date, hours, description)
  log_name = "work-record-$(month(date))-$(year(date)).bson"
  if !isfile(log_name)
    log = Log(month(date))
    @save log_name log
  end
  @load log_name log
  record = WorkItem(client_id, date, hours, description)
  update!(log, record)
  println(log)
  @save log_name log
end

function update!(log::Log, record::Record)
  push!(log.records, record)
  log.cost += record.hours * log.rate
end

function generate_invoice(client_id, month, year)
  client_details = get_clients()[client_id]
  if !ispath(personal_details_path)
    register_self()
  end
  @load personal_details_path personal_details
  try
    log_name = "work-record-$month-$year.bson"
    @load log_name log
    open("invoice-$month-$year.md", "w") do f
      str = "# Invoice: $(monthname(month)), $year\n"
      str *= markdown_header(personal_details.contact, personal_details.contact)
      str *= markdown_table(log, client_id, personal_details.title, client_details.work, client_details.billing_rate)
      write(f, str)
    end
    run(`pandoc -f markdown -t latex -o invoice-$month-$year.pdf invoice-$month-$year.md`)
  catch err
    @error "Cannot create invoce: $err"
  end
end

include("cli.jl")
end # module Invoice
