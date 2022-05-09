[HTML]: https://github.com/whatwg/html
[Fetch]: https://github.com/whatwg/fetch

<details>
  <summary><strong>Obsoletion notice</strong></summary>
  
  [**COEP:credentialless**](https://github.com/WICG/credentiallessness) merged into the [HTML] and [Fetch] specification.
  
  See PR:
  - whatwg/html/pull/6638
  - whatwg/fetch/pull/1229

  Significant sections: 
  - HTML:
  [(1)](https://html.spec.whatwg.org/multipage/origin.html#coep-credentialless)
  [(2)](https://html.spec.whatwg.org/multipage/origin.html#obtain-an-embedder-policy)
  [(3)](https://html.spec.whatwg.org/multipage/origin.html#compatible-with-cross-origin-isolation)
  [(4)](https://fetch.spec.whatwg.org/#cross-origin-embedder-policy-allows-credentials)
  - Fetch:
  [(1)](https://fetch.spec.whatwg.org/#cross-origin-resource-policy-internal-check)
  [(2)](https://fetch.spec.whatwg.org/#response-request-includes-credentials)
  [(3)](https://fetch.spec.whatwg.org/#ref-for-cross-origin-embedder-policy-allows-credentials)
  
  This document is not going to be actively maintained, please refer to [HTML] and [Fetch] as the source of truth for implementations.
</details>

# COEP: credentialless. Isolation w/o Opt-In?

Credentialless is a Cross-Origin-Embedder-Policy (COEP) variant. Similarly
to
[require-corp](https://html.spec.whatwg.org/multipage/origin.html#embedder-policy-value),
it can be used to enable [cross-origin-isolation](#cross-origin-isolation).
Contrary to require-corp, it is easier to deploy, instead of requiring a
Cross-Origin-Resource-Policy (CORP) header for every no-cors subresources,
COEP:credentialless is requesting them without credentials.

- [Explainer](./explainer.md)
- [Specification](https://wicg.github.io/credentiallessness/)
- [Experimenting instructions](./experimenting.md)
