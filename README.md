# HA-Web-Service-EC2

THe goal: 

User Story 1
As a product owner
- I would like the service to be highly available
- So that I can access it when I need it

User Story 2
As a product owner
- I would like the platform to be secure
- To reduce the attack surface exposed

<h2> Overview: </h2>

In result we have a simple nginx webservice running on port 80 on two EC2 instances deployed in private subnets in two availability zones - 
The fact that they are deployed within private subnets is reducing the accessibility and potentialsurface for an attack from the internet. 

The instances are protected behind NAT Gateway, which makes sure the instances are protected from the outside, but still able to communicate with the outside 
world from within.

There is application Load Balancer that provides load balancing in case one of the instances.

Instances are created and managed by autoscalling group engined by launch configuration.

Instances are directly accessible from SSM components.

<h3> Possible access to the instances </h3> 
Install SSM plugin manager https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

 aws --profile <your_profile> ssm start-session --region <region>  --target <i-** of instance>
 
 <h3> Further possible improvements </h3>
 
 - Adding SSL https on LoadBalancer https://aws.amazon.com/premiumsupport/knowledge-center/associate-acm-certificate-alb-nlb/
 - WAF https://aws.amazon.com/blogs/aws/aws-web-application-firewall-waf-for-application-load-balancers/
