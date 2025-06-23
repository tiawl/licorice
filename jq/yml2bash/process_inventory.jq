#! /usr/bin/env --split-string gojq --from-file

def process_inventory: (
  def process_inventory_into_inventory(walk_path; root_inventory): (
    if (type == "object") then (
      if (has("inventory")) then (
        if (.inventory | type != "string") then (
          "process_inventory_into_inventory: \"inventory\" must be string typed" | exit
        ) else . end |
        .inventory as $key |
        if (walk_path | any(. == $key)) then (
          [($key | debug_var("$key")), (walk_path | debug_var("walk_path"))] |
          "process_inventory_into_inventory: Inventory cycle detected" | exit
        ) else . end |
        root_inventory[$key] | process_inventory_into_inventory(walk_path + [$key]; root_inventory)
      ) else (
        map_values(process_inventory_into_inventory(walk_path; root_inventory))
      ) end
    ) elif (type == "array") then (
      map(process_inventory_into_inventory(walk_path; root_inventory))
    ) else . end
  );

  (.inventory as $root_inventory | $root_inventory | map_values(process_inventory_into_inventory([]; $root_inventory))) as $processed_inventory |
  {
    name: .name,
    import: ((.import | walk(if ((type == "object") and (has("inventory")) and ((.inventory | type) == "string")) then ($processed_inventory[.inventory]) else . end)) // {}),
    group: (.group | walk(if ((type == "object") and (has("inventory")) and ((.inventory | type) == "string")) then ($processed_inventory[.inventory]) else . end))
  }
);

process_inventory
