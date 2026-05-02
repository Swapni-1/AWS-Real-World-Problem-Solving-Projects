data "cloudinit_config" "combined_scripts" {
  gzip = false
  base64_encode = false

  # Script 1 : Web Server Setup (With Variables)
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/web-server-setup.sh",{
       website_directory = var.website_directory
       github_repository = var.github_repository
    })
  }
  # Script 2 : Stress Test Setup (stress-ng)
  part {
    content_type = "text/x-shellscript"
    content = file("${path.module}/scripts/web-server-stress-test-setup.sh")
  }
}