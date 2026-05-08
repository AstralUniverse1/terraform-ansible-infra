resource "terraform_data" "remote_backend_smoke" {
  input = {
    purpose = "verify remote backend initialization and state writes"
  }
}

output "smoke_id" {
  description = "ID from the backend smoke resource."
  value       = terraform_data.remote_backend_smoke.id
}
