#!/bin/bash
echo "Adding user secondary"
$JBOSS_HOME/bin/add-user.sh -u ${JBOSS_EAP_DOMAIN_USER} -p ${JBOSS_EAP_DOMAIN_PASSWORD}

echo "deploying applications"
$JBOSS_HOME/bin/jboss-cli.sh --file=${JBOSS_EAP_DOMAIN_DOMAIN_INIT_PATH}/scripts/cli.txt --echo-command

if [ -n "$JBOSS_EAP_DOMAIN_WEB_CONSOLE_ROUTE" ]; then
  echo "Enabling Web Console route $JBOSS_EAP_DOMAIN_WEB_CONSOLE_ROUTE"
  $JBOSS_HOME/bin/jboss-cli.sh --file=${JBOSS_EAP_DOMAIN_DOMAIN_INIT_PATH}/scripts/cli-web-console.txt --echo-command --resolve-parameter-values
fi

