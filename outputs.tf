output "instance_id" {
  description = "The ID of instance 1"
  value       = google_compute_instance.webserver.instance_id
}

output "instance_id2" {
  description = "The ID of instance 2"
  value       = google_compute_instance.webserver2.instance_id
}

output "instance_id3" {
  description = "The ID of instance 3"
  value       = google_compute_instance.webserver3.instance_id
}

output "instance_id4" {
  description = "The ID of instance 4"
  value       = google_compute_instance.webserver4.instance_id
}
