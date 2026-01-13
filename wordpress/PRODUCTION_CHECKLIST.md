# Production Deployment Checklist

Use this checklist before deploying WordPress to production.

## Pre-Deployment Security

### Image Security
- [ ] Use image digest instead of tags (set `image.digest`)
- [ ] Set `image.pullPolicy: Always`
- [ ] Scan images for vulnerabilities (Trivy, Snyk)
- [ ] Verify image signatures (cosign, Notary)
- [ ] Use private registry if possible

### Secrets Management
- [ ] Set strong `wordpressPassword` (min 16 chars, mixed case, numbers, symbols)
- [ ] Set `allowEmptyPassword: false`
- [ ] Use external secret manager (Vault, Sealed Secrets, External Secrets Operator)
- [ ] Set strong database passwords
- [ ] Rotate secrets regularly
- [ ] Never commit secrets to Git

### Network Security
- [ ] Use `ClusterIP` service type with Ingress (not LoadBalancer)
- [ ] Enable TLS/HTTPS (`ingress.tls: true`)
- [ ] Configure cert-manager for automatic certificate management
- [ ] Restrict NetworkPolicy (`networkPolicy.allowExternal: false`)
- [ ] Configure specific ingress/egress rules
- [ ] Implement rate limiting
- [ ] Add WAF (Web Application Firewall)

### Pod Security
- [ ] Enable Pod Security Standards (restricted)
- [ ] Verify `runAsNonRoot: true`
- [ ] Verify `allowPrivilegeEscalation: false`
- [ ] Verify `readOnlyRootFilesystem: false` (required for WordPress)
- [ ] Drop all capabilities
- [ ] Use seccomp profiles
- [ ] Avoid root containers

## High Availability

### Replication
- [ ] Set `replicaCount: 2` or higher
- [ ] Enable pod anti-affinity (`podAntiAffinityPreset: soft`)
- [ ] Configure PDB (`pdb.minAvailable: 1` or `"50%"`)
- [ ] Test pod disruption scenarios

### Update Strategy
- [ ] Configure `updateStrategy.rollingUpdate.maxSurge: 1`
- [ ] Configure `updateStrategy.rollingUpdate.maxUnavailable: 0`
- [ ] Test rolling updates
- [ ] Verify zero-downtime deployments

## Resource Management

### Resource Limits
- [ ] Set CPU limits and requests
- [ ] Set memory limits and requests
- [ ] Set limits for all containers (including sidecars)
- [ ] Configure LimitRange in namespace
- [ ] Right-size resources based on monitoring

### Autoscaling
- [ ] Enable HPA (`autoscaling.enabled: true`)
- [ ] Set appropriate min/max replicas
- [ ] Configure CPU/memory thresholds
- [ ] Test autoscaling behavior

## Monitoring & Observability

### Metrics
- [ ] Enable metrics (`metrics.enabled: true`)
- [ ] Configure ServiceMonitor for Prometheus
- [ ] Set up Grafana dashboards
- [ ] Configure alerting rules

### Logging
- [ ] Set up centralized logging (ELK, Loki)
- [ ] Configure log aggregation
- [ ] Set up log retention policies
- [ ] Configure log rotation

### Health Checks
- [ ] Enable all probes (liveness, readiness, startup)
- [ ] Configure appropriate timeouts
- [ ] Test health check endpoints
- [ ] Monitor probe failures

## Backup & Disaster Recovery

### Backup Strategy
- [ ] Implement backup solution (Velero, Kasten)
- [ ] Configure automated backups
- [ ] Test backup restoration
- [ ] Document backup procedures
- [ ] Set backup retention policies

### Database Backups
- [ ] Configure MariaDB backups
- [ ] Test database restoration
- [ ] Set up point-in-time recovery
- [ ] Document recovery procedures

### Volume Snapshots
- [ ] Configure volume snapshots
- [ ] Test snapshot restoration
- [ ] Set snapshot retention policies

## WordPress Configuration

### Security Settings
- [ ] Set `wordpressDebug: false`
- [ ] Configure security headers
- [ ] Enable file upload restrictions
- [ ] Configure rate limiting
- [ ] Set up security plugins (Wordfence, Sucuri)

### Performance
- [ ] Enable Memcached/Redis
- [ ] Configure caching
- [ ] Optimize PHP settings
- [ ] Enable CDN if applicable

### SSL/TLS
- [ ] Enable HTTPS redirect
- [ ] Configure HSTS headers
- [ ] Verify certificate validity
- [ ] Set up certificate auto-renewal

## Compliance & Auditing

### Audit Logging
- [ ] Enable Kubernetes audit logging
- [ ] Configure log aggregation
- [ ] Set up alerting for security events
- [ ] Review audit logs regularly

### Security Scanning
- [ ] Run security scans (Trivy, Snyk, Falco)
- [ ] Fix critical vulnerabilities
- [ ] Document security findings
- [ ] Schedule regular scans

### Documentation
- [ ] Document deployment procedures
- [ ] Document disaster recovery plan
- [ ] Document security policies
- [ ] Document monitoring procedures

## Testing

### Pre-Production Testing
- [ ] Test in staging environment
- [ ] Load testing
- [ ] Security testing
- [ ] Failover testing
- [ ] Backup/restore testing

### Post-Deployment
- [ ] Verify all services are running
- [ ] Verify health checks
- [ ] Verify monitoring is working
- [ ] Verify backups are running
- [ ] Document any issues

## Maintenance

### Regular Tasks
- [ ] Update WordPress regularly
- [ ] Update plugins and themes
- [ ] Review security advisories
- [ ] Rotate secrets
- [ ] Review and update resource limits
- [ ] Review and update monitoring alerts

### Incident Response
- [ ] Document incident response procedures
- [ ] Set up on-call rotation
- [ ] Test incident response procedures
- [ ] Review incidents and improve
