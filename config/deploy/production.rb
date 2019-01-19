set :stage, :production
server '54.226.78.3', user: 'ubuntu', roles: %w{app}

require 'aws-sdk-core'
require 'aws-sdk-autoscaling'
require 'aws-sdk-ec2'

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

as = Aws::AutoScaling::Client.new
instances_of_as = as.describe_auto_scaling_groups(
 auto_scaling_group_names: ['DLP Auto Scaling Group'],
 max_records: 1,
).auto_scaling_groups[0].instances

if instances_of_as.empty?
 autoscaling_dns = []
else
 instances_ids = instances_of_as.map(&:instance_id)
 i = {}

 ec2 = Aws::EC2::Resource.new(region: 'us-east-1')

 autoscaling_dns = instances_ids.map do |instance_id|
  ec2.instance(instance_id).public_dns_name
 end
end

instances = autoscaling_dns
instances.each do |instance|
 server instance, user: 'ubuntu', roles: %w{app}
end