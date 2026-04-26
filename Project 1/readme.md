# Cloud Cost Optimization for mid-sized SaaS Enterprise (FinOps Automation)


## A mid-sized SaaS enterprise on AWS is spending ₹35–₹50 lakhs per month on cloud infrastructure, with 25–40% of costs wasted due to idle EC2 instances, over-provisioned databases, and unused storage. Despite mostly predictable workloads with occasional 3–5x traffic spikes, they lack real-time cost visibility and automated optimization, leading to consistent over-provisioning and billing shocks. Their small engineering team cannot efficiently manage cost optimization across 50+ AWS services manually. If unresolved, this could result in ₹1–₹1.5 crore in annual losses, directly impacting profitability and limiting future growth investments.

## To solve above problem what they are actually facing we have to simulate same problem in out own cloud infrastructure

## To do this i will create :-
1. ec2 instance that will simulate idle ec2
2. rds with mysql that will simulate overprovisioned database
3. s3 bucket that will simulate unused storage 

## Then i have to create private network so i have to create :-
1. vpc for private network
2. private subnets for rds 
3. public subnet for ec2
4. Internet Gateway to access internet 
5. Security Groups for ec2 and rds

## To attach s3 with ec2 i will need to create :-
1. IAM Role to access s3 in a secure way






