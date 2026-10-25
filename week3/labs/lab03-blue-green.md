> **Topic:** Blue/Green Deployment Strategy
> **Exam Domain:** Application Deployment (20%)
> **Estimated Time:** ~20 minutes
> **Namespace:** `ckad-lab13`
> **Check Command:** `bash week3/labs/checks/lab03-check.sh`

---

# Lab 03 — Blue/Green Deployment

## 🎯 Objective

In namespace `ckad-lab13`, implement a blue/green deployment pattern using two separate Deployments and a single Service. Cut traffic over from the blue (old) version to the green (new) version by updating the Service selector.

**Resources to create:**

| Resource | Name | Detail |
|---|---|---|
| Deployment (blue) | `myapp-blue` | image `nginx:1.20`, 3 replicas, labels `app=myapp, version=blue` |
| Deployment (green) | `myapp-green` | image `nginx:1.21`, 3 replicas, labels `app=myapp, version=green` |
| Service | `myapp-svc` | type `ClusterIP`, port `80`, initially selects `app=myapp, version=blue` |

**Final state:** The Service `myapp-svc` selector must point to `version=green` (the cutover must be complete).

---

## 📋 Tasks

**A.** Create the namespace `ckad-lab13`, then write a Deployment manifest for `myapp-blue` with image `nginx:1.20`, 3 replicas, and pod template labels `app=myapp` and `version=blue`.

**B.** Write a Service manifest for `myapp-svc` of type `ClusterIP` on port `80`, with selector `app=myapp` and `version=blue`.

**C.** Apply both the blue Deployment and the Service to the cluster.

**D.** Write a Deployment manifest for `myapp-green` with image `nginx:1.21`, 3 replicas, and pod template labels `app=myapp` and `version=green`.

**E.** Apply the green Deployment to the cluster and wait for it to be fully ready.

**F.** Switch the `myapp-svc` Service selector to route traffic to the green Deployment by changing `version` to `green`. Confirm the service now targets the green pods.

---

## 🏁 Check your work

```bash
bash week3/labs/checks/lab03-check.sh
```

---

## 🧹 Manual Cleanup

> Only run this if the check script did not auto-cleanup.

```bash
kubectl delete namespace ckad-lab13 --force --grace-period=0
```
