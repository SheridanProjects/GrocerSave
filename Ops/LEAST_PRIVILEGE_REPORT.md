# Least Privilege Security Report for GrocerSave

## 1. Executive Summary
This report analyzes the current security posture of the GrocerSave application infrastructure (Kubernetes manifests, Dockerfiles, and Service configurations) and outlines a plan to implement the **Principle of Least Privilege (PoLP)**.

Currently, the application services run with default privileges, which include running as the `root` user inside containers, unrestricted network communication between services, and the use of administrative database credentials for application logic.

## 2. Current Security Posture Analysis

### 2.1. Container Privileges
*   **Issue**: All Dockerfiles (`Dockerfile.backend`, `Dockerfile.bff`, `Dockerfile.frontend`) lack a `USER` instruction.
*   **Impact**: Containers run as `root` (UID 0). If a container is compromised, the attacker has root privileges within the container namespace, making container breakout attacks significantly easier.
*   **Capabilities**: Default Linux capabilities (e.g., `CHOWN`, `SETUID`, `NET_RAW`) are enabled, which are unnecessary for these web applications.

### 2.2. Kubernetes Configuration
*   **Service Accounts**: Pods use the `default` ServiceAccount, and `automountServiceAccountToken` is likely set to `true` (default).
*   **Impact**: If a pod is compromised, an attacker could potentially use the mounted API token to query the Kubernetes API Server.
*   **Filesystem**: The root filesystem is writable. Attackers can download tools or modify configuration files at runtime.

### 2.3. Database Access
*   **Issue**: Services (`auth-service`, `catalog-service`) connect to PostgreSQL using the `grocer_admin` user.
*   **Impact**: The application has full administrative rights (CREATE, DROP, ALTER tables) rather than just the necessary DML permissions (SELECT, INSERT, UPDATE).

### 2.4. Secrets Management
*   **Issue**: Sensitive data (e.g., `POSTGRES_PASSWORD`, `RABBITMQ_DEFAULT_PASS`) is defined as plain text environment variables in Deployment YAML files.
*   **Impact**: Secrets are visible in the repository code and `kubectl describe pod` output.

---

## 3. Implementation Plan (What We Can Apply)

The following changes are recommended to enforce Least Privilege.

### 3.1. Run Containers as Non-Root User
**Action**: Modify Dockerfiles to create a specific user and switch to it.

*   **Go/Node Services**: Create a user `appuser` (UID 1001) and switch to it at the end of the Dockerfile.
*   **Nginx**: Use the unprivileged Nginx image or configure Nginx to run on ports > 1024 so it doesn't require root.

**Example Implementation (Dockerfile):**
```dockerfile
# Create a group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
# Change ownership of the app directory
RUN chown -R appuser:appgroup /app
# Switch to non-root user
USER appuser
```

### 3.2. Kubernetes Security Context
**Action**: Update all Deployment YAMLs (`k8s-*.yaml`) to enforce security contexts.

*   **runAsNonRoot**: Force the container to verify it is not running as UID 0.
*   **readOnlyRootFilesystem**: Mount the root filesystem as read-only. Use `emptyDir` volumes for temporary directories like `/tmp`.
*   **drop capabilities**: Drop `ALL` capabilities.

**Example Implementation (YAML):**
```yaml
spec:
  securityContext:
    runAsUser: 1001
    runAsGroup: 1001
    fsGroup: 1001
  containers:
  - name: service-name
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

### 3.3. Restrict Service Account Tokens
**Action**: Disable token mounting for application pods that do not need to talk to the K8s API.

**Example Implementation (YAML):**
```yaml
spec:
  automountServiceAccountToken: false
```

### 3.4. Database Least Privilege
**Action**: Create specific database users for each service with limited grants.

1.  **Auth Service User**: Only `SELECT, INSERT` on `users` table.
2.  **Catalog Service User**: Only `SELECT` on `products` table (if it's read-heavy) or `SELECT, INSERT, UPDATE`.
3.  **Migration Job**: Use `grocer_admin` only for a specific K8s Job that runs schema migrations, not the running application.

### 3.5. Secure Secrets
**Action**: Move environment variables to Kubernetes Secrets.

**Example Implementation:**
1.  Create Secret: `kubectl create secret generic db-creds --from-literal=password=dev_secret_123`
2.  Reference in YAML:
    ```yaml
    env:
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-creds
          key: password
    ```

### 3.6. Network Policies (Optional but Recommended)
**Action**: Deny all traffic by default and explicitly allow traffic between specific services (e.g., BFF -> Auth, BFF -> Catalog).

---

## 4. Summary of Proposed Changes

| Component | Current State | Proposed State | Benefit |
| :--- | :--- | :--- | :--- |
| **User Identity** | Root (UID 0) | `appuser` (UID 1001) | Prevents root-level compromise of the container host. |
| **Filesystem** | Writable | Read-Only | Prevents attackers from downloading/executing malware. |
| **DB Access** | Admin (`grocer_admin`) | Service-specific User | Limits blast radius if a service is compromised. |
| **Secrets** | Plaintext Env Vars | K8s Secrets | Prevents accidental exposure of credentials. |
| **K8s Token** | Mounted | Unmounted | Prevents K8s API abuse. |

This plan provides a robust roadmap to hardening the GrocerSave application.
