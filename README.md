# ios-certs-file-checker

Verify iOS Certificate and Provisioning Profile for GitHub Action.


## Usage
 - only use macos
 - setup Certificate and Provisioning Profile


You add the follows step on your github actions workflows.

```
 - name: verify ios certs file
   id: expire_check
   uses: tarappo/ios-certs-file-checker@v0.0.8
   with:
     slack_webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
     expire_limit_days: 30
```

## Example Result
Slack notify the follows.

```
[Provisioning Profile]
- XXXXXXX（残り約19日）
[Certificate(Distribution)]
- Apple Distribution: XXXXX. (XXXX)（残り約19日）
```
