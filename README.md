# DevSecOps Pipeline for `my-html-app`

## **Overview**
This project showcases my hands-on experience implementing a DevSecOps pipeline using Jenkins, Docker, and SonarQube. The pipeline automates the build, test, security scanning, and deployment of a sample HTML application. By incorporating modern DevSecOps practices, such as static application security testing (SAST) and container vulnerability scanning, I aimed to bridge the gap between development, security, and operations.

---

## **Pipeline Workflow**

### **1. Checkout Code**
- **What I Did**: Configured Jenkins to integrate with GitHub using a webhook, ensuring the pipeline triggers automatically whenever changes are pushed to the `main` branch.
- **Why I Did It**: Automated integration saves time and ensures that every code change is tested and validated immediately.
- **Real-World Example**: This setup mirrors how development teams manage rapid updates in shared repositories, maintaining continuous integration and minimizing manual effort.

### **2. Build**
- **What I Did**: Built a Docker image for the `my-html-app` project using an `nginx:alpine` base image and the provided `index.html` file.
- **Why I Did It**: Containerizing the application standardizes its environment, ensuring consistency across development, testing, and production.
- **Real-World Example**: Containers solve the "works on my machine" problem, enabling smooth deployment across various platforms.

### **3. Test**
- **What I Did**:
  - Ran the containerized application and validated its functionality by checking the HTTP response code.
  - Automated cleanup of running containers to prevent conflicts and resource issues.
- **Why I Did It**: Automated testing ensures that functional issues are identified early in the pipeline.
- **Real-World Example**: Quick smoke tests in CI pipelines help prevent broken builds from moving forward.

### **4. SAST with SonarQube**
- **What I Did**:
  - Integrated SonarQube for static code analysis to detect security vulnerabilities and code quality issues.
  - Analyzed potential risks, such as insecure JavaScript usage or missing security headers.
- **Why I Did It**: Early detection of vulnerabilities reduces the risk of deploying insecure applications.
- **Real-World Example**: Organizations use tools like SonarQube to comply with standards like OWASP Top 10 and PCI DSS.

### **5. Security Scan with Trivy**
- **What I Did**:
  - Scanned the Docker image for vulnerabilities using Trivy.
  - Identified issues in the base image and dependencies, documenting fixes where applicable.
- **Why I Did It**: Scanning for vulnerabilities ensures that only secure containers are deployed.
- **Real-World Example**: This step aligns with DevSecOps best practices and compliance requirements for container security.

### **6. Deploy**
- **What I Did**:
  - Automated deployment of the application using Docker Compose.
  - Included cleanup routines to remove stale deployments and prevent conflicts.
- **Why I Did It**: Automation reduces deployment errors and ensures consistency across environments.
- **Real-World Example**: Continuous deployment enables organizations to roll out updates rapidly with minimal downtime.

---

## **Challenges and Lessons Learned**

### **Challenges**
1. **Port Conflicts**: The pipeline encountered failures due to pre-existing containers using the same port.
2. **Webhook Issues**: Debugging webhook configurations caused delays in automating pipeline triggers.
3. **Static Analysis Tuning**: Adjusting SonarQube to effectively analyze HTML required experimentation with rule sets.

### **Lessons Learned**
1. **Automate Cleanup**: Automated container cleanup reduced conflicts and made the pipeline more reliable.
2. **Enhance Security Awareness**: Using tools like SonarQube and Trivy emphasized the importance of integrating security into development workflows.
3. **Simplify Webhook Configurations**: Proper webhook setup ensures seamless CI/CD integration.

---

## **Real-World Impact**
This pipeline exemplifies how DevSecOps principles integrate security into every stage of the software development lifecycle (SDLC). Key benefits include:

- **Enhanced Security**: Detecting vulnerabilities early reduces the likelihood of security breaches.
- **Increased Efficiency**: Automation shortens feedback loops, enabling teams to iterate faster.
- **Regulatory Compliance**: Integrating SAST and container scanning supports adherence to industry standards.
