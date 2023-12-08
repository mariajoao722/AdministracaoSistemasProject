output "instance_id" {
  description = "The ID of instance 1"
  value       = google_compute_instance.osd1.instance_id
}

output "instance_id2" {
  description = "The ID of instance 2"
  value       = google_compute_instance.osd2.instance_id
}

output "instance_id3" {
  description = "The ID of instance 3"
  value       = google_compute_instance.mon.instance_id
}

output "instance_id4" {
  description = "The ID of instance 4"
  value       = google_compute_instance.mjr.instance_id
}

output "instance_id5" {
  description = "The ID of instance 5"
  value       = google_compute_instance.backup.instance_id
}