include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
  games_config  = yamldecode(file("${get_repo_root()}/modules/game-reverse-proxies/games.yaml"))
  
  # Filter enabled games
  enabled_games = [for game in local.games_config.games : game if game.enabled]
  
  # Generate game service definitions for user-data
  game_services = join("\n", [
    for game in local.enabled_games : <<-EOT
      # Create systemd service for ${game.name} proxy
      echo "Creating systemd service for ${game.name} proxy..."
      cat > /etc/systemd/system/${game.name}-proxy.service <<SERVICE_EOF
      [Unit]
      Description=${game.description} Reverse Proxy
      After=network.target tailscaled.service
      Wants=tailscaled.service
      
      [Service]
      Type=simple
      ExecStart=/usr/bin/socat -d -d ${upper(game.protocol)}4-LISTEN:${game.port},fork,reuseaddr ${upper(game.protocol)}4:${local.games_config.homelab.fallback_ip}:${game.port}
      Restart=always
      RestartSec=5
      StandardOutput=journal
      StandardError=journal
      
      [Install]
      WantedBy=multi-user.target
      SERVICE_EOF
      
      systemctl daemon-reload
      systemctl enable ${game.name}-proxy.service
      systemctl start ${game.name}-proxy.service
    EOT
  ])
  
  # Generate service status checks
  service_status_checks = join("\n", [
    for game in local.enabled_games : "systemctl status ${game.name}-proxy.service --no-pager"
  ])
  
  # Game names for logging
  game_names = join(", ", [for game in local.enabled_games : game.name])
}

terraform {
  source = "${get_repo_root()}/modules/game-reverse-proxies/ec2"
}

dependency "vpc" {
  config_path = "${get_repo_root()}/modules/game-reverse-proxies/vpc"
  
  # Mock outputs for plan/validate without deploying VPC first
  mock_outputs = {
    vpc_id            = "vpc-mock-12345678"
    public_subnet_id  = "subnet-mock-12345678"
    vpc_cidr          = "10.0.0.0/24"
    availability_zone = "us-west-1a"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

dependency "security_group" {
  config_path = "${get_repo_root()}/modules/game-reverse-proxies/security-group"
  
  # Mock outputs for plan/validate without deploying security group first
  mock_outputs = {
    security_group_id   = "sg-mock-12345678"
    security_group_arn  = "arn:aws:ec2:us-west-1:123456789012:security-group/sg-mock-12345678"
    security_group_name = "game-reverse-proxies-sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

inputs = {
  name = "game-reverse-proxies"
  
  ami                         = "ami-0b967c22fe917319b"
  instance_type               = "t3.micro"
  key_name                    = "reverse-proxy"
  
  # Network configuration
  subnet_id                   = dependency.vpc.outputs.public_subnet_id
  vpc_security_group_ids      = [dependency.security_group.outputs.security_group_id]
  associate_public_ip_address = true
  
  # Monitoring
  monitoring                  = true
  
  # User data script - dynamically generated from games.yaml
  user_data_base64            = base64encode(templatefile("${get_terragrunt_dir()}/user-data-template.sh", {
    tailscale_auth_key    = get_env("TAILSCALE_AUTH_KEY")
    hostname              = "game-reverse-proxy"
    homelab_hostname      = local.games_config.homelab.tailscale_hostname
    homelab_fallback_ip   = local.games_config.homelab.fallback_ip
    game_services         = local.game_services
    service_status_checks = local.service_status_checks
    game_names            = local.game_names
  }))
  
  user_data_replace_on_change = false
  
  # Root volume (object format for module v6.x)
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }
  
  # IMDSv2
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  # EIP will be created separately
  create_eip = false
  
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name = "game-reverse-proxy"
    }
  )
}