require "json"

key_id_to_loc = {}

hash = JSON.parse(File.open("export.json", "r").read)

people = Array.new(hash["people"].size)

hash["people"].each.with_index do |(key_id, person), i|
  people[i] = person
  key_id_to_loc[key_id.to_i] = i
end

links = []

hash["graph"].each do |node, node_links|
  node = node.to_i
  node_links["from"].each do |from_id|
    from_id = from_id.to_i
    links << {
      source: key_id_to_loc.fetch(from_id),
      target: key_id_to_loc.fetch(node),
    }
  end

  node_links["to"].each do |to_id|
    to_id = to_id.to_i
    links << {
      source: key_id_to_loc.fetch(node),
      target: key_id_to_loc.fetch(to_id),
    }
  end
end

result = {
  nodes: people,
  links: links,
}

File.open("final_export.json", "w") do |f|
  f.puts(result.to_json)
end
