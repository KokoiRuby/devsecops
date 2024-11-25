## CI

**Continuous Integration** is a practice where developers frequently integrate their code changes into a **central repository**.

- Developers commit codes to **source repository** (GitHub, GitLab)

- Source repository triggers webhook & notifies **CI Server**

- CI Server pulls codes & perform **build** & (unit) **test** then return the **results** back to developers.


![image-20241118124949026](Readme.assets/image-20241118124949026.png)

**Tradeoff**

- **Speed** (efficiency up without affecting quality)
  - Duration
  - Error rate
  - Managed service: GitHub Action, GitLab CI
- **Extensibility** (Avoid analysis paralysis)
  - Best practices
- **Security** (preventive/detective)
  - Auditting
  - Observability
  - Supply-chain