# Useful Tips

### AWS

Clicking around the UI is a little bit slow, some shortcuts as follows.

List all the minion instance ids along with their public ips:

> aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=k-minion" --region us-west-2 --query 'Reservations[*].Instances[*].[InstanceId, NetworkInterfaces[].Association.PublicIp]' --output text
