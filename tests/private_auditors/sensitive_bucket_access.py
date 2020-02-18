from parliament import is_arn_match, expand_action


def audit(policy):
    action_resources = {}
    for action in expand_action("s3:*"):
        # Iterates through a list of containing elements such as
        # {'service': 's3', 'action': 'GetObject'}
        action_name = "{}:{}".format(action["service"], action["action"])
        action_resources[action_name] = policy.get_allowed_resources(
            action["service"], action["action"]
        )

    for action_name in action_resources:
        resources = action_resources[action_name]
        for r in resources:
            if is_arn_match("object", "arn:aws:s3:::secretbucket*", r) or is_arn_match(
                "object", "arn:aws:s3:::othersecretbucket*", r
            ):
                policy.add_finding(
                    "SENSITIVE_BUCKET_ACCESS",
                    location={"action": action_name, "resource": r},
                )
