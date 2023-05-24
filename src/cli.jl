"""
  register_client

CLI function that walks through adding a clients details and saves to local system
 * buisness name
 * contact name
 * billing rate
 * role at client
 * client contact
 * client address
"""
function register_client()
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
  while !isa(working_rate, Number)
    try
      working_rate = parse(Float64, working_rate)
    catch e
      println("Rate given of $working_rate cannot be parsed as a number, try again please.")
      working_rate = readline(stdin)
    end
  end
  println("How can the Client be contacted (email, phone, etc...):")
  contact = readline(stdin)
  println("Client Address [Builing Number + Street Name]:")
  line_one = readline(stdin)
  println("Address [City, State Postcode, Country (optional)]:")
  line_two = readline(stdin)

  client_details = ClientDetails(working_role, working_rate, AddressBlock(full_name, buisness, contact, line_one, line_two))
  @save joinpath(filedir, "client-details-$(UUIDs.uuid1()).bson") client_details
  return client_details
end

"""
  register_self

CLI that walks through adding your details and saves it to the system.
 * Full name
 * common name
 * title
 * company name
 * contact
 * address
"""
function register_self()
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
  println("Address [City, State Postcode, Country (optional)]:")
  line_two = readline(stdin)

  personal_details = PersonalDetails(working_title, full_name, AddressBlock(nick_name, buisness, contact, line_one, line_two))
  @save personal_details_path personal_details
  return personal_details
end

"""
  select_client

CLI for selecting or creating a new client.
"""
function select_client()
  println("Do you want to use an existing Client (Y/n)")
  ans = readline(stdin)
  if ans == "n" || ans == "N"
    return register_client()
  end
  println("--- Select Client ---")
  clients = get_clients()
  options = [opt for opt in keys(clients)]
  if length(options) == 0
    println("No registered Clients, starting new Client registration.")
    return register_client()
  end
  menu = RadioMenu(options, pagesize=4)
  choice = request("Choose a Client:", menu)
  if choice != -1
      println("Using ", options[choice], " for this record.")
      cpath = clients[options[choice]]
      @load joinpath(filedir, cpath) client_details
      return client_details
  else
      println("Creating a new client.")
      return register_client()
  end
end

"""
  generate_work_item

- client: ClientDetails

CLI that creates a item of work for a client. Colects information to create a `WorkItem`.
"""
function generate_work_item(client::ClientDetails)
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
  work_item = res == "n" ? generate_work_item(client) : WorkItem(get_client_id(client),day,hours_worked,description)
end

"""
  log_hours

select a client, and generate a `WorkItem` and log information to local file system.
"""
function log_hours()
  client = select_client()
  work_item = generate_work_item(client)
  update_logs(work_item)
end

"""
  export_invoice

CLI to select an invoice and export it.
"""
function export_invoice()
  client = select_client()
  println("What month do you want your invoice for? (1-12)")
  month = parse(Int, readline(stdin))
  println("What year do you want your invoice for? ie. 2023")
  year = parse(Int, readline(stdin))
  generate_invoice(client,month,year)
end
