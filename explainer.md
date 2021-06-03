# COEP: credentialless. Isolation w/o Opt-In?

[@camillelamy](https://github.com/camillelamy), [@clelland](https://github.com/clelland), [@mikewest](https://github.com/mikewest), [@ArthurSonzogni](https://github.com/ArthurSonzogni) - Nov. 2020 - Mai 2021

## A Problem

Sites that wish to continue using SharedArrayBuffer must opt-into cross-origin isolation. Among other things, cross-origin isolation will block the use of cross-origin resources and documents unless those resources opt-into inclusion via either CORS or CORP. This behavior ships today in Firefox, and Chrome aims to ship it as well in 2021H1.

The opt-in requirement is generally positive, as it ensures that developers have the opportunity to adequately evaluate the rewards of being included cross-site against the risks of potential data leakage via those environments. It poses adoption challenges, however, as it does require developers to adjust their servers to send an explicit opt-in. This is challenging in cases where there's not a single developer involved, but many. Google Earth, for example, includes user-generated content in sandboxed frames, and it seems somewhat unlikely that they'll be able to ensure that all the resources typed in by all their users over the years will do the work to opt-into being loadable.

Cases like Earth are, likely, outliers. Still, it seems clear that adoption of any opt-in mechanism is going to be limited. From a deployment perspective (especially with an eye towards changing default behaviors), it would be ideal if we could find an approach that provided robust-enough protection against accidental cross-process leakage without requiring an explicit opt-in.

## A Proposal

The goal of the existing opt-in is to block interesting data that an attacker wouldn't otherwise have access to from flowing into a process they control. It might be possible to obtain a similar result by minimizing the risk that outgoing requests will generate responses personalized to a specific user by extending [COEP](https://html.spec.whatwg.org/multipage/origin.html#coep) to support a new `credentialless` mode which strips credentials (cookies, client certs, etc) by default for non-CORS subresource requests. Let's explore that addition first, then look at whether it's Good Enough to enable cross-origin isolation.

### What is COEP:credentialless?

#### Subresource requests

In this new COEP variant, cross-origin no-cors subresource requests would be sent without credentials. Specific requests which require credentials can opt-into including them, at the cost of shifting the request's mode to require a [CORS check](https://fetch.spec.whatwg.org/#concept-cors-check) on the response. This bifurcation between credentiallessness and CORS means either that servers don't have browser-provided identifiers which could be used to personalize a response (see the isolation section below), or that they explicitly opt-in to exposing the response's content to the requesting origin.

As an example, consider a developer who wishes to load an image into a context isolated in the way described above. The `<img>` element has a `crossorigin` attribute which allows developers to alter the outgoing request's state. In this new mode, the following table describes the outgoing request's properties in Fetch's terms for various values:

| | Request's [Mode](https://fetch.spec.whatwg.org/#concept-request-mode) | Request's [Credentials Mode](https://fetch.spec.whatwg.org/#concept-request-credentials-mode) | [includeCredentials](https://fetch.spec.whatwg.org/#http-network-or-cache-fetch) <sub> COEP:unsafe-none</sub> | [includeCredentials](https://fetch.spec.whatwg.org/#http-network-or-cache-fetch) <sub> COEP:credentialless</sub>
|-|----------------|----------------------------| --- | --- |
| `<img src="https://same-origin/">` | `same-origin` | `include` | `true` | `true`
| `<img src="https://cross-origin/">` | `no-cors` | `include` | `true` | **`false`**
| <code>&lt;img src="https://cross-origin/" <strong>crossorigin="anonymous"</strong>></code> | `no-cors` | `omit` | `false` | `false`
| <code>&lt;img src="https://cross-origin/" <strong>crossorigin="use-credentials"</strong>></code> | `cors` | `include` | `true` | `true`

#### Main resource requests

Cross-origin nested navigational requests (`<iframe>`, etc) are more complicated, as they present risks different in kind from subresources. Frames create a browsing context with an origin distinct from the parent, which has implications on the data it has access to via requests on the one hand and storage APIs on the other. Given this capability, it seems clear that we can't just strip credentials from the nested navigational request and call it a day in the same way that we could with subresources.

For this reason, `COEP:credentialless` is as strict as `COEP:require-corp` for navigationnal requests, and works identically.
  
That is to say:
1. If the parent sets `COEP:credentialless` or `COEP:require-corp`, then the children must also use `COEP:credentialless` or `COEP:require-corp`. If it doen't, its response is blocked by COEP. The two COEP values can be used and mixed in any order.
2. If the parent sets `COEP:credentialless` or `COEP:require-corp`, then the children is required to specify a CORP header when it is cross-origin.

**Note:** To help developers with embedding cross-origin <iframe> without opt-in from the embeddee, the [anonymous iframe](https://github.com/w3ctag/design-reviews/issues/639) project has been proposed. This is orthogonal to `COEP:credentialless`. The latter only deals with subresources.
  
  
#### CacheStorage requests
  
See the issue:
https://github.com/w3c/ServiceWorker/issues/1592
  
Similarly to `COEP:require-corp`, the behavior of CacheStorage must be specified for `COEP:credentialless`.
A cross-origin credentialled response, with no CORP header, requested from `COEP:unsafe-none` context must not enter a `COEP:credentialless` context via `CacheStorage.{put,match}`.

The solution proposed is to store the `includeCredentials` variable from the
[HTTP-network-or-cache-fetch](https://fetch.spec.whatwg.org/#http-network-or-cache-fetch)
algorithm into the response. Then during the
[dom-cache-match-all](https://w3c.github.io/ServiceWorker/#dom-cache-matchall)
algorithm, to block "opaque" responses containing credentials for
COEP:credentialless documents.

### Does `COEP:credentialless` support cross-origin isolation?

Above, we asserted that the core goal of the existing opt-in requirement is to block interesting data that an attacker wouldn't otherwise have access to from flowing into a process they control. Removing credentials from outgoing requests seems like quite a reasonable way to deal with this for the kinds of requests which may vary based on browser-mediated credentials (cookies, client certs, etc). In these cases, `COEP:credentialless` would seem to substantially mitigate the risk of personalized data flowing into an attacker's process.

Some servers, however, don't actually use browser-mediated credentials to control access to a resource. They may examine the network characteristics of a user's request (originating IP address, [relationship with the telco](https://datapass.de/), etc) in order to determine whether and how to respond; or they might not even be accessible to attackers directly, instead requiring a user to be in a privileged network position. These resources would continue to leak data in a credentialless model.

Let's assert for the moment that servers accessible only via a privileged network position can be dealt with entirely by putting a wall between "public" and "private", along the lines of the [CORS and RFC1918 proposal](https://wicg.github.io/cors-rfc1918/). Successfully rolling out that kind of model would address the threat of this kind of leakage, perhaps allowing us to hand-wave it away.

IP-based authentication models are, on the other hand, more difficult to address. Though the practice is unfortunate in itself (users should have control over their state vis a vis servers they interact with on the one hand, and sensitive data should [assume a zero-trust network](https://cloud.google.com/beyondcorp) on the other), we know it's used in the wild for things like telco billing pages. In a credentialless isolation model, resources these servers expose would continue to flow into cross-origin processes unless and until they explicitly opted-out of that inclusion via CORP. We can minimize the risk of these attacks by increasing CORB's robustness on the one hand, and [requiring opt-in for embedded usage](https://goto.google.com/embedding-requires-consent) on the other.

This leaves us with a tradeoff to evaluate: `COEP:credentialless` seems substantially easier than `COEP:require-corp` to deploy, both as an opt-in in the short-term, and (critically) as default behavior in the long term. It does substantially reduce the status quo risk. At the same time, it doesn't prevent a category of resources from flowing into attackers' processes. We have reasonable ideas about one chunk of these resources, and would simply not protect the other without explicit opt-in.

Perhaps that's a tradeoff worth taking? The mechanism seems worth defining regardless, even if we don't end up considering it a fully cross-origin isolated context.

## FAQ

### Is the crossorigin attribute a reasonable opt-in?

The `crossorigin` attribute currently exists on `<audio>`, `<img>`, `<link>`, `<video>`, and `<script>` HTML elements, as well as the `<image>` and `<script>` SVG elements. For these elements, it seems quite reasonable to continue using `crossorigin` to distinguish between `no-cors` and `CORS` request modes.

Some requests don't yet have reasonable mechanisms for setting a CORS preference. Consider resources included via CSS (`@import`, `url(...)`, etc.), for example. These would be credentialless until such a mechanism is invented.

### How would a server safely respond to `COEP:credentialless` requests?

Most servers would simply serve generic results when presented with a `COEP:credentialless` request. Static resources would be served as-is (which isn't interesting to an attacker, as they could access those resources themselves), resources with access controls might redirect to a login page (which would likely be blocked by CORB on the one hand, and would be accessible by the attacker in any event).

These servers would likewise respond to CORS-enabled requests in precisely the way they do today allowing expected requests via appropriate response headers and rejecting the rest.

As noted above, however, some servers don't actually use request credentials to control access to a resource. They may examine the network characteristics of a user's request (originating IP address, relationship with the telco, etc) in order to determine whether and how to respond; or they might not even be accessible to attackers directly, instead requiring a user to be in a privileged network position. These resources might continue to leak data in a credentialless model, which is quite unfortunate!

These servers would need to continue opting-out of allowing other origins to embed their resources by sending appropriate CORP headers along with sensitive responses (`Cross-Origin-Resource-Policy: same-origin`, for example). It could also be reasonable to add a new Fetch Metadata header exposing the isolation status of the context making the request.

### What about cached resources?

It would be unfortunate if a resource requested with credentials was used for an uncredentialed request, as that might leak data unexpectedly. Servers can ensure that resources are delivered with Vary: Cookie or similar, but it might instead be reasonable to take the request's credential mode into account as part of the HTTP cache key. This would more directly address the underlying problem without requiring developer intervention.

### Does `COEP:credentialless` by default have privacy benefits?

It has substantial security implications, but no impact on privacy. If you squint a lot, you can think of it as something like the inverse of SameSite=None; that mechanism requires each resources' server to explicitly declare its willingness to serve authenticated resources in cross-origin contexts. The mechanism described in this document requires embedders to use the crossorigin attribute to declare their intent to embed authenticated cross-origin resources, and by doing so, require embedees to narrowly scope their grants via CORS.

You can imagine how that might allow user agents to do interesting things in follow-on changes, but in itself the change described here creates no new privacy boundary.
  
It would be unfortunate if a resource requested with credentials was used for an uncredentialed request, as that might leak data unexpectedly. Servers can ensure that resources are delivered with Vary: Cookie or similar, but it might instead be reasonable to take the request's credential mode into account as part of the HTTP cache key. This would more directly address the underlying problem without requiring developer intervention.
  
## Specification

Implementing this new COEP value would require modifying the HTML and Fetch specification:
  
* HTML (https://github.com/whatwg/html/pull/6638)
  * Define how to parse the `credentialless` value.
  * From the HTML spec point of view, `credentialless` and `require-corp` are equivalent. They have been grouped into `compatible with crossOriginIsolation` and the HTML spec rewritten to use this concept.

* Fetch: (https://github.com/whatwg/fetch/pull/1229)
  * Define `Cross-Origin-Embedder-Policy allows credentials` algorithm. It omits credentials for no-cors, cross-origin, COEP:credentialless requests.
  * Define `response's` `request-include-credentials` flag.
  * In the `Cross-Origin-Resource-Policy check`, if `embedderPolicy` is `credentialless`, require CORP for navigational responses, and opaque responses with `request-include-credentials`.
