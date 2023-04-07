module Invoice
using Dates, Crayons
using BSON: @save, @load

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

function markdown_header()
  str = "
> Nicholas Shindler\n
>	nick@shindler.tech\n
>	3492 Little River Road\n
>	Port Angeles, WA 98363\n
\n
#### Invoice To:\n
> Charles Grinnel\n
>	Harvest Automation Inc\n
>	85 Rangeway Road\n
>	Billerica, MA 01862\n
---\n"
end

function export_invoice(month, year)
try
  log_name = "work-record-$month-$year.bson"
  @load log_name log
  open("invoice-$month-$year.md", "w") do f
    str = "# Invoice: $(monthname(month)), $year\n"
    str *= markdown_header()
    str *= "\n_This invoce is for $(sum([r.hours for r in log.records])) hours worked performing Software Engineering and other Consulting work for Robotics & Software Development._\n\n"
    str *= "| Date | Hours | Description | Cost |\n|---|---|---|---|\n"
    for record in log.records
      str *= "| $(record.date) | $(record.hours) | $(record.description) | $(record.hours * log.rate) |\n"
    end
    str *= "\n#### Total: \$$(log.cost)"
    write(f, str)
  end
  run(`pandoc -f markdown -t latex -o invoice-$month-$year.pdf invoice-$month-$year.md`)
catch err
  @error "Cannot create invoce: $err"
end
end

end # module Invoice
