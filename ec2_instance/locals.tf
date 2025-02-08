locals {
  # Reading the scripts content and passing it to user_data.sh
  user_data = templatefile("${path.module}/user_data.sh", {
    script1 = file("${path.module}/user_data/user_data_users.sh")
    script2 = file("${path.module}/user_data/user_data_logs.sh")
    script3 = file("${path.module}/user_data/user_data_apache.sh")
    script4 = file("${path.module}/user_data/user_data_cron.sh")
    script5 = file("${path.module}/user_data/user_data_cloudwatch_agent.sh")
    env_var = "Hello from env_var in locals.tf!"

  })
}
