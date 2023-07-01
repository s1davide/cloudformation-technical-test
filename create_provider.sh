#!/bin/bash

: 'This bash script creates the identity provider and role to allow to get 
the status of AWS Code Pipeline and synchronize it with Git Hub Actions. 
- You must have previously installed Open SSL:
  https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html#oidc-install-openssl  
- You must execute these commands with credentials that have permissions 
  to create identity provider, roles and policies.
'

domain_name=token.actions.githubusercontent.com
certificate_name=certificate.crt    
role_name=$ROLE_NAME
policy_name="$POLICY_NAME-$role_name"
rm -f $certificate_name
openssl s_client -servername $domain_name -showcerts -connect $domain_name:443 \
    < /dev/null 2>/dev/null | openssl x509 -outform pem >> $certificate_name

fingerprint=`openssl x509 -in "$certificate_name" -fingerprint -sha1 -noout`
thumbprint=$(echo "$fingerprint" | sed 's/SHA1 Fingerprint=//g' | tr -d ':')

arn_identity_provider=$(aws iam create-open-id-connect-provider --url https://$domain_name  \
        --thumbprint-list $thumbprint --client-id-list sts.amazonaws.com \
        --query 'OpenIDConnectProviderArn' --output text)

assume_role_policy=$(cat ./assume-role-policy.json)
assume_role_policy=$(echo $assume_role_policy | sed s#arn_identity_provider#$arn_identity_provider#)
assume_role_policy=$(echo $assume_role_policy | sed s#domain_name#$domain_name#)

aws iam create-role --role-name $role_name --assume-role-policy-document $assume_role_policy 2>&1 > /dev/null

codepipeline_get_status_policy=$(cat ./codepipeline-get-status-policy.json)

aws iam put-role-policy --role-name $role_name --policy-name $policy_name --policy-document $codepipeline_get_status_policy  2>&1 > /dev/null

echo "Finished running the script to create an entity provider."