variable "vms" {
  type = map(object({
    size           = string
    subnet_key     = string          # ← KEY from networking output!
    admin_username = string
    additional_inbound_rules = list(object({
      name     = string
      priority = number
      protocol = string
      port     = string
      source   = string
    }))
  }))
  
}