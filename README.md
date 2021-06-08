# COEP: credentialless. Isolation w/o Opt-In?

Credentialless is a Cross-Origin-Embedder-Policy (COEP) variant. Similarly
to
[require-corp](https://html.spec.whatwg.org/multipage/origin.html#embedder-policy-value),
it can be used to enable [cross-origin-isolation](#cross-origin-isolation).
Contrary to require-corp, it is easier to deploy, instead of requiring a
Cross-Origin-Resource-Policy (CORP) header for every no-cors subresources,
COEP:credentialless is requesting them without credentials.

See:
- The [specification](https://htmlpreview.github.io/?https://github.com/mikewest/credentiallessness/blob/main/index.html)
- The [original explainer](./explainer.md)
