include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
  games_config  = yamldecode(file("${get_repo_root()}/modules/game-reverse-proxies/games.yaml"))
  
  # Filter enabled games and create ingress rules
  enabled_games = [for game in local.games_config.games : game if game.enabled]
  
  # Generate ingress rules for each enabled game
  game_ingress_rules = [
    for game in local.enabled_games : {
      from_port   = game.port
      to_port     = game.port
      protocol    = game.protocol
      description = game.description
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

terraform {
  source = "${get_repo_root()}/modules/game-reverse-proxies/security-group"
}

dependency "vpc" {
  config_path = "${get_repo_root()}/modules/game-reverse-proxies/vpc"
  
  # Mock outputs for plan/validate without deploying VPC first
  mock_outputs = {
    vpc_id = "vpc-mock-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

inputs = {
  name        = "game-reverse-proxy-sg"
  description = "Security group for game reverse proxy"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  # Ingress rules - dynamically generated from games.yaml + SSH
  ingress_with_cidr_blocks = concat(
    local.game_ingress_rules,
    [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "SSH access"
        cidr_blocks = get_env("ADMIN_CIDR_BLOCKS")
      }
    ]
  )
  
  # Egress rules - allow all outbound
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name = "game-reverse-proxy-sg"
    }
  )
}
