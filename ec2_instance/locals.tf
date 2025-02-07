# Use templatefile to process the user-data script
locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    env_var = "Hello from Apache Server!"  # Replace this with your desired value
  })
}
