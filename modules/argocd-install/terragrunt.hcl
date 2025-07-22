include "root" {
  path = find_in_parent_folders()
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

inputs = merge(
  local.common_inputs,
  {}
)
