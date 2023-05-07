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
  @save joinpath(filedir, "client-details-$(UUIDs.uuid1).bson") client_details
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
  @save personal_details_path personal_details
  return personal_details
end

function select_client()
  println("--- Select Client ---")
  clients = get_clients()
  menu = RadioMenu(clients, pagesize=4)
  choice = request("Choose a Client:", menu)
  if choice != -1
      println("Using ", client[choice], " for this record.")
  else
      println("Creating a new client.")
  end 
  choice != -1 ? register_client() : clients[choice]
end

function log_hours()
  client = select_client()
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
  res == "n" ? log_hours() : update_logs(get_client_id(client),day,hours_worked,description)
end