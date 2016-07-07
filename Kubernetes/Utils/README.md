# Utils

Not everything has a simple command to access it, especially things of a "glue" nature.
Here are some utilities to show how you might do it. 

## Example Useage:
python Utils/AWS/route53.py -elb $(Utils/get_ingress.sh prometheus) -domain prometheus.cncfdemo.io

A Service is exposed via an elb alias that is not user friendly unless you want to direct users to an address like:
a7a407ed342af11e68f1106a6d880b17-242835472.us-west-2.elb.amazonaws.com
The above example glues the alias to a subdomain via route53.
