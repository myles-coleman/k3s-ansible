# Palworld Reverse Proxy - Deployment Guide (terraform-aws-modules)

## 💰 Total Cost Breakdown

| Component | Monthly Cost | Annual Cost | Notes |
|-----------|--------------|-------------|-------|
| **VPC** | **$0** | **$0** | All VPC components are free |
| **EC2 t3.micro** | **$7.50** | **$90** | Free tier: 750 hrs/month for 12 months |
| **Elastic IP** | **$0** | **$0** | Free while attached to running instance |
| **Security Group** | **$0** | **$0** | Free |
| **Data Transfer** | **$0-9** | **$0-108** | First 100GB/month free, then $0.09/GB |
| **TOTAL** | **~$7.50** | **~$90** | **First year: $0 with free tier!** |

## 🏗️ Architecture

This setup uses official **terraform-aws-modules** for best practices:

```
┌─────────────┐
│   Players   │ Connect to bigbeevpn.mooo.com:8211
└──────┬──────┘
       │
       ▼
┌──────────────────────────────────────────────┐
│ AWS Infrastructure (terraform-aws-modules)   │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │ VPC Module (v5.1.2)                │     │
│  │ - 10.0.0.0/24                      │     │
│  │ - Public Subnet: 10.0.0.0/28       │     │
│  │ - Internet Gateway                 │     │
│  └────────────────────────────────────┘     │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │ Security Group Module (v5.1.0)     │     │
│  │ - UDP 8211 (Palworld)              │     │
│  │ - TCP 22 (SSH)                     │     │
│  └────────────────────────────────────┘     │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │ EC2 Instance Module (v5.6.0)       │     │
│  │ - t3.micro                         │     │
│  │ - Amazon Linux 2023                │     │
│  │ - Tailscale + Socat                │     │
│  └────────────────────────────────────┘     │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │ Elastic IP                         │     │
│  │ - Static public IP                 │     │
│  └────────────────────────────────────┘     │
└──────────────────────────────────────────────┘
                 │
                 ▼
         ┌───────────────┐
         │  Tailscale    │ Encrypted VPN
         │     VPN       │
         └───────┬───────┘
                 │
                 ▼
         ┌───────────────┐
         │ Home Network  │
         │  Palworld     │
         │  Server       │
         │  :8211        │
         └───────────────┘
```

## 📋 Prerequisites

### 1. Environment Variables

Create these environment variables:

```bash
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxx-xxxxxx"
export PALWORLD_SERVER_IP="100.x.x.x"  # Your server's Tailscale IP
export ADMIN_CIDR_BLOCKS='["0.0.0.0/0"]'  # Or restrict to your IP
```

### 2. Get Tailscale Information

On your Palworld server:
```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up

# Get Tailscale IP
tailscale ip -4
# Output: 100.x.x.x
```

### 3. Generate Tailscale Auth Key

1. Go to: https://login.tailscale.com/admin/settings/keys
2. Click "Generate auth key"
3. Check "Reusable" and set expiration to 90 days
4. Copy the key (starts with `tskey-auth-`)

## 🚀 Deployment Steps

### Option 1: Deploy All at Once (Recommended)

```bash
cd /home/bee/k3s-ansible

# Set environment variables
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxx-xxxxxx"
export PALWORLD_SERVER_IP="100.x.x.x"
export ADMIN_CIDR_BLOCKS='["0.0.0.0/0"]'

# Deploy everything
terragrunt run-all apply \\
  --terragrunt-include-dir modules/vpc \\
  --terragrunt-include-dir modules/palworld-reverse-proxy
```

### Option 2: Deploy Step-by-Step

#### Step 1: Deploy VPC ($0/month)

```bash
cd /home/bee/k3s-ansible/modules/vpc
terragrunt init
terragrunt apply
```

**Outputs:**
```
vpc_id = "vpc-xxxxx"
public_subnet_id = "subnet-xxxxx"
```

#### Step 2: Deploy Security Group ($0/month)

```bash
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/security-group
terragrunt init
terragrunt apply
```

**Outputs:**
```
security_group_id = "sg-xxxxx"
```

#### Step 3: Deploy EC2 Instance ($7.50/month)

```bash
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy

# Set environment variables
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxx-xxxxxx"
export PALWORLD_SERVER_IP="100.x.x.x"

terragrunt init
terragrunt apply
```

**Outputs:**
```
instance_id = "i-xxxxx"
instance_public_ip = "x.x.x.x"
```

