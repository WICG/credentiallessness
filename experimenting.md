[demo]:https://coep-credentialless.glitch.me/
[origin trial]:https://developer.chrome.com/origintrials/#/view_trial/3036552048754556929
[Request a token]:https://developer.chrome.com/origintrials/#/view_trial/3036552048754556929

Experimenting instructions:
===========================

- [Chrome](#chrome)
  * [Feature flag](#feature-flag)
  * [Origin Trial](#origin-trial)
- [Firefox](#firefox)
- [Webkit](#webkit)

Chrome
======

[Feature status](https://chromestatus.com/features/4918234241302528)

COEP:credentialless will be available for experimenting behind a flag and an
[Origin Trial](https://github.com/GoogleChrome/OriginTrials) starting from
version M93.

From Chrome >= M96, it is now **enabled by default**.

Feature flag
-------------

Starting from Chrome M93. COEP:credentialless can be enabled via two options:
- The command line switch `--enable-features=CrossOriginEmbedderPolicyCredentialless`
- The browser flag `chrome://flags/#cross-origin-embedder-policy-credentialless`

You can use the following [demo] to check it has been enabled.

Origin Trial
------------

COEP:credentialless is available as an [origin trial] in Chrome 93 to 95. The
origin trial ends on November 3rd, 2021.

Origin trials allow you to try new features on your website and give feedback on
their usability, practicality, and effectiveness to the web standards community.

How to register for the Origin Trial?
1. [Request a token] for your origin.
2. Configure your server to send the HTTP headers:
```http
Origin-Trial: TOKEN_GOES_HERE
Cross-Origin-Embedder-Policy: credentialless
```
**WARNING**. Declaring the Origin Trial and Cross-Origin-Embedder-Policy via the
`<meta>` tag isn't supported!

Firefox
=======

[Request for position: COEP:credentialless](https://github.com/mozilla/standards-positions/issues/539#issuecomment-867473836)

Webkit
======

[Request for position: COEP: credentialless](https://lists.webkit.org/pipermail/webkit-dev/2021-June/031898.html)
