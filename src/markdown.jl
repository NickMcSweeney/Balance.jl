function markdown_header(sender::AddressBlock, recipient::AddressBlock)
  str = "
> $(sender.name)\n
$(sender.buisness != "" ? ">	$(sender.buisness)\n" : "")
>	$(sender.contact)\n
>	$(sender.adr_l1)\n
>	$(sender.adr_l2)\n
\n
#### Invoice To:\n
> $(recipient.name)\n
$(recipient.buisness != "" ? ">	$(recipient.buisness)\n" : "")
>	$(recipient.contact)\n
>	$(recipient.adr_l1)\n
>	$(recipient.adr_l2)\n
---\n"
end

function markdown_table(log, client_id, work_type, work_field, work_rate)
    str = ""
    str *= "\n_This invoce is for $(sum([r.hours for r in log.records])) hours worked as $work_type performing $work_field._\n\n"
    str *= "| Date | Hours | Description | Cost |\n|---|---|---|---|\n"
    for record in log.records
      if client_id == record.client_id
        str *= "| $(record.date) | $(record.hours) | $(record.description) | $(record.hours * work_rate) |\n"
      end
    end
    str *= "\n#### Total: \$$(log.cost)"
end