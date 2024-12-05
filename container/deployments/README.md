For the demos that use deployments:

* oc import-image jboss-eap8-domain-openjdk17-openshift:6.0-update3.1 --from=quay.io/jdenise/jboss-eap8-domain-openjdk17-openshift:6.0-update3.1 --confirm
* oc import-image jboss-eap8-domain-openjdk17-openshift:4.0 --from=quay.io/jdenise/jboss-eap8-domain-openjdk17-openshift:4.0 --confirm
* oc tag jboss-eap8-domain-openjdk17-openshift:4.0 jboss-eap8-domain-openjdk17-openshift:latest
* oc set image-lookup jboss-eap8-domain-openjdk17-openshift
* oc create -f domain-mode-dc.yaml
* oc create -f domain-mode-ha-app.yaml
* oc create -f domain-mode-db-app.yaml

For the Rolling Upgrade update demo, call:

* oc tag jboss-eap8-domain-openjdk17-openshift:6.0-update3.1 jboss-eap8-domain-openjdk17-openshift:latest

The upgrade will be automatically handled. You can see the pods being killed in turn.



