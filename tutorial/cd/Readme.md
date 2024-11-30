## CD

A practice that emphasizes the ongoing and iterative process of releasing software updates and improvements. 

- ENV definition & elevation (dev → test → pre-release → prod)

vs.

- **Continuous Delivery** refers to deploying integrated code to a "prod-like env" then to prod manually.
  - Quality/Stability > Release efficiency
  - Release process may be interrupted
  - Ticket → DevOps team provides pipelines
- **Continuous Deployment** takes **a step further** by **automating** the process of deploying to the prood-env.
  - High automation, Fast release speed
  - "Left-shift" quality (to dev)
  - Less prone to process interruptions


![Continuous Delivery](Readme.assets/Continuous-Delivery.png)

![Continuous Deploy](Readme.assets/Continuous-Deploy.png)