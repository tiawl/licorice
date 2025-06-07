#! /usr/bin/env --split-string gojq --from-file

def process_inventory: (
  .inventory as $inventory |

  def process_inventory_into_inventory(walk_path): (
    if (type == "object") then (
      if (has("inventory")) then (
        if (.inventory | type != "string") then (
          "process_inventory_into_inventory: \"inventory\" must be string typed" | exit
        ) else . end |
        .inventory as $inv |
        if (walk_path | any(. == $inv)) then (
          "process_inventory_into_inventory: Inventory cycle detected" | exit
        ) else . end |
        $inventory[.inventory] | process_inventory_into_inventory(walk_path + [.inventory])
      ) else (
        map_values(process_inventory_into_inventory(walk_path))
      ) end
    ) elif type == "array" then (
      map(process_inventory_into_inventory(walk_path))
    ) else . end
  );

  (.inventory | map_values(process_inventory_into_inventory([]))) as $inventory |
  {
    group: (.group | walk(if type == "object" and has("inventory") then ($inventory[.inventory]) else . end))
  }
);

process_inventory
