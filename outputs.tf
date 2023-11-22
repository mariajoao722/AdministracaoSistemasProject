output "instance_id" {
  description = "The ID of instance"
  value       = google_compute_instance.webserver.instance_id
}

output "instance_id2" {
  description = "The ID of instance"
  value       = google_compute_instance.webserver2.instance_id
}
