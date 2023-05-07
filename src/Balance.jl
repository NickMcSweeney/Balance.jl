module Invoice
using Dates, Crayons, DotEnv, UUIDs
using BSON: @save, @load

struct AddressBlock
    name::String # human name
    buisness::String # buisness name (leave as "" to ignore)
    contact::String # email, phone, etc
    adr_l1::String # street and building number
    adr_l2::String # postcode, city, state/provice, country
end

struct PersonalDetails
  title::String # job title, ie. High Wizard and Chief Chef
  full_name::String # your full legal name
  contact::AddressBlock # contact information
end

struct ClientDetails
  work::String # Description of work performed , ie. duck wrangling
  billing_rate::Number # how much does this pay
  contact::AddressBlock # contact information
end

struct Record
  date::Date
  hours::Float64
  description::String
end

mutable struct Log
  records::Vector{Record}
  cost::Float64
  rate::Int64
  month::Int64
  function Log(month; rate=60)
    new(Vector{Record}(), 0, rate, month)
  end
end

include("template.jl")

function register_self()
  println("Is the Client a buisness? (y/N)")
  ans = readline(stdin)
  buisness = ""
  if (ans == "Y" || ans == "y")
    println("What is the name of the Client buisness?")
    buisness = readline(stdin)
  end
  println("What is your Client's name or the name of your contact at the Client Buisness?")
  full_name = readline(stdin)
  println("What do you do at the client?")
  working_role = readline(stdin)
  println("What is your billing rate at the Client?")
  working_rate = readline(stdin)
  println("How can the Client be contacted (email, phone, etc...):")
  contact = readline(stdin)
  println("Client Address [Builing Number + Street Name]:")
  line_one = readline(stdin)
  println("Client Address [Post Code + City + Country]:")
  line_two = readline(stdin)

  client_details = ClientDetails(working_role, working_rate, AddressBlock(full_name, buisness, contact, line_one, line_two))
  @save "client-details-$(UUIDs.uuid1).bson" client_details
end

function register_client()
  println("What is your Full Legal Name")
  full_name = readline(stdin)
  nick_name = full_name
  println("Would you like to use a different name for client contact? (y/N)")
  ans = readline(stdin)
  if (ans == "Y" || ans == "y")
    println("What name would you like to use for client contact?")
    nick_name = readline(stdin)
  end
  println("What is your title?")
  working_title = readline(stdin)
  println("Do you have a buisness name? (y/N)")
  ans = readline(stdin)
  buisness = ""
  if (ans == "Y" || ans == "y")
    println("What is the name of your buisness?")
    buisness = readline(stdin)
  end
  println("How can you be contacted (email, phone, etc...):")
  contact = readline(stdin)
  println("Address [Builing Number + Street Name]:")
  line_one = readline(stdin)
  println("Address [Post Code + City + Country]:")
  line_two = readline(stdin)

  personal_details = PersonalDetails(working_title, full_name, AddressBlock(nick_name, buisness, contact, line_one, line_two))
  @save "personal-details.bson" personal_details
end

function get_clients()
  files = filter(x->contains(x,"client-details"),readdir())
  clients = Dict()
  for f in files
    @load f client_details
    id = client_details.contact.buisness != "" ? client_details.contact.buisness :  client_details.contact.name
    clients[id] = f
  end
  return clients
end

function log_hours()
  println("--- Logging Hours ---")
  println("What date is this for?")
  println("<ENTER> for current day or dd/mm")
  ans = readline(stdin)
  day = ans == "" ? today() : Date("$ans/$(year(today()))", DateFormat("d/m/y"))
  println("How many hours did you work?")
  hours_worked = parse(Float64, readline(stdin))
  println("What did you do?")
  description = readline(stdin)
  println("Is this ok? (y/n)")
  println("Date: $day\nDescription: $description\nHours: $hours_worked\nCost: $(hours_worked*60)")
  res = readline(stdin)
  res == "n" ? log_hours() : update_logs(day,hours_worked,description)
end

function update_logs(date, hours, description)
  log_name = "work-record-$(month(date))-$(year(date)).bson"
  if !isfile(log_name)
    log = Log(month(date))
    @save log_name log
  end
  @load log_name log
  record = Record(date, hours, description)
  update!(log, record)
  println(log)
  @save log_name log
end

function update!(log::Log, record::Record)
  push!(log.records, record)
  log.cost += record.hours * log.rate
end

function generate_invoice(month, year)
  try
    log_name = "work-record-$month-$year.bson"
    @load log_name log
    open("invoice-$month-$year.md", "w") do f
      str = "# Invoice: $(monthname(month)), $year\n"
      str *= markdown_header()
      str *= markdown_table(log, )
      write(f, str)
    end
    run(`pandoc -f markdown -t latex -o invoice-$month-$year.pdf invoice-$month-$year.md`)
  catch err
    @error "Cannot create invoce: $err"
  end
end
end # module Invoice