#### Step 4: Deploy Elastic IP ($0/month)

```bash
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/eip
terragrunt init
terragrunt apply
```

**Outputs:**
```
public_ip = "y.y.y.y"
allocation_id = "eipalloc-xxxxx"
```

### Step 5: Wait for Instance Setup (2-3 minutes)

```bash
# Get the Elastic IP
EIP=$(cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/eip && terragrunt output -raw public_ip)

# Wait for SSH to be ready
sleep 60

# SSH into instance
ssh ec2-user@$EIP

# Check user-data progress
sudo tail -f /var/log/user-data.log

# Check Tailscale
sudo tailscale status

# Check proxy service
sudo systemctl status palworld-proxy

# View live logs
sudo journalctl -u palworld-proxy -f
```

### Step 6: Update DNS

```bash
# Get Elastic IP
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/eip
EIP=$(terragrunt output -raw public_ip)
echo "Update bigbeevpn.mooo.com to: $EIP"
```

Go to your DNS provider and update the A record.

### Step 7: Test Connection

```bash
# Test UDP port
nc -u -v bigbeevpn.mooo.com 8211

# Or connect from Palworld client
# Server: bigbeevpn.mooo.com:8211
```

## ✅ Verification Checklist

- [ ] VPC created (terraform-aws-modules/vpc)
- [ ] Security group created (terraform-aws-modules/security-group)
- [ ] EC2 instance running (terraform-aws-modules/ec2-instance)
- [ ] Elastic IP attached
- [ ] Tailscale connected (`sudo tailscale status`)
- [ ] Proxy service running (`sudo systemctl status palworld-proxy`)
- [ ] DNS updated to Elastic IP
- [ ] Can connect from Palworld client

## 🔧 Troubleshooting

### Module Not Found

```bash
# Re-initialize Terraform
cd <module-directory>
terragrunt init
```

### Dependency Errors

Modules must be deployed in order:
1. VPC
2. Security Group
3. EC2 Instance
4. Elastic IP

### Can't SSH

```bash
# Check security group
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/security-group
terragrunt output security_group_id

# Verify instance is running
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy
terragrunt output instance_id

aws ec2 describe-instances --instance-ids <instance-id>
```

### Tailscale Not Connecting

```bash
ssh ec2-user@$EIP

# Check Tailscale service
sudo systemctl status tailscaled

# Re-authenticate
sudo tailscale up --authkey=$TAILSCALE_AUTH_KEY
```

## 📊 Module Versions

This setup uses pinned versions for stability:

| Module | Version | Purpose |
|--------|---------|---------|
| terraform-aws-modules/vpc/aws | 5.1.2 | VPC infrastructure |
| terraform-aws-modules/ec2-instance/aws | 5.6.0 | EC2 instance |
| terraform-aws-modules/security-group/aws | 5.1.0 | Security group |

## 🔄 Updates

### Update Module Versions

Edit `terragrunt.hcl` files and change the version:

```hcl
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.2.0"  # Updated version
}
```

Then:
```bash
terragrunt init -upgrade
terragrunt apply
```

### Update User Data

If you modify `user-data.sh`:

```bash
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy

# Recreate instance
terragrunt taint module.ec2_instance.aws_instance.this[0]
terragrunt apply
```

## 🗑️ Cleanup

Delete in reverse order:

```bash
# 1. Delete EIP
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/eip
terragrunt destroy

# 2. Delete EC2
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy
terragrunt destroy

# 3. Delete Security Group
cd /home/bee/k3s-ansible/modules/palworld-reverse-proxy/security-group
terragrunt destroy

# 4. Delete VPC
cd /home/bee/k3s-ansible/modules/vpc
terragrunt destroy
```

Or destroy all at once:
```bash
cd /home/bee/k3s-ansible
terragrunt run-all destroy
```

## 💡 Benefits of terraform-aws-modules

✅ **Best Practices**: Official modules follow AWS best practices  
✅ **Well-Tested**: Used by thousands of production deployments  
✅ **Maintained**: Regular updates and security patches  
✅ **Documented**: Comprehensive documentation and examples  
✅ **Flexible**: Easy to customize via inputs  
✅ **DRY**: Don't Repeat Yourself - reuse proven code  
✅ **Community**: Large community support  

## 📚 Additional Resources

- [terraform-aws-modules GitHub](https://github.com/terraform-aws-modules)
- [VPC Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [EC2 Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)
- [Security Group Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Tailscale Documentation](https://tailscale.com/kb/)
