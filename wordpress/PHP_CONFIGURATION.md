# PHP Configuration Guide

This guide shows how to configure PHP settings for WordPress using the Helm chart.

## Method 1: Using Built-in PHP Configuration (Recommended)

The chart includes built-in support for PHP configuration via ConfigMap. This is the easiest method.

### Enable and Configure

Add to your `values.yaml`:

```yaml
## PHP Configuration
phpConfiguration:
  enabled: true
  uploadMaxFilesize: "256M"
  postMaxSize: "256M"
  maxExecutionTime: 360
  maxInputTime: 360
  memoryLimit: "512M"
  maxInputVars: 3000
  additionalSettings: |
    max_file_uploads = 50
    default_socket_timeout = 60
```

### Or Use Custom INI Content

For complete control, use `customIni`:

```yaml
phpConfiguration:
  enabled: true
  customIni: |
    upload_max_filesize = 256M
    post_max_size = 256M
    max_execution_time = 360
    max_input_time = 360
    memory_limit = 512M
    max_input_vars = 3000
    max_file_uploads = 50
    default_socket_timeout = 60
```

### Install

```bash
helm install wordpress . -f values.yaml
```

The ConfigMap will be automatically created and mounted to `/usr/local/etc/php/conf.d/php-custom.ini`.

## Method 2: Using Existing ConfigMap

If you already have a ConfigMap (like the example you provided), you can use `extraVolumes` and `extraVolumeMounts`:

### Step 1: Create the ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: php-ini
  namespace: smokingdoodle
  labels:
    app.kubernetes.io/name: wordpress
data:
  php-custom.ini: |
    upload_max_filesize = 256M
    post_max_size = 256M
    max_execution_time = 360
    max_input_time = 360
    memory_limit = 512M
```

Apply it:
```bash
kubectl apply -f php-configmap.yaml
```

### Step 2: Configure values.yaml

```yaml
wordpressBlogName: "My Smoking Doodle WordPress Site"

# Use extraVolumes and extraVolumeMounts
extraVolumes:
  - name: php-ini
    configMap:
      name: php-ini

extraVolumeMounts:
  - name: php-ini
    mountPath: /usr/local/etc/php/conf.d/php-custom.ini
    subPath: php-custom.ini
    readOnly: true
```

### Important: Mount Path

The correct mount path for PHP configuration files in the official WordPress image is:
```
/usr/local/etc/php/conf.d/php-custom.ini
```

When using `subPath` to mount a single file from a ConfigMap, the `mountPath` must be the **full path including the filename**.

## Verification

After deployment, verify PHP settings:

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=wordpress -o jsonpath='{.items[0].metadata.name}')

# Check PHP configuration
kubectl exec -it $POD_NAME -- php -i | grep -E "upload_max_filesize|post_max_size|memory_limit|max_execution_time"
```

Or check the ini file:

```bash
kubectl exec -it $POD_NAME -- cat /usr/local/etc/php/conf.d/php-custom.ini
```

## Available PHP Settings

Common settings you can configure:

| Setting | Description | Example Value |
|---------|-------------|---------------|
| `upload_max_filesize` | Maximum size of uploaded files | `256M` |
| `post_max_size` | Maximum size of POST data | `256M` |
| `max_execution_time` | Maximum execution time (seconds) | `360` |
| `max_input_time` | Maximum input parsing time (seconds) | `360` |
| `memory_limit` | Maximum memory per script | `512M` |
| `max_input_vars` | Maximum input variables | `3000` |
| `max_file_uploads` | Maximum number of files | `50` |
| `upload_tmp_dir` | Temporary directory for uploads | `/tmp` |

## Notes

- PHP configuration files in `/usr/local/etc/php/conf.d/` are automatically loaded by PHP
- Settings in custom ini files override default PHP settings
- Changes require pod restart to take effect
- The official WordPress image uses PHP, so `/usr/local/etc/php/conf.d/` is the correct path
