 private_link_access:-
Go to: Azure Portal → Microsoft Defender for Cloud.
Under "Environment settings", select your subscription.
Click on "Storage" under "Defender plans".
Scroll down to the “Data scanning” section.
If enabled, you’ll see a Private Link or Storage Data Scanner resource.
Click on it and open its properties.
Look for the Resource ID — it will look like:
Copy this string → this is your endpoint_resource_id.

endpoint_tenant_id: Usually your tenant ID