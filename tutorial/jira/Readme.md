## [Jira](https://www.atlassian.com/software/jira)

A project management and issue tracking tool developed by Atlassian.

It is widely used by software development for tracking bugs, managing projects, and facilitating agile development methodologies.

### Trunk-based vs. GitFlow

### Hands-on

![workflow](Readme.assets/workflow.png)

![jenkins-prod](Readme.assets/jenkins-prod.png)



#### Demo#1

> Smart commit

Note: you might meet 504 Gateway Time-out. Please check jira-0 pod log & refresh the page later if necessary.

Set up application properties on jira dashboard.

![image-20241203193825376](Readme.assets/image-20241203193825376.png)

Generate trail license. Note: you need a Atlanssian account.

![image-20241203194430865](Readme.assets/image-20241203194430865.png)

Set up admin account. **Note: you need to use the same email as the one in Github that contains demo app source repo.**

![image-20241203194905379](Readme.assets/image-20241203194905379.png)

Good to go.

![image-20241203195132098](Readme.assets/image-20241203195132098.png)

Create a scrum project & specify the key.

![image-20241203195147105](Readme.assets/image-20241203195147105.png)

![image-20241203195235417](Readme.assets/image-20241203195235417.png)

"Manage apps".

![image-20241203195408262](Readme.assets/image-20241203195408262.png)

"Applications" 👉 "DVCS accounts".

![image-20241203195507802](Readme.assets/image-20241203195507802.png)

Create client id & secret in GitHub and add to jira.

![image-20241203195703585](Readme.assets/image-20241203195703585.png)

![image-20241203195749898](Readme.assets/image-20241203195749898.png)

![image-20241203195809955](Readme.assets/image-20241203195809955.png)

![image-20241203200032849](Readme.assets/image-20241203200032849.png)

Authorize.

![image-20241203200134080](Readme.assets/image-20241203200134080.png)

![image-20241203200223183](Readme.assets/image-20241203200223183.png)

![image-20241203200246705](Readme.assets/image-20241203200246705.png)

Create a test issue.

![image-20241203200459961](Readme.assets/image-20241203200459961.png)

Check created issue. Note: the ticket number is what we want to correlate with commit.

![image-20241203200644498](Readme.assets/image-20241203200644498.png)

Create a commit in demo app source repo given ticket number.

```bash
git commit -a -m 'DEVSECOPS-1 #comment test1' --allow-empty
git push -u origin main
```

Check on jira dashboard.

![image-20241203201654730](Readme.assets/image-20241203201654730.png)

Similarly.

```bash
# log time spent on the issue.
git commit -a -m 'DEVSECOPS-1 #time 2h' --allow-empty
git push -u origin main
```

```bash
# transition the issue to the "In Progress" status.
git commit -a -m 'DEVSECOPS-1 #in-progress' --allow-empty
git push -u origin main
```

```bash
# transition the issue to the "Done" status.
git commit -a -m 'DEVSECOPS-1 #done' --allow-empty
```

#### Demo#2

> Jenkins multibranch